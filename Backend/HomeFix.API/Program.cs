using HomeFix.BLL;
using HomeFix.BLL.Models;
using HomeFix.DAL.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Enter your JWT token."
    });

    options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddHomeFixBLL(builder.Configuration);

var jwtSettings = builder.Configuration.GetSection("Jwt").Get<JwtSettings>()
                  ?? throw new InvalidOperationException("Jwt configuration is missing.");

if (string.IsNullOrWhiteSpace(jwtSettings.Key) || Encoding.UTF8.GetByteCount(jwtSettings.Key) < 32)
    throw new InvalidOperationException("Jwt:Key must be configured and contain at least 32 bytes for HS256.");

if (string.IsNullOrWhiteSpace(jwtSettings.Issuer) || string.IsNullOrWhiteSpace(jwtSettings.Audience))
    throw new InvalidOperationException("Jwt:Issuer and Jwt:Audience must be configured.");

if (!builder.Environment.IsDevelopment())
{
    ValidateRequiredConfiguration(builder.Configuration,
        "ConnectionStrings:DefaultConnection",
        "Email:Host",
        "Email:Username",
        "Email:Password",
        "Email:From");
}

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidAudience = jwtSettings.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.Key)),
            ClockSkew = TimeSpan.FromSeconds(30)
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
});

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.OnRejected = async (context, cancellationToken) =>
    {
        context.HttpContext.Response.ContentType = "application/problem+json";
        await context.HttpContext.Response.WriteAsJsonAsync(new
        {
            type = "https://httpstatuses.com/429",
            title = "Too many requests.",
            status = StatusCodes.Status429TooManyRequests,
            detail = "Please try again later."
        }, cancellationToken);
    };

    options.AddPolicy("auth", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            GetRateLimitPartitionKey(httpContext),
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 10,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0,
                AutoReplenishment = true
            }));

    options.AddPolicy("verification", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            GetRateLimitPartitionKey(httpContext),
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0,
                AutoReplenishment = true
            }));
});

builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database", tags: new[] { "ready" });

builder.Services.AddProblemDetails();

var app = builder.Build();

app.UseExceptionHandler(exceptionApp =>
{
    exceptionApp.Run(async context =>
    {
        var exception = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerFeature>()?.Error;
        var logger = context.RequestServices.GetRequiredService<ILoggerFactory>().CreateLogger("GlobalExceptionHandler");
        var traceId = context.TraceIdentifier;
        logger.LogError(
            "Unhandled exception {ExceptionType} for {Method} {Path}. TraceId: {TraceId}",
            exception?.GetType().FullName ?? "Unknown",
            context.Request.Method,
            context.Request.Path,
            traceId);

        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        context.Response.ContentType = "application/problem+json";
        await context.Response.WriteAsJsonAsync(new
        {
            type = "https://httpstatuses.com/500",
            title = "An unexpected error occurred.",
            status = StatusCodes.Status500InternalServerError,
            traceId
        });
    });
});

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false
}).AllowAnonymous();

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(new
        {
            status = report.Status.ToString(),
            checks = report.Entries.ToDictionary(
                e => e.Key,
                e => new { status = e.Value.Status.ToString() })
        });
    }
}).AllowAnonymous();

app.MapControllers();

app.Run();

static string GetRateLimitPartitionKey(HttpContext httpContext)
    => httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

static void ValidateRequiredConfiguration(IConfiguration configuration, params string[] keys)
{
    var missing = keys.Where(key => string.IsNullOrWhiteSpace(configuration[key])).ToArray();
    if (missing.Length > 0)
        throw new InvalidOperationException($"Required production configuration is missing: {string.Join(", ", missing)}.");
}

public sealed class DatabaseHealthCheck : IHealthCheck
{
    private readonly HomeFixDbContext _dbContext;

    public DatabaseHealthCheck(HomeFixDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var canConnect = await _dbContext.Database.CanConnectAsync(cancellationToken);
            return canConnect
                ? HealthCheckResult.Healthy()
                : HealthCheckResult.Unhealthy("Database connection is unavailable.");
        }
        catch
        {
            return HealthCheckResult.Unhealthy("Database health check failed.");
        }
    }
}
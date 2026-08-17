using HomeFix.API.DTOs.Auth;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IJwtService _jwtService;

    public AuthController(IAuthService authService, IJwtService jwtService)
    {
        _authService = authService;
        _jwtService = jwtService;
    }

    [AllowAnonymous]
    [EnableRateLimiting("auth")]
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        var result = await _authService.RegisterAsync(request.FullName, request.Email, request.PhoneNumber, request.Password, request.Role);
        if (!result.Success) return BadRequest(new { message = result.Error });
        var user = result.User!;
        return Ok(new AuthResponse { UserId = user.Id, FullName = user.FullName, Email = user.Email, Role = user.Role, RequiresEmailVerification = true });
    }

    [AllowAnonymous]
    [EnableRateLimiting("verification")]
    [HttpPost("verify-email")]
    public async Task<IActionResult> VerifyEmail(VerifyCodeRequest request)
    {
        var result = await _authService.VerifyEmailAsync(request.Email, request.Code);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Email verified successfully." });
    }

    [AllowAnonymous]
    [EnableRateLimiting("auth")]
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var result = await _authService.ValidateLoginAsync(request.Email, request.Password);
        if (!result.Success)
        {
            return Unauthorized(new { message = result.Error, requiresEmailVerification = result.User?.IsEmailVerified == false });
        }
        return Ok(await BuildAuthResponseAsync(result.User!));
    }

    [AllowAnonymous]
    [EnableRateLimiting("auth")]
    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh(RefreshTokenRequest request)
    {
        var result = await _authService.ValidateRefreshTokenAsync(request.RefreshToken);
        if (!result.Success) return Unauthorized(new { message = result.Error });

        await _authService.RevokeRefreshTokenAsync(request.RefreshToken);
        var refreshToken = await _authService.CreateRefreshTokenAsync(result.User!);

        return Ok(new { accessToken = _jwtService.GenerateAccessToken(result.User!), refreshToken });
    }

    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(RefreshTokenRequest request)
    {
        var success = await _authService.RevokeRefreshTokenAsync(request.RefreshToken);
        return success ? Ok(new { message = "Logged out successfully." }) : NotFound(new { message = "Refresh token not found." });
    }

    [AllowAnonymous]
    [EnableRateLimiting("auth")]
    [HttpPost("google")]
    public async Task<IActionResult> Google(GoogleLoginRequest request)
    {
        var result = await _authService.GoogleLoginAsync(request.IdToken);
        if (!result.Success) return Unauthorized(new { message = result.Error });
        return Ok(await BuildAuthResponseAsync(result.User!));
    }

    [AllowAnonymous]
    [EnableRateLimiting("verification")]
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
    {
        var result = await _authService.RequestPasswordResetAsync(request.Email);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "If the account exists, a password reset code has been issued." });
    }

    [AllowAnonymous]
    [EnableRateLimiting("verification")]
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(ResetPasswordRequest request)
    {
        var result = await _authService.ResetPasswordAsync(request.Email, request.Code, request.NewPassword);
        if (!result.Success) return BadRequest(new { message = result.Error });
        return Ok(new { message = "Password reset successfully." });
    }

    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {
        return Ok(new
        {
            userId = User.FindFirstValue(ClaimTypes.NameIdentifier),
            name = User.FindFirstValue(ClaimTypes.Name),
            email = User.FindFirstValue(ClaimTypes.Email),
            role = User.FindFirstValue(ClaimTypes.Role)
        });
    }

    private async Task<AuthResponse> BuildAuthResponseAsync(HomeFix.DAL.Entities.User user)
    {
        return new AuthResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            Role = user.Role,
            AccessToken = _jwtService.GenerateAccessToken(user),
            RefreshToken = await _authService.CreateRefreshTokenAsync(user),
            RequiresEmailVerification = !user.IsEmailVerified
        };
    }
}
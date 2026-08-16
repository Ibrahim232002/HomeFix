using HomeFix.API.DTOs.Auth;
using HomeFix.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IJwtService _jwtService;

    public AuthController(
        IAuthService authService,
        IJwtService jwtService)
    {
        _authService = authService;
        _jwtService = jwtService;
    }

    // =========================
    // REGISTER
    // =========================

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        var result = await _authService.RegisterAsync(
            request.FullName,
            request.Email,
            request.PhoneNumber,
            request.Password,
            request.Role);

        if (!result.Success)
        {
            return BadRequest(new
            {
                message = result.Error
            });
        }

        var user = result.User!;

        var accessToken = _jwtService.GenerateAccessToken(user);

        var refreshToken =
            await _authService.CreateRefreshTokenAsync(user);

        return Ok(new AuthResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            Role = user.Role,
            AccessToken = accessToken,
            RefreshToken = refreshToken
        });
    }

    // =========================
    // LOGIN
    // =========================

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var result = await _authService.ValidateLoginAsync(
            request.Email,
            request.Password);

        if (!result.Success)
        {
            return Unauthorized(new
            {
                message = result.Error
            });
        }

        var user = result.User!;

        var accessToken = _jwtService.GenerateAccessToken(user);

        var refreshToken =
            await _authService.CreateRefreshTokenAsync(user);

        return Ok(new AuthResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            Role = user.Role,
            AccessToken = accessToken,
            RefreshToken = refreshToken
        });
    }

    // =========================
    // REFRESH TOKEN
    // =========================

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh(
        RefreshTokenRequest request)
    {
        var result =
            await _authService.ValidateRefreshTokenAsync(
                request.RefreshToken);

        if (!result.Success)
        {
            return Unauthorized(new
            {
                message = result.Error
            });
        }

        var user = result.User!;

        var accessToken =
            _jwtService.GenerateAccessToken(user);

        return Ok(new
        {
            accessToken
        });
    }

    // =========================
    // LOGOUT
    // =========================

    [HttpPost("logout")]
    public async Task<IActionResult> Logout(
        RefreshTokenRequest request)
    {
        var success =
            await _authService.RevokeRefreshTokenAsync(
                request.RefreshToken);

        if (!success)
        {
            return NotFound(new
            {
                message = "Refresh token not found."
            });
        }

        return Ok(new
        {
            message = "Logged out successfully."
        });
    }

    // =========================
    // CURRENT USER
    // =========================

    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {
        var userId =
            User.FindFirstValue(ClaimTypes.NameIdentifier);

        var name =
            User.FindFirstValue(ClaimTypes.Name);

        var email =
            User.FindFirstValue(ClaimTypes.Email);

        var role =
            User.FindFirstValue(ClaimTypes.Role);

        return Ok(new
        {
            userId,
            name,
            email,
            role
        });
    }
}
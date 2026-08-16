using System.Net;
using System.Net.Mail;
using HomeFix.BLL.Interfaces;
using HomeFix.BLL.Models;
using Microsoft.Extensions.Options;

namespace HomeFix.BLL.Services;

public sealed class EmailService : IEmailService
{
    private readonly EmailSettings _settings;

    public EmailService(IOptions<EmailSettings> settings)
    {
        _settings = settings.Value;
    }

    public async Task SendCodeAsync(string email, string code, string purpose)
    {
        ValidateConfiguration();

        var subject = purpose switch
        {
            "EmailVerification" => "HomeFix - Verify your email",
            "PasswordReset" => "HomeFix - Password reset code",
            _ => "HomeFix - Verification code"
        };

        var actionText = purpose switch
        {
            "EmailVerification" => "Use this code to verify your HomeFix email address:",
            "PasswordReset" => "Use this code to reset your HomeFix password:",
            _ => "Use this verification code:"
        };

        var body = $"""
            Hello,

            {actionText}

            {code}

            This code expires in 10 minutes.
            If you did not request this code, you can safely ignore this email.

            HomeFix
            """;

        using var message = new MailMessage
        {
            From = new MailAddress(_settings.From),
            Subject = subject,
            Body = body,
            IsBodyHtml = false
        };
        message.To.Add(new MailAddress(email));

        using var client = new SmtpClient(_settings.Host, _settings.Port)
        {
            EnableSsl = _settings.EnableSsl,
            DeliveryMethod = SmtpDeliveryMethod.Network,
            UseDefaultCredentials = false,
            Credentials = new NetworkCredential(_settings.Username, _settings.Password)
        };

        await client.SendMailAsync(message);
    }

    private void ValidateConfiguration()
    {
        if (string.IsNullOrWhiteSpace(_settings.Host))
            throw new InvalidOperationException("Email SMTP host is not configured.");
        if (_settings.Port <= 0)
            throw new InvalidOperationException("Email SMTP port is not configured correctly.");
        if (string.IsNullOrWhiteSpace(_settings.Username))
            throw new InvalidOperationException("Email SMTP username is not configured.");
        if (string.IsNullOrWhiteSpace(_settings.Password))
            throw new InvalidOperationException("Email SMTP password is not configured.");
        if (string.IsNullOrWhiteSpace(_settings.From))
            throw new InvalidOperationException("Email sender address is not configured.");
    }
}

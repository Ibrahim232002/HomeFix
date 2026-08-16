namespace HomeFix.BLL.Interfaces;

public interface IEmailService
{
    Task SendCodeAsync(string email, string code, string purpose);
}

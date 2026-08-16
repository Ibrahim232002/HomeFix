namespace HomeFix.API.DTOs.UserDevice;

public class RegisterUserDeviceRequest
{
    public string DeviceToken { get; set; } = string.Empty;
    public string Platform { get; set; } = string.Empty;
}

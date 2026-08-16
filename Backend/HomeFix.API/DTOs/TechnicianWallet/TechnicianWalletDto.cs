namespace HomeFix.API.DTOs.TechnicianWallet;

public class TechnicianWalletDto
{
    public int Id { get; set; }

    public int TechnicianId { get; set; }

    public decimal Balance { get; set; }

    public DateTime UpdatedAt { get; set; }
}
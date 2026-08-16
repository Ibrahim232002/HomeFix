namespace HomeFix.API.DTOs.PromoCode;

public class CreatePromoCodeRequest
{
    public string Code { get; set; } = string.Empty;
    public string DiscountType { get; set; } = string.Empty;

    public decimal DiscountValue { get; set; }

    public int? MaxUses { get; set; }

    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}
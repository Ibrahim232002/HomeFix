namespace HomeFix.API.DTOs.UserPromoCode;

public class UserPromoCodeDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int PromoCodeId { get; set; }
    public int ServiceRequestId { get; set; }

    public decimal DiscountAmount { get; set; }
    public DateTime UsedAt { get; set; }
}
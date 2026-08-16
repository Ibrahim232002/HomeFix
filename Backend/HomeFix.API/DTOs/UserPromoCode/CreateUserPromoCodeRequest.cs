namespace HomeFix.API.DTOs.UserPromoCode;

public class CreateUserPromoCodeRequest
{
    public int UserId { get; set; }
    public int PromoCodeId { get; set; }
    public int ServiceRequestId { get; set; }

    public decimal DiscountAmount { get; set; }
}
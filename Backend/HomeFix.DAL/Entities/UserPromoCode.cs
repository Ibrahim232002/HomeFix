using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class UserPromoCode
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int PromoCodeId { get; set; }

    public int ServiceRequestId { get; set; }

    public decimal DiscountAmount { get; set; }

    public DateTime UsedAt { get; set; }

    public virtual PromoCode PromoCode { get; set; } = null!;

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}

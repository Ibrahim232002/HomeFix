using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class PromoCode
{
    public int Id { get; set; }

    public string Code { get; set; } = null!;

    public string DiscountType { get; set; } = null!;

    public decimal DiscountValue { get; set; }

    public int? MaxUses { get; set; }

    public int UsedCount { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public bool IsActive { get; set; }

    public virtual ICollection<UserPromoCode> UserPromoCodes { get; set; } = new List<UserPromoCode>();
}

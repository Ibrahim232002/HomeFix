using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class ServicePricing
{
    public int Id { get; set; }

    public int ServiceId { get; set; }

    public int? CityId { get; set; }

    public decimal VisitFee { get; set; }

    public decimal? MinimumPrice { get; set; }

    public decimal? MaximumPrice { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual City? City { get; set; }

    public virtual Service Service { get; set; } = null!;
}

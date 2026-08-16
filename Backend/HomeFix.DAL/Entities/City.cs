using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class City
{
    public int Id { get; set; }

    public int GovernorateId { get; set; }

    public string Name { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Address> Addresses { get; set; } = new List<Address>();

    public virtual Governorate Governorate { get; set; } = null!;

    public virtual ICollection<ServicePricing> ServicePricings { get; set; } = new List<ServicePricing>();

    public virtual ICollection<TechnicianServiceArea> TechnicianServiceAreas { get; set; } = new List<TechnicianServiceArea>();
}

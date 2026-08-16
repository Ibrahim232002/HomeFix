using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Service
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public string? ImageUrl { get; set; }

    public int? EstimatedDurationMinutes { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<ServicePricing> ServicePricings { get; set; } = new List<ServicePricing>();

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();


    public virtual ICollection<TechnicianProfile> Technicians { get; set; } = new List<TechnicianProfile>();
}

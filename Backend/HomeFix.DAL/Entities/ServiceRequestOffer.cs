using System;

namespace HomeFix.DAL.Entities;

public partial class ServiceRequestOffer
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public int TechnicianId { get; set; }

    public decimal ProposedPrice { get; set; }

    public string? TechnicianNote { get; set; }

    public string Status { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ExpiresAt { get; set; }

    public DateTime? RespondedAt { get; set; }

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

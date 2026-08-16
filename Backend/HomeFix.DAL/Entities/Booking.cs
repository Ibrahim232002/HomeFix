using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Booking
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public int TechnicianId { get; set; }

    public string Status { get; set; } = null!;

    public decimal? AgreedPrice { get; set; }

    public DateTime? AcceptedAt { get; set; }

    public DateTime? ArrivedAt { get; set; }

    public DateTime? StartedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public decimal? FinalPrice { get; set; }

    public string? TechnicianNotes { get; set; }

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    public virtual TechnicianProfile Technician { get; set; } = null!;

    public virtual ICollection<VerificationCode> VerificationCodes { get; set; } = new List<VerificationCode>();
}

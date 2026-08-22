using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Entities;

[Index(nameof(ServiceRequestId), IsUnique = true, Name = "UX_Inspections_ServiceRequest")]
[Index(nameof(TechnicianId), Name = "IX_Inspections_Technician")]
public partial class Inspection
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public int TechnicianId { get; set; }

    [Precision(10, 2)]
    public decimal Fee { get; set; }

    public DateTime ScheduledAt { get; set; }

    [Required]
    [MaxLength(30)]
    public string Status { get; set; } = "Scheduled";

    public string? Findings { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    [ForeignKey(nameof(ServiceRequestId))]
    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    [ForeignKey(nameof(TechnicianId))]
    public virtual TechnicianProfile Technician { get; set; } = null!;

    public virtual ICollection<ServiceQuote> ServiceQuotes { get; set; } = new List<ServiceQuote>();
}

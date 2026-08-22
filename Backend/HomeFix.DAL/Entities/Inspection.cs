using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Entities;

[Index(nameof(ServiceRequestId), IsUnique = true)]
public partial class Inspection
{
    public int Id { get; set; }
    public int ServiceRequestId { get; set; }
    public int TechnicianId { get; set; }
    [Precision(10, 2)]
    public decimal Fee { get; set; }
    public DateTime ScheduledAt { get; set; }
    [MaxLength(30)]
    public string Status { get; set; } = "Scheduled";
    [MaxLength(4000)]
    public string? Findings { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;
    public virtual TechnicianProfile Technician { get; set; } = null!;
    public virtual ICollection<ServiceQuote> ServiceQuotes { get; set; } = new List<ServiceQuote>();
}

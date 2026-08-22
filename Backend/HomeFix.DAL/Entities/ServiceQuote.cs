using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Entities;

[Index(nameof(InspectionId), nameof(Revision), IsUnique = true)]
[Index(nameof(InspectionId), nameof(Status))]
public partial class ServiceQuote
{
    public int Id { get; set; }
    public int InspectionId { get; set; }
    [Precision(10, 2)]
    public decimal Amount { get; set; }
    [MaxLength(30)]
    public string Status { get; set; } = "PendingCustomer";
    [MaxLength(4000)]
    public string? Notes { get; set; }
    public int Revision { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }

    public virtual Inspection Inspection { get; set; } = null!;
}

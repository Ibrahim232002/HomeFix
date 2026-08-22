using System;
using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Entities;

[Index(nameof(InspectionId), nameof(Revision), IsUnique = true, Name = "UX_ServiceQuotes_Inspection_Revision")]
[Index(nameof(InspectionId), nameof(Status), Name = "IX_ServiceQuotes_Inspection_Status")]
public partial class ServiceQuote
{
    public int Id { get; set; }

    public int InspectionId { get; set; }

    [Precision(10, 2)]
    public decimal Amount { get; set; }

    [Required]
    [MaxLength(30)]
    public string Status { get; set; } = "PendingCustomer";

    [MaxLength(2000)]
    public string? Notes { get; set; }

    public int Revision { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? ExpiresAt { get; set; }

    public virtual Inspection Inspection { get; set; } = null!;
}

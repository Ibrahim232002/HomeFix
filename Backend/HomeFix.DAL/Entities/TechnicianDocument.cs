using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class TechnicianDocument
{
    public int Id { get; set; }

    public int TechnicianId { get; set; }

    public string DocumentType { get; set; } = null!;

    public string DocumentUrl { get; set; } = null!;

    public DateTime UploadedAt { get; set; }

    public string Status { get; set; } = null!;

    public string? RejectionReason { get; set; }

    public DateTime? ReviewedAt { get; set; }

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

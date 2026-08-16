using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class ServiceRequestStatusHistory
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public string? OldStatus { get; set; }

    public string NewStatus { get; set; } = null!;

    public int ChangedByUserId { get; set; }

    public DateTime ChangedAt { get; set; }

    public virtual User ChangedByUser { get; set; } = null!;

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;
}

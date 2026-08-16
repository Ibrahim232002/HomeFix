using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Review
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public int CustomerId { get; set; }

    public int TechnicianId { get; set; }

    public int Rating { get; set; }

    public string? Comment { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual CustomerProfile Customer { get; set; } = null!;

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Conversation
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public int CustomerId { get; set; }

    public int TechnicianId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual CustomerProfile Customer { get; set; } = null!;

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

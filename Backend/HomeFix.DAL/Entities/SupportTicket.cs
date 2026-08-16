using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class SupportTicket
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int? ServiceRequestId { get; set; }

    public string Subject { get; set; } = null!;

    public string Description { get; set; } = null!;

    public string Status { get; set; } = null!;

    public string Priority { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual ServiceRequest? ServiceRequest { get; set; }

    public virtual ICollection<SupportMessage> SupportMessages { get; set; } = new List<SupportMessage>();

    public virtual User User { get; set; } = null!;
}

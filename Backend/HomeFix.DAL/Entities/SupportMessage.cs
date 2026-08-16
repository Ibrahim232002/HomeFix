using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class SupportMessage
{
    public int Id { get; set; }

    public int SupportTicketId { get; set; }

    public int SenderId { get; set; }

    public string Message { get; set; } = null!;

    public string? AttachmentUrl { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual User Sender { get; set; } = null!;

    public virtual SupportTicket SupportTicket { get; set; } = null!;
}

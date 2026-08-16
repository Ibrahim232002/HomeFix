using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Message
{
    public int Id { get; set; }

    public int ConversationId { get; set; }

    public int SenderId { get; set; }

    public string? MessageText { get; set; }

    public string? AttachmentUrl { get; set; }

    public string? AttachmentType { get; set; }

    public bool IsRead { get; set; }

    public DateTime SentAt { get; set; }

    public virtual Conversation Conversation { get; set; } = null!;

    public virtual User Sender { get; set; } = null!;
}

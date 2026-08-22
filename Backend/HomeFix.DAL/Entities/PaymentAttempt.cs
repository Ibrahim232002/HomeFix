using System;

namespace HomeFix.DAL.Entities;

public partial class PaymentAttempt
{
    public int Id { get; set; }

    public int PaymentId { get; set; }

    public string Provider { get; set; } = null!;

    public string? ProviderTransactionId { get; set; }

    public decimal Amount { get; set; }

    public string Status { get; set; } = null!;

    public string? FailureReason { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual Payment Payment { get; set; } = null!;
}

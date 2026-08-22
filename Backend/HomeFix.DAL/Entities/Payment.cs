using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Payment
{
    public int Id { get; set; }

    public int ServiceRequestId { get; set; }

    public decimal Amount { get; set; }

    public string PaymentType { get; set; } = null!;

    public string PaymentMethod { get; set; } = null!;

    public string Status { get; set; } = null!;

    public string? TransactionReference { get; set; }

    public string? Provider { get; set; }

    public string? ProviderTransactionId { get; set; }

    public DateTime? PaidAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ServiceRequest ServiceRequest { get; set; } = null!;

    public virtual ICollection<PaymentAttempt> PaymentAttempts { get; set; } = new List<PaymentAttempt>();
}

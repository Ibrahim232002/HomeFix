using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Payout
{
    public int Id { get; set; }

    public int TechnicianId { get; set; }

    public decimal Amount { get; set; }

    public string Status { get; set; } = null!;

    public string PaymentMethod { get; set; } = null!;

    public string? TransactionReference { get; set; }

    public DateTime RequestedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

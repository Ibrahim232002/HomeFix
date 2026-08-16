using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class WalletTransaction
{
    public int Id { get; set; }

    public int WalletId { get; set; }

    public int? ServiceRequestId { get; set; }

    public decimal Amount { get; set; }

    public string TransactionType { get; set; } = null!;

    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ServiceRequest? ServiceRequest { get; set; }

    public virtual TechnicianWallet Wallet { get; set; } = null!;
}

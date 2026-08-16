using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class TechnicianWallet
{
    public int Id { get; set; }

    public int TechnicianId { get; set; }

    public decimal Balance { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual TechnicianProfile Technician { get; set; } = null!;

    public virtual ICollection<WalletTransaction> WalletTransactions { get; set; } = new List<WalletTransaction>();
}

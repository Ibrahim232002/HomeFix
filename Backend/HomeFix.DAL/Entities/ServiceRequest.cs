using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class ServiceRequest
{
    public int Id { get; set; }

    public int CustomerId { get; set; }

    public int ServiceId { get; set; }

    public int AddressId { get; set; }

    public string Description { get; set; } = null!;

    public DateOnly? PreferredDate { get; set; }

    public TimeOnly? PreferredTime { get; set; }

    public string Status { get; set; } = null!;

    public decimal VisitFee { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual Address Address { get; set; } = null!;

    public virtual Booking? Booking { get; set; }

    public virtual Inspection? Inspection { get; set; }

    public virtual Conversation? Conversation { get; set; }

    public virtual CustomerProfile Customer { get; set; } = null!;

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual Review? Review { get; set; }

    public virtual Service Service { get; set; } = null!;

    public virtual ICollection<ServiceRequestOffer> ServiceRequestOffers { get; set; } = new List<ServiceRequestOffer>();

    public virtual ICollection<ServiceRequestFile> ServiceRequestFiles { get; set; } = new List<ServiceRequestFile>();

    public virtual ICollection<ServiceRequestStatusHistory> ServiceRequestStatusHistories { get; set; } = new List<ServiceRequestStatusHistory>();

    public virtual ICollection<SupportTicket> SupportTickets { get; set; } = new List<SupportTicket>();

    public virtual UserPromoCode? UserPromoCode { get; set; }

    public virtual ICollection<WalletTransaction> WalletTransactions { get; set; } = new List<WalletTransaction>();
}

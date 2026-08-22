using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class TechnicianProfile
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public int? CategoryId { get; set; }

    public string? Bio { get; set; }

    public string? ProfileImageUrl { get; set; }

    public int? YearsOfExperience { get; set; }

    public bool IsVerified { get; set; }

    public bool IsAvailable { get; set; }

    public decimal AverageRating { get; set; }

    public int TotalJobs { get; set; }

    public DateTime CreatedAt { get; set; }

    public decimal? CurrentLatitude { get; set; }

    public decimal? CurrentLongitude { get; set; }

    public int? CurrentGovernorateId { get; set; }

    public int? CurrentCityId { get; set; }

    public virtual ServiceCategory? Category { get; set; }

    public virtual Governorate? CurrentGovernorate { get; set; }

    public virtual City? CurrentCity { get; set; }

    public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();

    public virtual ICollection<Conversation> Conversations { get; set; } = new List<Conversation>();

    public virtual ICollection<Inspection> Inspections { get; set; } = new List<Inspection>();

    public virtual ICollection<Payout> Payouts { get; set; } = new List<Payout>();

    public virtual ICollection<ServiceRequestOffer> ServiceRequestOffers { get; set; } = new List<ServiceRequestOffer>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<TechnicianAvailability> TechnicianAvailabilities { get; set; } = new List<TechnicianAvailability>();

    public virtual ICollection<TechnicianDocument> TechnicianDocuments { get; set; } = new List<TechnicianDocument>();

    public virtual ICollection<TechnicianServiceArea> TechnicianServiceAreas { get; set; } = new List<TechnicianServiceArea>();

    public virtual TechnicianWallet? TechnicianWallet { get; set; }

    public virtual User User { get; set; } = null!;

    public virtual ICollection<Service> Services { get; set; } = new List<Service>();
}

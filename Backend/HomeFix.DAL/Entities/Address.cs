using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class Address
{
    public int Id { get; set; }

    public int CustomerId { get; set; }

    public string? Label { get; set; }

    public string FullAddress { get; set; } = null!;

    public decimal? Latitude { get; set; }

    public decimal? Longitude { get; set; }

    public string? BuildingNumber { get; set; }

    public string? FloorNumber { get; set; }

    public string? ApartmentNumber { get; set; }

    public string? AdditionalInstructions { get; set; }

    public bool IsDefault { get; set; }

    public DateTime CreatedAt { get; set; }

    public int? GovernorateId { get; set; }

    public int? CityId { get; set; }

    public virtual City? City { get; set; }

    public virtual CustomerProfile Customer { get; set; } = null!;

    public virtual Governorate? Governorate { get; set; }

    public virtual ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}

using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class ServiceCategory
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public string? ImageUrl { get; set; }

    public string? IconName { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Service> Services { get; set; } = new List<Service>();
}

using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class TechnicianServiceArea
{
    public int TechnicianId { get; set; }

    public int CityId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual City City { get; set; } = null!;

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

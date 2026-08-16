using System;
using System.Collections.Generic;

namespace HomeFix.DAL.Entities;

public partial class TechnicianAvailability
{
    public int Id { get; set; }

    public int TechnicianId { get; set; }

    public byte DayOfWeek { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public bool IsAvailable { get; set; }

    public virtual TechnicianProfile Technician { get; set; } = null!;
}

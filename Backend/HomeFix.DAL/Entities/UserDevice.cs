using System;

namespace HomeFix.DAL.Entities;

public partial class UserDevice
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string DeviceToken { get; set; } = null!;

    public string Platform { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? LastSeenAt { get; set; }

    public virtual User User { get; set; } = null!;
}

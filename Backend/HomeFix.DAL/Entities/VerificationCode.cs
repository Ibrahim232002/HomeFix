using System;

namespace HomeFix.DAL.Entities;

public partial class VerificationCode
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string CodeHash { get; set; } = null!;

    public string Purpose { get; set; } = null!;

    public string Channel { get; set; } = null!;

    public DateTime ExpiresAt { get; set; }

    public DateTime? UsedAt { get; set; }

    public int Attempts { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual User User { get; set; } = null!;
}

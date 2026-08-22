using System;

namespace HomeFix.DAL.Entities;

public partial class ExternalLogin
{
    public int Id { get; set; }

    public int UserId { get; set; }

    public string Provider { get; set; } = null!;

    public string ProviderSubjectId { get; set; } = null!;

    public string? Email { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual User User { get; set; } = null!;
}

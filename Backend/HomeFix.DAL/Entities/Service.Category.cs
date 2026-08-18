namespace HomeFix.DAL.Entities;

public partial class Service
{
    public int CategoryId { get; set; }
    public virtual ServiceCategory Category { get; set; } = null!;
}

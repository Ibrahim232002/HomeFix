using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Data;

public partial class HomeFixDbContext
{
    public virtual DbSet<ServiceCategory> ServiceCategories { get; set; }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ServiceCategory>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Name)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.Description)
                .HasMaxLength(500);

            entity.Property(e => e.ImageUrl)
                .HasMaxLength(500);

            entity.Property(e => e.IconName)
                .HasMaxLength(50);

            entity.Property(e => e.IsActive)
                .HasDefaultValue(true);

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())");

            entity.HasMany(e => e.Services)
                .WithOne(e => e.Category)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("FK_Services_ServiceCategories_CategoryId");
        });

        modelBuilder.Entity<Service>(entity =>
        {
            entity.HasOne(e => e.Category)
                .WithMany(e => e.Services)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("FK_Services_ServiceCategories_CategoryId");
        });
    }
}

using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Data;

public partial class HomeFixDbContext
{
    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TechnicianProfile>(entity =>
        {
            entity.HasOne(d => d.CurrentGovernorate)
                .WithMany()
                .HasForeignKey(d => d.CurrentGovernorateId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianProfiles_CurrentGovernorate");

            entity.HasOne(d => d.CurrentCity)
                .WithMany()
                .HasForeignKey(d => d.CurrentCityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TechnicianProfiles_CurrentCity");
        });
    }
}

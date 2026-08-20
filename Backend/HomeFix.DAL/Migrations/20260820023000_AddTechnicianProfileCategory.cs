using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations;

public partial class AddTechnicianProfileCategory : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<int>(
            name: "CategoryId",
            table: "TechnicianProfiles",
            type: "int",
            nullable: true);

        migrationBuilder.Sql("""
            UPDATE tp
            SET tp.CategoryId = category.CategoryId
            FROM TechnicianProfiles tp
            INNER JOIN (
                SELECT ts.TechnicianId, MIN(s.CategoryId) AS CategoryId
                FROM TechnicianServices ts
                INNER JOIN Services s ON s.Id = ts.ServiceId
                GROUP BY ts.TechnicianId
                HAVING COUNT(DISTINCT s.CategoryId) = 1
            ) category ON category.TechnicianId = tp.Id
            WHERE tp.CategoryId IS NULL;
            """);

        migrationBuilder.CreateIndex(
            name: "IX_TechnicianProfiles_CategoryId",
            table: "TechnicianProfiles",
            column: "CategoryId");

        migrationBuilder.AddForeignKey(
            name: "FK_TechnicianProfiles_ServiceCategories_CategoryId",
            table: "TechnicianProfiles",
            column: "CategoryId",
            principalTable: "ServiceCategories",
            principalColumn: "Id",
            onDelete: ReferentialAction.Restrict);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropForeignKey(
            name: "FK_TechnicianProfiles_ServiceCategories_CategoryId",
            table: "TechnicianProfiles");

        migrationBuilder.DropIndex(
            name: "IX_TechnicianProfiles_CategoryId",
            table: "TechnicianProfiles");

        migrationBuilder.DropColumn(
            name: "CategoryId",
            table: "TechnicianProfiles");
    }
}

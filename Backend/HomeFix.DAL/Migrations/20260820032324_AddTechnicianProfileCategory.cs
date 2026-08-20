using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations
{
    /// <inheritdoc />
    public partial class AddTechnicianProfileCategory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CategoryId",
                table: "TechnicianProfiles",
                type: "int",
                nullable: true);

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

        /// <inheritdoc />
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
}

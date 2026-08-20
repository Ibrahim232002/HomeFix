using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations
{
    /// <inheritdoc />
    public partial class AddTechnicianCurrentLocation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CurrentCityId",
                table: "TechnicianProfiles",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CurrentGovernorateId",
                table: "TechnicianProfiles",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_TechnicianProfiles_CurrentCityId",
                table: "TechnicianProfiles",
                column: "CurrentCityId");

            migrationBuilder.CreateIndex(
                name: "IX_TechnicianProfiles_CurrentGovernorateId",
                table: "TechnicianProfiles",
                column: "CurrentGovernorateId");

            migrationBuilder.AddForeignKey(
                name: "FK_TechnicianProfiles_CurrentCity",
                table: "TechnicianProfiles",
                column: "CurrentCityId",
                principalTable: "Cities",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TechnicianProfiles_CurrentGovernorate",
                table: "TechnicianProfiles",
                column: "CurrentGovernorateId",
                principalTable: "Governorates",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TechnicianProfiles_CurrentCity",
                table: "TechnicianProfiles");

            migrationBuilder.DropForeignKey(
                name: "FK_TechnicianProfiles_CurrentGovernorate",
                table: "TechnicianProfiles");

            migrationBuilder.DropIndex(
                name: "IX_TechnicianProfiles_CurrentCityId",
                table: "TechnicianProfiles");

            migrationBuilder.DropIndex(
                name: "IX_TechnicianProfiles_CurrentGovernorateId",
                table: "TechnicianProfiles");

            migrationBuilder.DropColumn(
                name: "CurrentCityId",
                table: "TechnicianProfiles");

            migrationBuilder.DropColumn(
                name: "CurrentGovernorateId",
                table: "TechnicianProfiles");
        }
    }
}

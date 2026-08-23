using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations
{
    /// <inheritdoc />
    public partial class AddServicePricingModes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PricingMode",
                table: "Services",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "InspectionFee",
                table: "ServicePricing",
                type: "decimal(10,2)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PricingMode",
                table: "Services");

            migrationBuilder.DropColumn(
                name: "InspectionFee",
                table: "ServicePricing");
        }
    }
}

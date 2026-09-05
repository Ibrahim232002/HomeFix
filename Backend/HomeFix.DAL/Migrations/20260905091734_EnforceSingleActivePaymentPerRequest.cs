using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations
{
    /// <inheritdoc />
    public partial class EnforceSingleActivePaymentPerRequest : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Payments_ServiceRequestId",
                table: "Payments");

            migrationBuilder.DropIndex(
                name: "UX_Payments_Paid_ServiceRequestId",
                table: "Payments");

            migrationBuilder.DropIndex(
                name: "UX_Payments_Pending_ServiceRequestId",
                table: "Payments");

            migrationBuilder.CreateIndex(
                name: "UX_Payments_Active_ServiceRequestId",
                table: "Payments",
                column: "ServiceRequestId",
                unique: true,
                filter: "[Status] IN ('Pending', 'Paid')");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UX_Payments_Active_ServiceRequestId",
                table: "Payments");

            migrationBuilder.CreateIndex(
                name: "UX_Payments_Paid_ServiceRequestId",
                table: "Payments",
                column: "ServiceRequestId",
                unique: true,
                filter: "[Status] = 'Paid'");

            migrationBuilder.CreateIndex(
                name: "UX_Payments_Pending_ServiceRequestId",
                table: "Payments",
                column: "ServiceRequestId",
                unique: true,
                filter: "[Status] = 'Pending'");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_ServiceRequestId",
                table: "Payments",
                column: "ServiceRequestId");
        }
    }
}

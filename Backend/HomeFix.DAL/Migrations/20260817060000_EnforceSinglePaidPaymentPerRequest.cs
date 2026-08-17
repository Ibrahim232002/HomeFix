using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using HomeFix.DAL.Data;

#nullable disable

namespace HomeFix.DAL.Migrations;

[DbContext(typeof(HomeFixDbContext))]
[Migration("20260817060000_EnforceSinglePaidPaymentPerRequest")]
public partial class EnforceSinglePaidPaymentPerRequest : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateIndex(
            name: "UX_Payments_Paid_ServiceRequestId",
            table: "Payments",
            column: "ServiceRequestId",
            unique: true,
            filter: "[Status] = 'Paid'");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "UX_Payments_Paid_ServiceRequestId",
            table: "Payments");
    }
}

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
        // Do not automatically rewrite or cancel paid financial records.
        // If duplicate Paid rows already exist, this migration fails safely and
        // requires explicit reconciliation before the constraint is applied.
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

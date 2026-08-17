using Microsoft.EntityFrameworkCore.Migrations;
using HomeFix.DAL.Data;

#nullable disable

namespace HomeFix.DAL.Migrations;

[DbContext(typeof(HomeFixDbContext))]
[Migration("20260817040000_ProductionHardening")]
public partial class ProductionHardening : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Clean up legacy conflicts created before payment idempotency hardening.
        migrationBuilder.Sql("""
            UPDATE pendingPayment
            SET Status = 'Cancelled'
            FROM Payments AS pendingPayment
            WHERE pendingPayment.Status = 'Pending'
              AND EXISTS
              (
                  SELECT 1
                  FROM Payments AS paidPayment
                  WHERE paidPayment.ServiceRequestId = pendingPayment.ServiceRequestId
                    AND paidPayment.Status = 'Paid'
              );
            """);

        // Keep the oldest remaining pending payment for each request; cancel stale duplicates.
        migrationBuilder.Sql("""
            WITH PendingPayments AS
            (
                SELECT Id,
                       ROW_NUMBER() OVER
                       (
                           PARTITION BY ServiceRequestId
                           ORDER BY CreatedAt, Id
                       ) AS RowNumber
                FROM Payments
                WHERE Status = 'Pending'
            )
            UPDATE payment
            SET Status = 'Cancelled'
            FROM Payments AS payment
            INNER JOIN PendingPayments AS ranked
                ON ranked.Id = payment.Id
            WHERE ranked.RowNumber > 1;
            """);

        migrationBuilder.AddCheckConstraint(
            name: "CK_Payments_Amount_Positive",
            table: "Payments",
            sql: "[Amount] > 0");

        migrationBuilder.AddCheckConstraint(
            name: "CK_TechnicianAvailability_DayOfWeek",
            table: "TechnicianAvailability",
            sql: "[DayOfWeek] BETWEEN 0 AND 6");

        migrationBuilder.AddCheckConstraint(
            name: "CK_TechnicianAvailability_TimeRange",
            table: "TechnicianAvailability",
            sql: "[StartTime] < [EndTime]");

        migrationBuilder.CreateIndex(
            name: "UX_Payments_Pending_ServiceRequestId",
            table: "Payments",
            column: "ServiceRequestId",
            unique: true,
            filter: "[Status] = 'Pending'");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "UX_Payments_Pending_ServiceRequestId",
            table: "Payments");

        migrationBuilder.DropCheckConstraint(
            name: "CK_Payments_Amount_Positive",
            table: "Payments");

        migrationBuilder.DropCheckConstraint(
            name: "CK_TechnicianAvailability_DayOfWeek",
            table: "TechnicianAvailability");

        migrationBuilder.DropCheckConstraint(
            name: "CK_TechnicianAvailability_TimeRange",
            table: "TechnicianAvailability");
    }
}
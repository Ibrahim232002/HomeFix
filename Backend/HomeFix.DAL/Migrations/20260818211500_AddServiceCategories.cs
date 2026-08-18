using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations;

public partial class AddServiceCategories : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "ServiceCategories",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false)
                    .Annotation("SqlServer:Identity", "1, 1"),
                Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                IconName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getdate())")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_ServiceCategories", x => x.Id);
            });

        migrationBuilder.AddColumn<int>(
            name: "CategoryId",
            table: "Services",
            type: "int",
            nullable: true);

        migrationBuilder.InsertData(
            table: "ServiceCategories",
            columns: new[] { "Id", "Name", "Description", "ImageUrl", "IconName", "IsActive" },
            values: new object[,]
            {
                { 1, "Electrical", "Electrical home services", null, "Bolt", true },
                { 2, "Plumbing", "Plumbing home services", null, "WaterDrop", true },
                { 3, "Air Conditioning", "Air conditioning home services", null, "AcUnit", true }
            });

        migrationBuilder.Sql("""
            UPDATE [Services]
            SET [CategoryId] = CASE [Name]
                WHEN N'Electrical Repair' THEN 1
                WHEN N'Plumbing Repair' THEN 2
                WHEN N'Air Conditioner Maintenance' THEN 3
                ELSE NULL
            END;

            IF EXISTS (SELECT 1 FROM [Services] WHERE [CategoryId] IS NULL)
                THROW 50001, 'Service category assignment is incomplete. Every existing Service must be mapped before CategoryId becomes required.', 1;
            """);

        migrationBuilder.AlterColumn<int>(
            name: "CategoryId",
            table: "Services",
            type: "int",
            nullable: false,
            oldClrType: typeof(int),
            oldType: "int",
            oldNullable: true);

        migrationBuilder.CreateIndex(
            name: "IX_Services_CategoryId",
            table: "Services",
            column: "CategoryId");

        migrationBuilder.AddForeignKey(
            name: "FK_Services_ServiceCategories_CategoryId",
            table: "Services",
            column: "CategoryId",
            principalTable: "ServiceCategories",
            principalColumn: "Id",
            onDelete: ReferentialAction.Restrict);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropForeignKey(
            name: "FK_Services_ServiceCategories_CategoryId",
            table: "Services");

        migrationBuilder.DropIndex(
            name: "IX_Services_CategoryId",
            table: "Services");

        migrationBuilder.DropColumn(
            name: "CategoryId",
            table: "Services");

        migrationBuilder.DropTable(
            name: "ServiceCategories");
    }
}

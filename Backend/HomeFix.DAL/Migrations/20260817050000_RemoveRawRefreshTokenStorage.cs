using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeFix.DAL.Migrations;

public partial class RemoveRawRefreshTokenStorage : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Preserve existing refresh-token validity while migrating away from plaintext
        // token storage. TokenHash is already populated by current application versions,
        // but this backfill also handles legacy rows safely.
        migrationBuilder.Sql(@"
UPDATE dbo.RefreshTokens
SET TokenHash = CONVERT(varchar(128), HASHBYTES('SHA2_256', Token), 2)
WHERE TokenHash IS NULL OR TokenHash = '';");

        migrationBuilder.DropIndex(
            name: "UQ__RefreshT__1EB4F817A73115DC",
            table: "RefreshTokens");

        migrationBuilder.AlterColumn<string>(
            name: "TokenHash",
            table: "RefreshTokens",
            type: "nvarchar(128)",
            maxLength: 128,
            nullable: false,
            oldClrType: typeof(string),
            oldType: "nvarchar(128)",
            oldMaxLength: 128,
            oldNullable: true);

        migrationBuilder.DropColumn(
            name: "Token",
            table: "RefreshTokens");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "Token",
            table: "RefreshTokens",
            type: "nvarchar(500)",
            maxLength: 500,
            nullable: true);

        migrationBuilder.AlterColumn<string>(
            name: "TokenHash",
            table: "RefreshTokens",
            type: "nvarchar(128)",
            maxLength: 128,
            nullable: true,
            oldClrType: typeof(string),
            oldType: "nvarchar(128)",
            oldMaxLength: 128);

        migrationBuilder.CreateIndex(
            name: "UQ__RefreshT__1EB4F817A73115DC",
            table: "RefreshTokens",
            column: "Token",
            unique: true,
            filter: "[Token] IS NOT NULL");
    }
}

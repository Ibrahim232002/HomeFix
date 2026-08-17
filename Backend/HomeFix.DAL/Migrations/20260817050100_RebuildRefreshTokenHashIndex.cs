using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using HomeFix.DAL.Data;

#nullable disable

namespace HomeFix.DAL.Migrations;

[DbContext(typeof(HomeFixDbContext))]
[Migration("20260817050100_RebuildRefreshTokenHashIndex")]
public partial class RebuildRefreshTokenHashIndex : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateIndex(
            name: "UX_RefreshTokens_TokenHash",
            table: "RefreshTokens",
            column: "TokenHash",
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "UX_RefreshTokens_TokenHash",
            table: "RefreshTokens");
    }
}

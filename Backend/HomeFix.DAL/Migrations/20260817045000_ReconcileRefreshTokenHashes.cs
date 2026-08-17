using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using HomeFix.DAL.Data;

#nullable disable

namespace HomeFix.DAL.Migrations;

[DbContext(typeof(HomeFixDbContext))]
[Migration("20260817045000_ReconcileRefreshTokenHashes")]
public partial class ReconcileRefreshTokenHashes : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // The existing database contains legacy TokenHash values that do not
        // correspond to the raw Token values. Recompute all hashes before the
        // following migration removes the raw Token column.
        migrationBuilder.Sql(@"
UPDATE dbo.RefreshTokens
SET TokenHash = CONVERT(varchar(128), HASHBYTES('SHA2_256', Token), 2)
WHERE Token IS NOT NULL;");

        // Never drop the raw token if any row could not be migrated safely.
        migrationBuilder.Sql(@"
IF EXISTS
(
    SELECT 1
    FROM dbo.RefreshTokens
    WHERE Token IS NULL
       OR TokenHash IS NULL
       OR LTRIM(RTRIM(TokenHash)) = ''
)
    THROW 51000, 'RefreshTokens contains a row that cannot be migrated safely to TokenHash.', 1;");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Data-only reconciliation; intentionally no-op on rollback.
    }
}

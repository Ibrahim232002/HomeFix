using HomeFix.DAL.Data;
using Microsoft.EntityFrameworkCore.Storage;

namespace HomeFix.DAL;

/// <summary>
/// Coordinates persistence for the BLL. Repositories only track changes;
/// the BLL decides when to commit them and when to use a transaction.
/// </summary>
public sealed class UnitOfWork
{
    private readonly HomeFixDbContext _context;

    public UnitOfWork(HomeFixDbContext context)
    {
        _context = context;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);

    public Task<IDbContextTransaction> BeginTransactionAsync(CancellationToken cancellationToken = default)
        => _context.Database.BeginTransactionAsync(cancellationToken);
}

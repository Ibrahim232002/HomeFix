using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class ExternalLoginRepository
{
    private readonly HomeFixDbContext _context;
    public ExternalLoginRepository(HomeFixDbContext context) => _context = context;

    public Task<ExternalLogin?> GetAsync(string provider, string providerSubjectId) =>
        _context.ExternalLogins.Include(x => x.User).FirstOrDefaultAsync(x => x.Provider == provider && x.ProviderSubjectId == providerSubjectId);

    public Task AddAsync(ExternalLogin login) => _context.ExternalLogins.AddAsync(login).AsTask();

    public Task<bool> ExistsForUserAsync(int userId, string provider) =>
        _context.ExternalLogins.AnyAsync(x => x.UserId == userId && x.Provider == provider);
}

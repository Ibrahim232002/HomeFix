using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class CustomerProfileRepository
{
    private readonly HomeFixDbContext _context;

    public CustomerProfileRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<CustomerProfile?> GetByIdAsync(int id)
    {
        return await _context.CustomerProfiles
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<CustomerProfile?> GetByUserIdAsync(int userId)
    {
        return await _context.CustomerProfiles
            .FirstOrDefaultAsync(c => c.UserId == userId);
    }

    public async Task AddAsync(CustomerProfile profile)
    {
        await _context.CustomerProfiles.AddAsync(profile);
    }

    public async Task UpdateAsync(CustomerProfile profile)
    {
        _context.CustomerProfiles.Update(profile);
    }
}
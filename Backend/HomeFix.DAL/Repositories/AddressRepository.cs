using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class AddressRepository
{
    private readonly HomeFixDbContext _context;

    public AddressRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<Address?> GetByIdAsync(int id)
    {
        return await _context.Addresses
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task<List<Address>> GetByCustomerIdAsync(int customerId)
    {
        return await _context.Addresses
            .Where(a => a.CustomerId == customerId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(Address address)
    {
        await _context.Addresses.AddAsync(address);
    }

    public async Task UpdateAsync(Address address)
    {
        _context.Addresses.Update(address);
    }

    public async Task DeleteAsync(Address address)
    {
        _context.Addresses.Remove(address);
    }
}
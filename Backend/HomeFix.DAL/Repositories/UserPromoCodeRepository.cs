using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class UserPromoCodeRepository
{
    private readonly HomeFixDbContext _context;

    public UserPromoCodeRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<UserPromoCode?> GetByIdAsync(int id)
    {
        return await _context.UserPromoCodes
            .Include(x => x.PromoCode)
            .FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<UserPromoCode?> GetByRequestIdAsync(int serviceRequestId)
    {
        return await _context.UserPromoCodes
            .Include(x => x.PromoCode)
            .FirstOrDefaultAsync(x => x.ServiceRequestId == serviceRequestId);
    }

    public async Task AddAsync(UserPromoCode userPromoCode)
    {
        await _context.UserPromoCodes.AddAsync(userPromoCode);
    }
}
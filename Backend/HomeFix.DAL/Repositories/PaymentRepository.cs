using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class PaymentRepository
{
    private readonly HomeFixDbContext _context;

    public PaymentRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<Payment?> GetByIdAsync(int id)
    {
        return await _context.Payments
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<List<Payment>> GetByRequestIdAsync(int serviceRequestId)
    {
        return await _context.Payments
            .Where(p => p.ServiceRequestId == serviceRequestId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task AddAsync(Payment payment)
    {
        await _context.Payments.AddAsync(payment);
    }

    public async Task UpdateAsync(Payment payment)
    {
        _context.Payments.Update(payment);
    }
}
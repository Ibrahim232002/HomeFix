using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class PaymentAttemptRepository
{
    private readonly HomeFixDbContext _context;
    public PaymentAttemptRepository(HomeFixDbContext context) => _context = context;
    public Task<PaymentAttempt?> GetByProviderTransactionIdAsync(string providerTransactionId) => _context.PaymentAttempts.FirstOrDefaultAsync(x => x.ProviderTransactionId == providerTransactionId);
    public Task<List<PaymentAttempt>> GetByPaymentIdAsync(int paymentId) => _context.PaymentAttempts.Where(x => x.PaymentId == paymentId).OrderByDescending(x => x.CreatedAt).ToListAsync();
    public Task AddAsync(PaymentAttempt attempt) => _context.PaymentAttempts.AddAsync(attempt).AsTask();
    public void Update(PaymentAttempt attempt) => _context.PaymentAttempts.Update(attempt);
}

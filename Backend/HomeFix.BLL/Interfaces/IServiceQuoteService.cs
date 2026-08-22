using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IServiceQuoteService
{
    Task<ServiceQuote?> GetByIdAsync(int id);
    Task<List<ServiceQuote>> GetByInspectionIdAsync(int inspectionId);
    Task<(bool Success, string? Error, ServiceQuote? Quote)> CreateAsync(int inspectionId, int technicianId, decimal amount, string? notes, DateTime? expiresAt);
    Task<(bool Success, string? Error, ServiceQuote? Quote)> CreateRevisionAsync(int quoteId, int technicianId, decimal amount, string? notes, DateTime? expiresAt);
    Task<(bool Success, string? Error)> AcceptAsync(int quoteId, int customerUserId);
    Task<(bool Success, string? Error)> RejectAsync(int quoteId, int customerUserId);
}

using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ISupportTicketService
{
    Task<SupportTicket?> GetByIdAsync(int id);
    Task<List<SupportTicket>> GetByUserIdAsync(int userId);
    Task<List<SupportTicket>> GetByStatusAsync(string status);
    Task AddAsync(SupportTicket ticket);
    Task UpdateAsync(SupportTicket ticket);
}
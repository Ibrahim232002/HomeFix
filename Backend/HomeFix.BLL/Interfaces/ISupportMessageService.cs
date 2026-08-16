using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ISupportMessageService
{
    Task<List<SupportMessage>> GetByTicketIdAsync(int supportTicketId);
    Task AddAsync(SupportMessage message);
}
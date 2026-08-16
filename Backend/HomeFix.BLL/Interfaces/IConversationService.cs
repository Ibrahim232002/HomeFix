using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IConversationService
{
    Task<Conversation?> GetByIdAsync(int id);
    Task<Conversation?> GetByRequestIdAsync(int serviceRequestId);
    Task<List<Conversation>> GetByCustomerIdAsync(int customerId);
    Task<List<Conversation>> GetByTechnicianIdAsync(int technicianId);
    Task AddAsync(Conversation conversation);
}
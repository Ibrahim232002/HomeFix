using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IMessageService
{
    Task<Message?> GetByIdAsync(int id);
    Task<List<Message>> GetByConversationIdAsync(int conversationId);
    Task AddAsync(Message message);
}
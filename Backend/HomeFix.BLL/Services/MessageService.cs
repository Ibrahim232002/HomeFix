using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class MessageService : IMessageService
{
    private readonly MessageRepository _repository;

    public MessageService(MessageRepository repository)
    {
        _repository = repository;
    }

    public Task<Message?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Message>> GetByConversationIdAsync(int conversationId)
        => _repository.GetByConversationIdAsync(conversationId);

    public Task AddAsync(Message message)
        => _repository.AddAsync(message);
}
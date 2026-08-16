using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class MessageService : IMessageService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly MessageRepository _repository;

    public MessageService(MessageRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<Message?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<Message>> GetByConversationIdAsync(int conversationId)
        => _repository.GetByConversationIdAsync(conversationId);

    public async Task AddAsync(Message message)
        {
        await _repository.AddAsync(message);
        await _unitOfWork.SaveChangesAsync();
    }
}

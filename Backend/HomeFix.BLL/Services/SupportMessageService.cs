using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class SupportMessageService : ISupportMessageService
{
    private readonly SupportMessageRepository _repository;

    public SupportMessageService(SupportMessageRepository repository)
    {
        _repository = repository;
    }

    public Task<List<SupportMessage>> GetByTicketIdAsync(int supportTicketId)
        => _repository.GetByTicketIdAsync(supportTicketId);

    public Task AddAsync(SupportMessage message)
        => _repository.AddAsync(message);
}
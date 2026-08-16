using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class SupportMessageService : ISupportMessageService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly SupportMessageRepository _repository;

    public SupportMessageService(SupportMessageRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<List<SupportMessage>> GetByTicketIdAsync(int supportTicketId)
        => _repository.GetByTicketIdAsync(supportTicketId);

    public async Task AddAsync(SupportMessage message)
        {
        await _repository.AddAsync(message);
        await _unitOfWork.SaveChangesAsync();
    }
}

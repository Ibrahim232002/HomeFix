using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class SupportTicketService : ISupportTicketService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly SupportTicketRepository _repository;

    public SupportTicketService(SupportTicketRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<SupportTicket?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<SupportTicket>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<List<SupportTicket>> GetByStatusAsync(string status)
        => _repository.GetByStatusAsync(status);

    public async Task AddAsync(SupportTicket ticket)
        {
        await _repository.AddAsync(ticket);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(SupportTicket ticket)
        {
        await _repository.UpdateAsync(ticket);
        await _unitOfWork.SaveChangesAsync();
    }
}

using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class SupportTicketService : ISupportTicketService
{
    private readonly SupportTicketRepository _repository;

    public SupportTicketService(SupportTicketRepository repository)
    {
        _repository = repository;
    }

    public Task<SupportTicket?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<SupportTicket>> GetByUserIdAsync(int userId)
        => _repository.GetByUserIdAsync(userId);

    public Task<List<SupportTicket>> GetByStatusAsync(string status)
        => _repository.GetByStatusAsync(status);

    public Task AddAsync(SupportTicket ticket)
        => _repository.AddAsync(ticket);

    public Task UpdateAsync(SupportTicket ticket)
        => _repository.UpdateAsync(ticket);
}
using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ConversationService : IConversationService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly ConversationRepository _repository;

    public ConversationService(ConversationRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<Conversation?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<Conversation?> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public Task<List<Conversation>> GetByCustomerIdAsync(int customerId)
        => _repository.GetByCustomerIdAsync(customerId);

    public Task<List<Conversation>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task AddAsync(Conversation conversation)
        {
        await _repository.AddAsync(conversation);
        await _unitOfWork.SaveChangesAsync();
    }
}

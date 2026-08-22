using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianDocumentService : ITechnicianDocumentService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly TechnicianDocumentRepository _repository;

    public TechnicianDocumentService(TechnicianDocumentRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<TechnicianDocument?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<TechnicianDocument>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task<List<TechnicianDocument>> GetPendingAsync()
        => _repository.GetPendingAsync();

    public async Task AddAsync(TechnicianDocument document)
        {
        await _repository.AddAsync(document);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(TechnicianDocument document)
        {
        await _repository.UpdateAsync(document);
        await _unitOfWork.SaveChangesAsync();
    }
}

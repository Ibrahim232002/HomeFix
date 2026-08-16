using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class TechnicianDocumentService : ITechnicianDocumentService
{
    private readonly TechnicianDocumentRepository _repository;

    public TechnicianDocumentService(TechnicianDocumentRepository repository)
    {
        _repository = repository;
    }

    public Task<TechnicianDocument?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<List<TechnicianDocument>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public Task<List<TechnicianDocument>> GetPendingAsync()
        => _repository.GetPendingAsync();

    public Task AddAsync(TechnicianDocument document)
        => _repository.AddAsync(document);

    public Task UpdateAsync(TechnicianDocument document)
        => _repository.UpdateAsync(document);
}
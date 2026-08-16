using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface ITechnicianDocumentService
{
    Task<TechnicianDocument?> GetByIdAsync(int id);
    Task<List<TechnicianDocument>> GetByTechnicianIdAsync(int technicianId);
    Task<List<TechnicianDocument>> GetPendingAsync();
    Task AddAsync(TechnicianDocument document);
    Task UpdateAsync(TechnicianDocument document);
}
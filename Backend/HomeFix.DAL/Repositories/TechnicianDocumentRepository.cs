using HomeFix.DAL.Data;
using HomeFix.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.DAL.Repositories;

public class TechnicianDocumentRepository
{
    private readonly HomeFixDbContext _context;

    public TechnicianDocumentRepository(HomeFixDbContext context)
    {
        _context = context;
    }

    public async Task<TechnicianDocument?> GetByIdAsync(int id)
    {
        return await _context.TechnicianDocuments
            .FirstOrDefaultAsync(d => d.Id == id);
    }

    public async Task<List<TechnicianDocument>> GetByTechnicianIdAsync(int technicianId)
    {
        return await _context.TechnicianDocuments
            .Where(d => d.TechnicianId == technicianId)
            .OrderByDescending(d => d.UploadedAt)
            .ToListAsync();
    }

    public async Task<List<TechnicianDocument>> GetPendingAsync()
    {
        return await _context.TechnicianDocuments
            .Where(d => d.Status == "Pending")
            .OrderBy(d => d.UploadedAt)
            .ToListAsync();
    }

    public async Task AddAsync(TechnicianDocument document)
    {
        await _context.TechnicianDocuments.AddAsync(document);
    }

    public async Task UpdateAsync(TechnicianDocument document)
    {
        _context.TechnicianDocuments.Update(document);
    }
}
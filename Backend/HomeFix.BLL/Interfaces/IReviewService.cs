using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IReviewService
{
    Task<Review?> GetByIdAsync(int id);
    Task<Review?> GetByRequestIdAsync(int serviceRequestId);
    Task<List<Review>> GetByTechnicianIdAsync(int technicianId);
    Task AddAsync(Review review);
}
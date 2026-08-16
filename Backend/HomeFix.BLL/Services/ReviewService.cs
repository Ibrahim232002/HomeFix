using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class ReviewService : IReviewService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly ReviewRepository _repository;

    public ReviewService(ReviewRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<Review?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<Review?> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public Task<List<Review>> GetByTechnicianIdAsync(int technicianId)
        => _repository.GetByTechnicianIdAsync(technicianId);

    public async Task AddAsync(Review review)
        {
        await _repository.AddAsync(review);
        await _unitOfWork.SaveChangesAsync();
    }
}

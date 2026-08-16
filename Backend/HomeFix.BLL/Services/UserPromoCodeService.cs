using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class UserPromoCodeService : IUserPromoCodeService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly UserPromoCodeRepository _repository;

    public UserPromoCodeService(UserPromoCodeRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<UserPromoCode?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<UserPromoCode?> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public async Task AddAsync(UserPromoCode userPromoCode)
        {
        await _repository.AddAsync(userPromoCode);
        await _unitOfWork.SaveChangesAsync();
    }
}

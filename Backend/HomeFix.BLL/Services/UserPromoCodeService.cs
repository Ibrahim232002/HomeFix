using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class UserPromoCodeService : IUserPromoCodeService
{
    private readonly UserPromoCodeRepository _repository;

    public UserPromoCodeService(UserPromoCodeRepository repository)
    {
        _repository = repository;
    }

    public Task<UserPromoCode?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<UserPromoCode?> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public Task AddAsync(UserPromoCode userPromoCode)
        => _repository.AddAsync(userPromoCode);
}
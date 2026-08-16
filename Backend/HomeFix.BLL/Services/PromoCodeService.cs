using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PromoCodeService : IPromoCodeService
{
    private readonly PromoCodeRepository _repository;

    public PromoCodeService(PromoCodeRepository repository)
    {
        _repository = repository;
    }

    public Task<PromoCode?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<PromoCode?> GetByCodeAsync(string code)
        => _repository.GetByCodeAsync(code);

    public Task<List<PromoCode>> GetActiveAsync()
        => _repository.GetActiveAsync();

    public Task AddAsync(PromoCode promoCode)
        => _repository.AddAsync(promoCode);

    public Task UpdateAsync(PromoCode promoCode)
        => _repository.UpdateAsync(promoCode);
}
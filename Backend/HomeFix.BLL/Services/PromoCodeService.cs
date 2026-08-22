using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class PromoCodeService : IPromoCodeService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly PromoCodeRepository _repository;

    public PromoCodeService(PromoCodeRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<PromoCode?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<PromoCode?> GetByCodeAsync(string code)
        => _repository.GetByCodeAsync(code);

    public Task<List<PromoCode>> GetActiveAsync()
        => _repository.GetActiveAsync();

    public async Task AddAsync(PromoCode promoCode)
        {
        await _repository.AddAsync(promoCode);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(PromoCode promoCode)
        {
        await _repository.UpdateAsync(promoCode);
        await _unitOfWork.SaveChangesAsync();
    }
}

using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IPromoCodeService
{
    Task<PromoCode?> GetByIdAsync(int id);
    Task<PromoCode?> GetByCodeAsync(string code);
    Task<List<PromoCode>> GetActiveAsync();
    Task AddAsync(PromoCode promoCode);
    Task UpdateAsync(PromoCode promoCode);
}
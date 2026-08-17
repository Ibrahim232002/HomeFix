using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IUserPromoCodeService
{
    Task<UserPromoCode?> GetByIdAsync(int id);
    Task<UserPromoCode?> GetByRequestIdAsync(int serviceRequestId);
    Task<(bool Success, string? Error, UserPromoCode? UserPromoCode)> ApplyAsync(
        int userId,
        int serviceRequestId,
        int promoCodeId);
    Task AddAsync(UserPromoCode userPromoCode);
}
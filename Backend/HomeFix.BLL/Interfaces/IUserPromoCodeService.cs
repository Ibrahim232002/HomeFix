using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Interfaces;

public interface IUserPromoCodeService
{
    Task<UserPromoCode?> GetByIdAsync(int id);
    Task<UserPromoCode?> GetByRequestIdAsync(int serviceRequestId);
    Task AddAsync(UserPromoCode userPromoCode);
}
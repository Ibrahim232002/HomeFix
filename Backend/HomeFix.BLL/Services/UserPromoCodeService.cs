using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;
using Microsoft.EntityFrameworkCore;

namespace HomeFix.BLL.Services;

public class UserPromoCodeService : IUserPromoCodeService
{
    private readonly UnitOfWork _unitOfWork;
    private readonly UserPromoCodeRepository _repository;
    private readonly ServiceRequestRepository _requestRepository;
    private readonly PromoCodeRepository _promoCodeRepository;

    public UserPromoCodeService(
        UserPromoCodeRepository repository,
        ServiceRequestRepository requestRepository,
        PromoCodeRepository promoCodeRepository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
        _requestRepository = requestRepository;
        _promoCodeRepository = promoCodeRepository;
        }

    public Task<UserPromoCode?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<UserPromoCode?> GetByRequestIdAsync(int serviceRequestId)
        => _repository.GetByRequestIdAsync(serviceRequestId);

    public async Task<(bool Success, string? Error, UserPromoCode? UserPromoCode)> ApplyAsync(
        int userId,
        int serviceRequestId,
        int promoCodeId)
    {
        var request = await _requestRepository.GetByIdAsync(serviceRequestId);
        if (request is null)
            return (false, "Service request not found.", null);
        if (request.CustomerId <= 0 || request.Customer?.UserId != userId)
            return (false, "Service request not found.", null);

        var existing = await _repository.GetByRequestIdAsync(serviceRequestId);
        if (existing is not null)
            return (false, "A promo code has already been applied to this service request.", null);

        var promo = await _promoCodeRepository.GetByIdAsync(promoCodeId);
        if (promo is null)
            return (false, "Invalid or inactive promo code.", null);

        var now = DateTime.UtcNow;
        if (!promo.IsActive || now < promo.StartDate || now > promo.EndDate)
            return (false, "Promo code is outside its validity period.", null);

        if (request.VisitFee < 0)
            return (false, "The service request has an invalid visit fee.", null);

        decimal discountAmount = promo.DiscountType switch
        {
            var type when type.Equals("Percentage", StringComparison.OrdinalIgnoreCase)
                => request.VisitFee * (promo.DiscountValue / 100m),
            var type when type.Equals("Fixed", StringComparison.OrdinalIgnoreCase)
                => promo.DiscountValue,
            _ => -1m
        };

        if (discountAmount < 0)
            return (false, "Unsupported promo code discount type.", null);

        discountAmount = Math.Clamp(discountAmount, 0m, request.VisitFee);

        await using var tx = await _unitOfWork.BeginTransactionAsync(System.Data.IsolationLevel.Serializable);
        try
        {
            if (await _repository.GetByRequestIdAsync(serviceRequestId) is not null)
            {
                await tx.RollbackAsync();
                return (false, "A promo code has already been applied to this service request.", null);
            }

            var reserved = await _promoCodeRepository.TryReserveUseAsync(promo.Id, now);
            if (reserved != 1)
            {
                await tx.RollbackAsync();
                return (false, "Promo code usage limit has been reached or the code is no longer active.", null);
            }

            var userPromoCode = new UserPromoCode
            {
                UserId = userId,
                PromoCodeId = promo.Id,
                ServiceRequestId = request.Id,
                DiscountAmount = discountAmount,
                UsedAt = now
            };

            await _repository.AddAsync(userPromoCode);
            await _unitOfWork.SaveChangesAsync();
            await tx.CommitAsync();

            return (true, null, userPromoCode);
        }
        catch (DbUpdateException)
        {
            await tx.RollbackAsync();
            var raced = await _repository.GetByRequestIdAsync(serviceRequestId);
            if (raced is not null)
                return (false, "A promo code has already been applied to this service request.", null);
            throw;
        }
        catch
        {
            await tx.RollbackAsync();
            throw;
        }
    }

    public async Task AddAsync(UserPromoCode userPromoCode)
    {
        await _repository.AddAsync(userPromoCode);
        await _unitOfWork.SaveChangesAsync();
    }
}
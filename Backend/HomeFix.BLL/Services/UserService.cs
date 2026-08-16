using HomeFix.DAL;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class UserService : IUserService
{
    private readonly UnitOfWork _unitOfWork;

    private readonly UserRepository _repository;

    public UserService(UserRepository repository,
        UnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
        _repository = repository;
    }

    public Task<User?> GetByIdAsync(int id)
        => _repository.GetByIdAsync(id);

    public Task<User?> GetByEmailAsync(string email)
        => _repository.GetByEmailAsync(email);

    public Task<User?> GetByPhoneAsync(string phoneNumber)
        => _repository.GetByPhoneAsync(phoneNumber);

    public Task<bool> EmailExistsAsync(string email)
        => _repository.EmailExistsAsync(email);

    public Task<bool> PhoneExistsAsync(string phoneNumber)
        => _repository.PhoneExistsAsync(phoneNumber);

    public async Task AddAsync(User user)
        {
        await _repository.AddAsync(user);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task UpdateAsync(User user)
        {
        await _repository.UpdateAsync(user);
        await _unitOfWork.SaveChangesAsync();
    }

    public async Task DeleteAsync(User user)
        {
        await _repository.DeleteAsync(user);
        await _unitOfWork.SaveChangesAsync();
    }
}

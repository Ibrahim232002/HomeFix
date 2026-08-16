using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using HomeFix.DAL.Repositories;

namespace HomeFix.BLL.Services;

public class UserService : IUserService
{
    private readonly UserRepository _repository;

    public UserService(UserRepository repository)
    {
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

    public Task AddAsync(User user)
        => _repository.AddAsync(user);

    public Task UpdateAsync(User user)
        => _repository.UpdateAsync(user);

    public Task DeleteAsync(User user)
        => _repository.DeleteAsync(user);
}
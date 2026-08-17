using System.Security.Cryptography;
using HomeFix.BLL.Interfaces;

namespace HomeFix.BLL.Services;

public class PasswordHasher : IPasswordHasher
{
    private const int LegacyIterations = 100_000;
    private const int CurrentIterations = 600_000;
    private const int SaltSize = 16;
    private const int HashSize = 32;

    public string Hash(string password)
    {
        ArgumentNullException.ThrowIfNull(password);

        byte[] salt = RandomNumberGenerator.GetBytes(SaltSize);
        byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
            password,
            salt,
            CurrentIterations,
            HashAlgorithmName.SHA256,
            HashSize);

        return $"v2.{CurrentIterations}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    public bool Verify(string password, string passwordHash)
    {
        ArgumentNullException.ThrowIfNull(password);
        ArgumentNullException.ThrowIfNull(passwordHash);

        var parts = passwordHash.Split('.');
        try
        {
            if (parts.Length == 4 && parts[0] == "v2" && int.TryParse(parts[1], out var iterations))
            {
                var salt = Convert.FromBase64String(parts[2]);
                var storedHash = Convert.FromBase64String(parts[3]);
                var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, iterations, HashAlgorithmName.SHA256, storedHash.Length);
                return CryptographicOperations.FixedTimeEquals(hash, storedHash);
            }

            // Backward-compatible verification for existing hashes created before
            // the versioned format was introduced.
            if (parts.Length == 2)
            {
                var salt = Convert.FromBase64String(parts[0]);
                var storedHash = Convert.FromBase64String(parts[1]);
                var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, LegacyIterations, HashAlgorithmName.SHA256, storedHash.Length);
                return CryptographicOperations.FixedTimeEquals(hash, storedHash);
            }
        }
        catch (FormatException)
        {
            return false;
        }

        return false;
    }

    public bool NeedsRehash(string passwordHash)
        => !passwordHash.StartsWith($"v2.{CurrentIterations}.", StringComparison.Ordinal);
}

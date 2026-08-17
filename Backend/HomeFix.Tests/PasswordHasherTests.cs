using HomeFix.BLL.Services;

namespace HomeFix.Tests;

public class PasswordHasherTests
{
    [Fact]
    public void Hash_ProducesVersionedCurrentFormat()
    {
        var hasher = new PasswordHasher();
        var hash = hasher.Hash("StrongPassword123!");

        Assert.StartsWith("v2.600000.", hash);
        Assert.True(hasher.Verify("StrongPassword123!", hash));
        Assert.False(hasher.Verify("WrongPassword", hash));
        Assert.False(hasher.NeedsRehash(hash));
    }

    [Fact]
    public void LegacyHash_RemainsVerifiableAndNeedsRehash()
    {
        var hasher = new PasswordHasher();
        const string password = "LegacyPassword123!";
        var legacyHash = CreateLegacyHash(password);

        Assert.True(hasher.Verify(password, legacyHash));
        Assert.False(hasher.Verify("WrongPassword", legacyHash));
        Assert.True(hasher.NeedsRehash(legacyHash));
    }

    private static string CreateLegacyHash(string password)
    {
        var salt = System.Security.Cryptography.RandomNumberGenerator.GetBytes(16);
        var hash = System.Security.Cryptography.Rfc2898DeriveBytes.Pbkdf2(
            password,
            salt,
            100_000,
            System.Security.Cryptography.HashAlgorithmName.SHA256,
            32);

        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }
}

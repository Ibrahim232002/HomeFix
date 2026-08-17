using HomeFix.BLL.Services;
using HomeFix.DAL.Entities;
using Xunit;

namespace HomeFix.Tests;

public class PaymentRulesTests
{
    [Fact]
    public void PaidPayment_IsActiveConflict()
    {
        var payments = new[]
        {
            new Payment { Id = 10, Status = "Paid", PaymentMethod = "Card" }
        };

        Assert.True(PaymentRules.HasActiveConflict(payments));
    }

    [Fact]
    public void PendingCash_IsReturnedForIdempotentCashRequest()
    {
        var pendingCash = new Payment { Id = 12, Status = "Pending", PaymentMethod = "Cash" };
        var payments = new[] { pendingCash };

        Assert.Same(pendingCash, PaymentRules.FindPendingCash(payments));
    }

    [Fact]
    public void ExcludedPayment_DoesNotConflictWithItself()
    {
        var payment = new Payment { Id = 7, Status = "Pending", PaymentMethod = "Cash" };

        Assert.False(PaymentRules.HasActiveConflict(new[] { payment }, excludedPaymentId: 7));
    }

    [Fact]
    public void SecondPaymentAttempt_IsBlockedWhenFirstAttemptIsActive()
    {
        var firstAttempt = new Payment { Id = 20, Status = "Pending", PaymentMethod = "Cash" };

        // The payment service executes this invariant inside a Serializable transaction.
        Assert.True(PaymentRules.HasActiveConflict(new[] { firstAttempt }));
    }

    [Theory]
    [InlineData("Pending", "Paid", true)]
    [InlineData("Pending", "Cancelled", true)]
    [InlineData("Paid", "Pending", false)]
    [InlineData("Failed", "Paid", false)]
    [InlineData("Cancelled", "Pending", false)]
    public void PaymentStatusTransition_IsValidated(string current, string next, bool expected)
    {
        Assert.Equal(expected, PaymentRules.IsAllowedStatusTransition(current, next));
    }
}
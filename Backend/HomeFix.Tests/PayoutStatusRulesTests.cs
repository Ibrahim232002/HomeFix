using HomeFix.BLL.Services;
using Xunit;

namespace HomeFix.Tests;

public class PayoutStatusRulesTests
{
    [Theory]
    [InlineData("Pending", "Pending", true)]
    [InlineData("Pending", "Completed", true)]
    [InlineData("Pending", "Failed", true)]
    [InlineData("Pending", "Cancelled", true)]
    [InlineData("Completed", "Completed", true)]
    [InlineData("Failed", "Failed", true)]
    [InlineData("Cancelled", "Cancelled", true)]
    [InlineData("Completed", "Pending", false)]
    [InlineData("Completed", "Failed", false)]
    [InlineData("Completed", "Cancelled", false)]
    [InlineData("Failed", "Pending", false)]
    [InlineData("Failed", "Completed", false)]
    [InlineData("Failed", "Cancelled", false)]
    [InlineData("Cancelled", "Pending", false)]
    [InlineData("Cancelled", "Completed", false)]
    [InlineData("Cancelled", "Failed", false)]
    [InlineData("Pending", "Unknown", false)]
    public void PayoutStatusTransition_IsAllowedOnlyByStateMachine(string current, string next, bool expected)
    {
        Assert.Equal(expected, PayoutStatusRules.IsAllowedStatusTransition(
            PayoutStatusRules.Normalize(current),
            PayoutStatusRules.Normalize(next)));
    }

    [Theory]
    [InlineData("Pending", "Failed", true)]
    [InlineData("Pending", "Cancelled", true)]
    [InlineData("Pending", "Completed", false)]
    [InlineData("Pending", "Pending", false)]
    [InlineData("Failed", "Failed", false)]
    [InlineData("Cancelled", "Cancelled", false)]
    [InlineData("Failed", "Cancelled", false)]
    [InlineData("Cancelled", "Failed", false)]
    public void PayoutRefund_IsOnlyForPendingToTerminalFailure(string current, string next, bool expected)
    {
        Assert.Equal(expected, PayoutStatusRules.ShouldRefund(
            PayoutStatusRules.Normalize(current),
            PayoutStatusRules.Normalize(next)));
    }

    [Fact]
    public void FailedToFailed_IsIdempotentAndDoesNotRefund()
    {
        var current = PayoutStatusRules.Normalize("Pending");
        var refunds = 0;

        Assert.True(PayoutStatusRules.IsAllowedStatusTransition(current, "Failed"));
        if (PayoutStatusRules.ShouldRefund(current, "Failed")) refunds++;
        current = "Failed";

        Assert.True(PayoutStatusRules.IsAllowedStatusTransition(current, "Failed"));
        if (PayoutStatusRules.ShouldRefund(current, "Failed")) refunds++;

        Assert.Equal("Failed", current);
        Assert.Equal(1, refunds);
    }

    [Fact]
    public void CancelledToCancelled_IsIdempotentAndDoesNotRefund()
    {
        var current = PayoutStatusRules.Normalize("Pending");
        var refunds = 0;

        Assert.True(PayoutStatusRules.IsAllowedStatusTransition(current, "Cancelled"));
        if (PayoutStatusRules.ShouldRefund(current, "Cancelled")) refunds++;
        current = "Cancelled";

        Assert.True(PayoutStatusRules.IsAllowedStatusTransition(current, "Cancelled"));
        if (PayoutStatusRules.ShouldRefund(current, "Cancelled")) refunds++;

        Assert.Equal("Cancelled", current);
        Assert.Equal(1, refunds);
    }

    [Fact]
    public void TerminalStateCannotReturnToPending()
    {
        Assert.False(PayoutStatusRules.IsAllowedStatusTransition("Failed", "Pending"));
        Assert.False(PayoutStatusRules.IsAllowedStatusTransition("Cancelled", "Pending"));
    }

    [Fact]
    public void SerializedConcurrentTerminalUpdates_CanRefundOnlyOnce()
    {
        var current = "Pending";
        var refunds = 0;
        var gate = new object();

        Parallel.For(0, 2, _ =>
        {
            lock (gate)
            {
                const string next = "Failed";
                if (!PayoutStatusRules.IsAllowedStatusTransition(current, next))
                    return;

                if (PayoutStatusRules.ShouldRefund(current, next))
                    refunds++;

                current = next;
            }
        });

        Assert.Equal("Failed", current);
        Assert.Equal(1, refunds);
    }
}

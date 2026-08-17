using HomeFix.BLL.Services;
using Xunit;

namespace HomeFix.Tests;

public class PaymentAmountCalculatorTests
{
    [Fact]
    public void NormalPaymentWithoutPromo_UsesFullBookingAmount()
    {
        Assert.Equal(500m, PaymentAmountCalculator.Calculate(500m, null));
    }

    [Fact]
    public void ValidPromo_SubtractsAuthoritativeDiscount()
    {
        Assert.Equal(425m, PaymentAmountCalculator.Calculate(500m, 75m));
    }

    [Fact]
    public void DiscountLargerThanPrice_IsClampedToZero()
    {
        Assert.Equal(0m, PaymentAmountCalculator.Calculate(500m, 800m));
    }

    [Fact]
    public void NegativeDiscount_IsIgnored()
    {
        Assert.Equal(500m, PaymentAmountCalculator.Calculate(500m, -25m));
    }
}
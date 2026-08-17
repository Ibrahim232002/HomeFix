namespace HomeFix.BLL.Services;

public static class PaymentAmountCalculator
{
    public static decimal Calculate(decimal baseAmount, decimal? discountAmount)
    {
        if (baseAmount <= 0)
            throw new ArgumentOutOfRangeException(nameof(baseAmount), "Base amount must be greater than zero.");

        var discount = Math.Clamp(discountAmount ?? 0m, 0m, baseAmount);
        return baseAmount - discount;
    }
}
using HomeFix.DAL.Entities;

namespace HomeFix.BLL.Services;

public static class PaymentRules
{
    public static bool IsActive(Payment payment)
        => payment.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
           payment.Status.Equals("Paid", StringComparison.OrdinalIgnoreCase);

    public static bool HasActiveConflict(IEnumerable<Payment> payments, int excludedPaymentId = 0)
        => payments.Any(payment => payment.Id != excludedPaymentId && IsActive(payment));

    public static bool IsAllowedStatusTransition(string currentStatus, string nextStatus)
    {
        var current = currentStatus.Trim().ToLowerInvariant();
        var next = nextStatus.Trim().ToLowerInvariant();

        return current switch
        {
            "pending" => next is "pending" or "paid" or "failed" or "cancelled",
            "paid" => next == "paid",
            "failed" => next == "failed",
            "cancelled" => next == "cancelled",
            _ => false
        };
    }

    public static Payment? FindPaid(IEnumerable<Payment> payments)
        => payments.FirstOrDefault(payment =>
            payment.Status.Equals("Paid", StringComparison.OrdinalIgnoreCase));

    public static Payment? FindPendingCash(IEnumerable<Payment> payments)
        => payments.FirstOrDefault(payment =>
            payment.PaymentMethod.Equals("Cash", StringComparison.OrdinalIgnoreCase) &&
            payment.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase));
}
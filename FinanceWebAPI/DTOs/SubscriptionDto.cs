namespace FinanceWebAPI.DTOs
{
    public class SubscriptionDto
    {
        public int UserId { get; set; }
        public string SubscriptionName { get; set; } = string.Empty;
        public string SubscriptionCategory { get; set; } = string.Empty; // Dining, Groceries, Shopping, vb.
        public decimal MonthlyFee { get; set; }
        public int PaymentDay { get; set; } // 1 - 31
    }
}

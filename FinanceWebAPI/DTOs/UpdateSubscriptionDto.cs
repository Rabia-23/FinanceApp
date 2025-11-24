namespace FinanceWebAPI.DTOs
{
    public class UpdateSubscriptionDto
    {
        public string SubscriptionName { get; set; } = string.Empty;
        public string SubscriptionCategory { get; set; } = string.Empty;
        public decimal MonthlyFee { get; set; }
        public int PaymentDay { get; set; }
    }
}

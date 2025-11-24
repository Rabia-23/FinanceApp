using System;

namespace FinanceWebAPI.DTOs
{
    public class CreateSubscriptionDto
    {
        public int UserId { get; set; }
        public string SubscriptionName { get; set; } = string.Empty;
        public string SubscriptionCategory { get; set; } = string.Empty;
        public decimal MonthlyFee { get; set; }
        public int PaymentDay { get; set; }
    }
}
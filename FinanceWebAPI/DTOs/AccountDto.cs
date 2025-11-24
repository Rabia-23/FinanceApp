namespace FinanceWebAPI.DTOs
{
    public class AccountDto
    {
        public int AccountId { get; set; }
        public int UserId { get; set; }
        public string AccountName { get; set; } = string.Empty;
        public decimal AccountBalance { get; set; }
        public string Currency { get; set; } = "TRY";
    }
}

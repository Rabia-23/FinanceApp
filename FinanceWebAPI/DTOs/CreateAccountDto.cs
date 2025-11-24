namespace FinanceWebAPI.DTOs
{
    public class CreateAccountDto
    {
        public int UserId { get; set; }
        public string AccountName { get; set; } = string.Empty;
        public decimal AccountBalance { get; set; }
        public string Currency { get; set; } = "TRY";
    }
}

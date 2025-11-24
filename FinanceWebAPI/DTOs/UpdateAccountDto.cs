namespace FinanceWebAPI.DTOs
{
    public class UpdateAccountDto
    {
        public string AccountName { get; set; } = string.Empty;
        public decimal AccountBalance { get; set; }
        public string Currency { get; set; } = "TRY";
    }
}

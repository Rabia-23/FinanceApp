namespace FinanceWebAPI.DTOs
{
    public class CreateBudgetDto
    {
        public int UserId { get; set; }
        public string PeriodType { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal AmountLimit { get; set; }
    }
}

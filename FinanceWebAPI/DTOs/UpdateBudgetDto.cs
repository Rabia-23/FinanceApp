namespace FinanceWebAPI.DTOs
{
    public class UpdateBudgetDto
    {
        public string PeriodType { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal AmountLimit { get; set; }
        public decimal SpentAmount { get; set; }
    }
}

namespace FinanceWebAPI.DTOs
{
    public class BudgetDto
    {
        public int UserId { get; set; }
        public string PeriodType { get; set; } = string.Empty; // Weekly, Monthly, Yearly
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal AmountLimit { get; set; }
        public decimal SpentAmount { get; set; } = 0;
    }
}

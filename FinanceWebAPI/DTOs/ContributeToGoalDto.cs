namespace FinanceWebAPI.DTOs
{
    public class ContributeToGoalDto
    {
        public int AccountId { get; set; }
        public decimal Amount { get; set; }
        public string? Note { get; set; }
    }
}
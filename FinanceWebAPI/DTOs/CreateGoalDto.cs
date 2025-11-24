namespace FinanceWebAPI.DTOs
{
    public class CreateGoalDto
    {
        public int UserId { get; set; }
        public string GoalType { get; set; } = string.Empty;
        public string GoalName { get; set; } = string.Empty;
        public decimal TargetAmount { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}

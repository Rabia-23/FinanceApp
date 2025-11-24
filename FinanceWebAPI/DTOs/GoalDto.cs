namespace FinanceWebAPI.DTOs
{
    public class GoalDto
    {
        public int UserId { get; set; }
        public string GoalType { get; set; } = string.Empty; // expense_goal, savings_goal
        public string GoalName { get; set; } = string.Empty;
        public decimal TargetAmount { get; set; }
        public decimal CurrentAmount { get; set; } = 0;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}

using System;
using System.ComponentModel.DataAnnotations.Schema; // for foreign key

namespace FinanceWebAPI.Models
{
   public class Goal
   {
      public int GoalId { get; set; }
      public int UserId { get; set; }

      public string GoalType { get; set; } = string.Empty; // expense_goal veya savings_goal
      public string GoalName { get; set; } = string.Empty;
      public decimal TargetAmount { get; set; }
      public DateTime StartDate { get; set; }
      public DateTime EndDate { get; set; }
      public decimal CurrentAmount { get; set; } = 0;

      [ForeignKey("UserId")]
      public User? User { get; set; }
   }
}

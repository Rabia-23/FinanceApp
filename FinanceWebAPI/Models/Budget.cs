using System;
using System.ComponentModel.DataAnnotations.Schema; // for foreign key

namespace FinanceWebAPI.Models
{
   public class Budget
   {
      public int BudgetId { get; set; }
      public int UserId { get; set; }

      public string PeriodType { get; set; } = "Monthly"; // Weekly, Monthly, Yearly
      public DateTime StartDate { get; set; }
      public DateTime EndDate { get; set; }
      public decimal AmountLimit { get; set; }
      public decimal SpentAmount { get; set; } = 0;

      [ForeignKey("UserId")]
      public User? User { get; set; }
   }
}

using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace FinanceWebAPI.Models
{
   public class Subscription
   {
      public int SubscriptionId { get; set; }
      public int UserId { get; set; }
      public string SubscriptionName { get; set; } = string.Empty;
      public string SubscriptionCategory { get; set; } = string.Empty;
      public decimal MonthlyFee { get; set; }
      public int PaymentDay { get; set; }
      
      // yeni kolonlar icin mapping
      [Column("next_payment_date")]
      public DateTime NextPaymentDate { get; set; } = DateTime.UtcNow;
      
      [Column("is_overdue")]
      public bool IsOverdue { get; set; } = false;

      [ForeignKey("UserId")]
      public User? User { get; set; }
   }
}
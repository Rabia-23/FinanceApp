using System;
using System.ComponentModel.DataAnnotations.Schema; // for foreign key

namespace FinanceWebAPI.Models
{
   public class Account
   {
      public int AccountId { get; set; } // PRIMARY KEY
      public int UserId { get; set; } // FOREIGN KEY -> Users
      public string AccountName { get; set; } = string.Empty;
      public decimal AccountBalance { get; set; } = 0;
      public string Currency { get; set; } = "TRY";
      public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

      // Navigation property
      [ForeignKey("UserId")]
      public User? User { get; set; }
   }
}

using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace FinanceWebAPI.Models
{
    public class Transaction
    {
        public int TransactionId { get; set; } // PRIMARY KEY
        public int UserId { get; set; } // FOREIGN KEY -> Users
        public int AccountId { get; set; } // FOREIGN KEY -> Accounts

        public string TransactionType { get; set; } = "Expense"; // 'Income' veya 'Expense'
        public string TransactionTitle { get; set; } = string.Empty;
        public string TransactionCategory { get; set; } = string.Empty;
        public decimal TransactionAmount { get; set; }
        public string? TransactionNote { get; set; }
        public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
        public TimeSpan TransactionTime { get; set; } = DateTime.UtcNow.TimeOfDay;

        // Navigation properties
        [ForeignKey("UserId")]
        public User? User { get; set; }

        [ForeignKey("AccountId")]
         public Account Account { get; set; } = null!;
    }
}

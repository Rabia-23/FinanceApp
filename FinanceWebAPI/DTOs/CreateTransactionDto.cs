using System;
using System.Text.Json.Serialization;

namespace FinanceWebAPI.DTOs
{
    public class CreateTransactionDto
    {
        public int UserId { get; set; }
        public int AccountId { get; set; }
        public string TransactionType { get; set; } = "Expense";
        public string TransactionTitle { get; set; } = string.Empty;
        public string TransactionCategory { get; set; } = string.Empty;
        public decimal TransactionAmount { get; set; }
        public string? TransactionNote { get; set; }
        public DateTime TransactionDate { get; set; } = DateTime.UtcNow;
        public string TransactionTime { get; set; } = DateTime.UtcNow.TimeOfDay.ToString();
    }
}

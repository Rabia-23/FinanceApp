using System;
using System.Text.Json.Serialization;

namespace FinanceWebAPI.DTOs
{
    public class UpdateTransactionDto
    {
        public string TransactionType { get; set; } = "Expense";
        public string TransactionTitle { get; set; } = string.Empty;
        public string TransactionCategory { get; set; } = string.Empty;
        public decimal TransactionAmount { get; set; }
        public string? TransactionNote { get; set; }
        public DateTime TransactionDate { get; set; }
        public string TransactionTime { get; set; } = DateTime.UtcNow.TimeOfDay.ToString();
    }
}

using System.Collections.Generic;
using FinanceWebAPI.Models;

namespace FinanceWebAPI.DTOs
{
    public class HomeDataDto
    {
        public string UserName { get; set; } = string.Empty;
        public int UserId { get; set; }
        public List<AccountDto> Accounts { get; set; } = new(); // Burayı AccountDto yaptık
        public decimal NetWorth { get; set; }
        public List<Budget> Budgets { get; set; } = new();
        public List<Transaction> LastTransactions { get; set; } = new();
        public ChartData ChartData { get; set; } = new();
    }

    public class ChartData
    {
        public decimal Income { get; set; }
        public decimal Expense { get; set; }
        public decimal Total { get; set; }
    }
}

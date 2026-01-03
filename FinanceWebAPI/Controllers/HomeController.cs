using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Data;
using FinanceWebAPI.DTOs;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using FinanceWebAPI.Models; // Budget için

namespace FinanceWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class HomeController : ControllerBase
    {
        private readonly AppDbContext _context;

        public HomeController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetHomeData()
        {
            var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                return Unauthorized();

            var userId = int.Parse(userIdClaim.Value);

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound("Kullanici bulunamadi.");

            var accounts = await _context.Accounts
               .Where(a => a.UserId == userId)
               .Select(a => new AccountDto
               {
                  AccountId = a.AccountId,
                  UserId = a.UserId,
                  AccountName = a.AccountName,
                  AccountBalance = a.AccountBalance,
                  Currency = a.Currency
               })
               .ToListAsync();

            var netWorth = accounts.Sum(a => a.AccountBalance);

            // Budget'leri getirirken otomatik yenileme kontrolü yap
            var budgets = await _context.Budgets
               .Where(b => b.UserId == userId)
               .OrderByDescending(b => b.StartDate)
               .Take(5)
               .ToListAsync();

            // Her budget için yenileme kontrolü
            foreach (var budget in budgets)
            {
                await RenewBudgetIfExpired(budget);
            }

            var transactions = await _context.Transactions
               .Where(t => t.UserId == userId)
               .OrderByDescending(t => t.TransactionDate)
               .Take(30)
               .ToListAsync();

            var incomeSum = await _context.Transactions
               .Where(t => t.UserId == userId && t.TransactionType == "Income")
               .SumAsync(t => t.TransactionAmount);

            var expenseSum = await _context.Transactions
               .Where(t => t.UserId == userId && t.TransactionType == "Expense")
               .SumAsync(t => t.TransactionAmount);

            var data = new HomeDataDto
            {
               UserName = user.Username,
               UserId = userId,
               Accounts = accounts,
               NetWorth = netWorth,
               Budgets = budgets,
               LastTransactions = transactions,
               ChartData = new ChartData
               {
                  Income = incomeSum,
                  Expense = expenseSum,
                  Total = incomeSum - expenseSum
               }
            };

            return Ok(data);
        }

        // Otomatik Yenileme Fonksiyonu
        private async Task RenewBudgetIfExpired(Budget budget)
        {
            var now = DateTime.UtcNow;

            if (budget.EndDate < now)
            {
                var oldEnd = budget.EndDate;

                switch (budget.PeriodType)
                {
                    case "Weekly":
                        budget.StartDate = oldEnd;
                        budget.EndDate = oldEnd.AddDays(7);
                        break;

                    case "Monthly":
                        budget.StartDate = oldEnd;
                        budget.EndDate = new DateTime(
                            oldEnd.Year, 
                            oldEnd.Month, 
                            oldEnd.Day,
                            0, 0, 0,
                            DateTimeKind.Utc
                        ).AddMonths(1);
                        break;

                    case "Yearly":
                        budget.StartDate = oldEnd;
                        budget.EndDate = oldEnd.AddYears(1);
                        break;
                }

                budget.SpentAmount = 0;

                _context.Budgets.Update(budget);
                await _context.SaveChangesAsync();
            }
        }
    }
}
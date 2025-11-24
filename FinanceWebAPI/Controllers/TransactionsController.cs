using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Data;
using FinanceWebAPI.DTOs;
using FinanceWebAPI.Models;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace FinanceWebAPI.Controllers
{
   [Route("api/[controller]")]
   [ApiController]
   public class TransactionsController : ControllerBase
   {
      private readonly AppDbContext _context;

      public TransactionsController(AppDbContext context)
      {
         _context = context;
      }

      // GET /api/Transactions/{userId}
      [HttpGet("{userId}")]
      public async Task<ActionResult<IEnumerable<TransactionDto>>> GetTransactionsByUserId(int userId)
      {
         var transactions = await _context.Transactions
               .Where(t => t.UserId == userId)
               .OrderByDescending(t => t.TransactionDate)
               .ToListAsync();

         var transactionDtos = transactions.Select(t => new TransactionDto
         {
               TransactionId = t.TransactionId,
               UserId = t.UserId,
               AccountId = t.AccountId,
               TransactionType = t.TransactionType,
               TransactionTitle = t.TransactionTitle,
               TransactionCategory = t.TransactionCategory,
               TransactionAmount = t.TransactionAmount,
               TransactionNote = t.TransactionNote,
               TransactionDate = t.TransactionDate,
               TransactionTime = t.TransactionTime.ToString()
         }).ToList();

         return Ok(transactionDtos);
      }

      // POST /api/Transactions
      // POST /api/Transactions
      [HttpPost]
      public async Task<IActionResult> CreateTransaction([FromBody] CreateTransactionDto dto)
      {
         try
         {
            var user = await _context.Users.FindAsync(dto.UserId);
            if (user == null)
                  return NotFound("Kullanici bulunamadi.");

            var account = await _context.Accounts.FindAsync(dto.AccountId);
            if (account == null)
                  return NotFound("Hesap bulunamadi.");

            TimeSpan parsedTime;
            if (!TimeSpan.TryParse(dto.TransactionTime, out parsedTime))
            {
                  parsedTime = DateTime.UtcNow.TimeOfDay;
            }

            DateTime parsedDate = DateTime.SpecifyKind(dto.TransactionDate, DateTimeKind.Utc);

            var transaction = new Transaction
            {
                  UserId = dto.UserId,
                  AccountId = dto.AccountId,
                  TransactionType = dto.TransactionType,
                  TransactionTitle = dto.TransactionTitle,
                  TransactionCategory = dto.TransactionCategory,
                  TransactionAmount = dto.TransactionAmount,
                  TransactionNote = dto.TransactionNote,
                  TransactionDate = parsedDate,
                  TransactionTime = parsedTime
            };

            // AccountBalance'i guncelle
            if (transaction.TransactionType == "Income")
                  account.AccountBalance += transaction.TransactionAmount;
            else if (transaction.TransactionType == "Expense")
                  account.AccountBalance -= transaction.TransactionAmount;

            _context.Transactions.Add(transaction);

            // ✅ DEBUG: Tüm budget'leri çek ve kontrol et
            if (transaction.TransactionType == "Expense")
            {
                  var allBudgets = await _context.Budgets
                     .Where(b => b.UserId == dto.UserId)
                     .ToListAsync();

                  // ✅ DEBUG LOG
                  Console.WriteLine($"[DEBUG] Transaction Date: {parsedDate}");
                  Console.WriteLine($"[DEBUG] Found {allBudgets.Count} budgets for user {dto.UserId}");
                  
                  foreach (var b in allBudgets)
                  {
                     Console.WriteLine($"[DEBUG] Budget {b.BudgetId}: Start={b.StartDate}, End={b.EndDate}");
                     Console.WriteLine($"[DEBUG] Date Check: {parsedDate} >= {b.StartDate} && {parsedDate} <= {b.EndDate}");
                     Console.WriteLine($"[DEBUG] Result: {parsedDate >= b.StartDate && parsedDate <= b.EndDate}");
                  }

                  var activeBudget = allBudgets
                     .FirstOrDefault(b => parsedDate >= b.StartDate && parsedDate <= b.EndDate);

                  if (activeBudget != null)
                  {
                     Console.WriteLine($"[DEBUG] Active budget found! Updating spentAmount from {activeBudget.SpentAmount} to {activeBudget.SpentAmount + transaction.TransactionAmount}");
                     activeBudget.SpentAmount += transaction.TransactionAmount;
                  }
                  else
                  {
                     Console.WriteLine("[DEBUG] ❌ NO active budget found!");
                  }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                  message = "İşlem başarıyla eklendi.",
                  transactionId = transaction.TransactionId
            });
         }
         catch (Exception ex)
         {
            Console.WriteLine($"[ERROR] {ex.Message}");
            Console.WriteLine($"[ERROR] {ex.StackTrace}");
            return StatusCode(500, new
            {
                  message = "Bir hata oluştu.",
                  error = ex.Message,
                  innerError = ex.InnerException?.Message
            });
         }
      }

      // PUT /api/Transactions/{transactionId}
      [HttpPut("{transactionId}")]
      public async Task<IActionResult> UpdateTransaction(int transactionId, [FromBody] UpdateTransactionDto dto)
      {
         var transaction = await _context.Transactions.FindAsync(transactionId);
         if (transaction == null)
               return NotFound("İslem bulunamadi.");

         var account = await _context.Accounts.FindAsync(transaction.AccountId);
         if (account == null)
               return NotFound("İslem yapilan hesap bulunamadi.");

         // ✅ ESKİ TRANSACTION'IN BUDGET ETKİSİNİ GERİ AL
         if (transaction.TransactionType == "Expense")
         {
            var oldBudget = await _context.Budgets
                  .Where(b => b.UserId == transaction.UserId 
                     && b.StartDate <= transaction.TransactionDate 
                     && b.EndDate >= transaction.TransactionDate)
                  .FirstOrDefaultAsync();

            if (oldBudget != null)
            {
                  oldBudget.SpentAmount -= transaction.TransactionAmount;
            }
         }

         // AccountBalance'i eski haline cevir
         if (transaction.TransactionType == "Income")
               account.AccountBalance -= transaction.TransactionAmount;
         else if (transaction.TransactionType == "Expense")
               account.AccountBalance += transaction.TransactionAmount;

         // guncellemeler
         transaction.TransactionType = dto.TransactionType;
         transaction.TransactionTitle = dto.TransactionTitle;
         transaction.TransactionCategory = dto.TransactionCategory;
         transaction.TransactionAmount = dto.TransactionAmount;
         transaction.TransactionNote = dto.TransactionNote;
         transaction.TransactionDate = DateTime.SpecifyKind(dto.TransactionDate, DateTimeKind.Utc);
         transaction.TransactionTime = TimeSpan.Parse(dto.TransactionTime);

         // AccountBalance'i guncelle
         if (transaction.TransactionType == "Income")
               account.AccountBalance += transaction.TransactionAmount;
         else if (transaction.TransactionType == "Expense")
               account.AccountBalance -= transaction.TransactionAmount;

         // ✅ YENİ TRANSACTION'IN BUDGET ETKİSİNİ EKLE
         if (transaction.TransactionType == "Expense")
         {
            var newBudget = await _context.Budgets
                  .Where(b => b.UserId == transaction.UserId 
                     && b.StartDate <= transaction.TransactionDate 
                     && b.EndDate >= transaction.TransactionDate)
                  .FirstOrDefaultAsync();

            if (newBudget != null)
            {
                  newBudget.SpentAmount += transaction.TransactionAmount;
            }
         }

         await _context.SaveChangesAsync();

         var updatedTransaction = await _context.Transactions
               .Include(t => t.User)
               .Include(t => t.Account)
               .ThenInclude(a => a.User)
               .FirstOrDefaultAsync(t => t.TransactionId == transaction.TransactionId);

         return Ok(updatedTransaction);
      }

      // DELETE /api/Transactions/{transactionId}
      [HttpDelete("{transactionId}")]
      public async Task<IActionResult> DeleteTransaction(int transactionId)
      {
         var transaction = await _context.Transactions.FindAsync(transactionId);
         if (transaction == null)
               return NotFound("İslem bulunamadi.");

         var account = await _context.Accounts.FindAsync(transaction.AccountId);
         if (account != null)
         {
               // AccountBalance'i guncelle
               if (transaction.TransactionType == "Income")
                  account.AccountBalance -= transaction.TransactionAmount;
               else if (transaction.TransactionType == "Expense")
                  account.AccountBalance += transaction.TransactionAmount;
         }

         // ✅ BUDGET'TEN HARCAMAYI ÇIKAR
         if (transaction.TransactionType == "Expense")
         {
            var budget = await _context.Budgets
                  .Where(b => b.UserId == transaction.UserId 
                     && b.StartDate <= transaction.TransactionDate 
                     && b.EndDate >= transaction.TransactionDate)
                  .FirstOrDefaultAsync();

            if (budget != null)
            {
                  budget.SpentAmount -= transaction.TransactionAmount;
            }
         }

         _context.Transactions.Remove(transaction);
         await _context.SaveChangesAsync();

         return Ok("İslem basariyla silindi.");
      }
   }
}
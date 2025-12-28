using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Data;
using FinanceWebAPI.Models;
using FinanceWebAPI.DTOs;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace FinanceWebAPI.Controllers
{
   [Route("api/[controller]")]
   [ApiController]
   public class BudgetsController : ControllerBase
   {
      private readonly AppDbContext _context;

      public BudgetsController(AppDbContext context)
      {
         _context = context;
      }

      // GET: api/Budgets/{userId}
      [HttpGet("{userId}")]
      public async Task<IActionResult> GetBudgets(int userId)
      {
         var budgets = await _context.Budgets
               .Where(b => b.UserId == userId)
               .OrderByDescending(b => b.StartDate)
               .ToListAsync();

         // ✅ Otomatik yenileme kontrolü
         foreach (var budget in budgets)
         {
            await RenewBudgetIfExpired(budget);
         }

         return Ok(budgets);
      }

      // POST: api/Budgets
      [HttpPost]
      public async Task<IActionResult> CreateBudget([FromBody] CreateBudgetDto dto)
      {
         if (!ModelState.IsValid)
            return BadRequest(ModelState);

         var startDate = DateTime.SpecifyKind(dto.StartDate, DateTimeKind.Utc);
         var endDate = DateTime.SpecifyKind(dto.EndDate, DateTimeKind.Utc);

         if (endDate <= startDate)
         {
            return BadRequest("EndDate must be after StartDate");
         }

         var budget = new Budget
         {
            UserId = dto.UserId,
            PeriodType = dto.PeriodType,
            StartDate = startDate,
            EndDate = endDate,
            AmountLimit = dto.AmountLimit,
            SpentAmount = 0
         };

         _context.Budgets.Add(budget);
         await _context.SaveChangesAsync();

         return Ok(budget);
      }

      // PUT: api/Budgets/{id}
      [HttpPut("{id}")]
      public async Task<IActionResult> UpdateBudget(int id, [FromBody] UpdateBudgetDto dto)
      {
         var budget = await _context.Budgets.FindAsync(id);
         if (budget == null)
               return NotFound();

         // ✅ UTC olarak belirt (PostgreSQL hatası çözümü)
         var startDate = DateTime.SpecifyKind(dto.StartDate, DateTimeKind.Utc);
         var endDate = DateTime.SpecifyKind(dto.EndDate, DateTimeKind.Utc);

         if (endDate <= startDate)
         {
            return BadRequest("EndDate must be after StartDate");
         }

         budget.PeriodType = dto.PeriodType;
         budget.StartDate = startDate;
         budget.EndDate = endDate;
         budget.AmountLimit = dto.AmountLimit;
         budget.SpentAmount = dto.SpentAmount;

         await _context.SaveChangesAsync();
         return Ok(budget);
      }

      // DELETE: api/Budgets/{id}
      [HttpDelete("{id}")]
      public async Task<IActionResult> DeleteBudget(int id)
      {
         var budget = await _context.Budgets.FindAsync(id);
         if (budget == null)
               return NotFound();

         _context.Budgets.Remove(budget);
         await _context.SaveChangesAsync();

         return NoContent();
      }

      // ✅ YENİ: Otomatik Yenileme Fonksiyonu
      private async Task RenewBudgetIfExpired(Budget budget)
      {
         var now = DateTime.UtcNow;

         // Eğer bitiş tarihi geçmişse, yenile
         if (budget.EndDate < now)
         {
            var oldStart = budget.StartDate;
            var oldEnd = budget.EndDate;

            // Yeni dönem hesapla
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

            // Harcamayı sıfırla
            budget.SpentAmount = 0;

            // Veritabanına kaydet
            _context.Budgets.Update(budget);
            await _context.SaveChangesAsync();

            Console.WriteLine($"[AUTO-RENEW] Budget {budget.BudgetId} renewed: {oldStart} -> {budget.StartDate}");
         }
      }
   }
}
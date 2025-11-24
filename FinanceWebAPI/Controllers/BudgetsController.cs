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

         return Ok(budgets);
      }

      // POST: api/Budgets
      [HttpPost]
      public async Task<IActionResult> CreateBudget([FromBody] CreateBudgetDto dto)
      {
         if (!ModelState.IsValid)
            return BadRequest(ModelState);

         // ✅ DEBUG
         Console.WriteLine($"[DEBUG] Received StartDate: {dto.StartDate}");
         Console.WriteLine($"[DEBUG] Received EndDate: {dto.EndDate}");

         // ✅ Tarihleri UTC olarak ayarla
         var startDate = DateTime.SpecifyKind(dto.StartDate, DateTimeKind.Utc);
         var endDate = DateTime.SpecifyKind(dto.EndDate, DateTimeKind.Utc);

         // ✅ Kontrol: EndDate > StartDate olmalı
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

         // ✅ DEBUG
         Console.WriteLine($"[DEBUG] Created budget: Start={budget.StartDate}, End={budget.EndDate}");

         return Ok(budget);
      }

      // PUT: api/Budgets/{id}
      [HttpPut("{id}")]
      public async Task<IActionResult> UpdateBudget(int id, [FromBody] UpdateBudgetDto dto)
      {
         var budget = await _context.Budgets.FindAsync(id);
         if (budget == null)
               return NotFound();

         budget.PeriodType = dto.PeriodType;
         budget.StartDate = dto.StartDate;
         budget.EndDate = dto.EndDate;
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
   }
}

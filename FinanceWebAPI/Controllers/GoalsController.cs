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
    public class GoalsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public GoalsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Goals/{userId}
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetGoals(int userId)
        {
            var goals = await _context.Goals
                .Where(g => g.UserId == userId)
                .OrderByDescending(g => g.StartDate)
                .ToListAsync();

            return Ok(goals);
        }

        // POST: api/Goals
        [HttpPost]
        public async Task<IActionResult> CreateGoal([FromBody] CreateGoalDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var goal = new Goal
            {
                UserId = dto.UserId,
                GoalType = dto.GoalType,
                GoalName = dto.GoalName,
                TargetAmount = dto.TargetAmount,
                StartDate = dto.StartDate,
                EndDate = dto.EndDate,
                CurrentAmount = 0
            };

            _context.Goals.Add(goal);
            await _context.SaveChangesAsync();

            return Ok(goal);
        }

        // PUT: api/Goals/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGoal(int id, [FromBody] UpdateGoalDto dto)
        {
            var goal = await _context.Goals.FindAsync(id);
            if (goal == null)
                return NotFound();

            goal.GoalType = dto.GoalType;
            goal.GoalName = dto.GoalName;
            goal.TargetAmount = dto.TargetAmount;
            goal.StartDate = dto.StartDate;
            goal.EndDate = dto.EndDate;
            goal.CurrentAmount = dto.CurrentAmount;

            await _context.SaveChangesAsync();
            return Ok(goal);
        }

        // POST: api/Goals/{goalId}/contribute
         [HttpPost("{goalId}/contribute")]
         public async Task<IActionResult> ContributeToGoal(int goalId, [FromBody] ContributeToGoalDto dto)
         {
            try
            {
               var goal = await _context.Goals.FindAsync(goalId);
               if (goal == null)
                     return NotFound("Hedef bulunamadı.");

               var account = await _context.Accounts.FindAsync(dto.AccountId);
               if (account == null)
                     return NotFound("Hesap bulunamadı.");

               // Yeterli bakiye kontrolü
               if (account.AccountBalance < dto.Amount)
                     return BadRequest("Yetersiz bakiye.");

               // Account'tan para düş
               account.AccountBalance -= dto.Amount;

               // Goal'a para ekle
               goal.CurrentAmount += dto.Amount;

               // Transaction oluştur
               var transaction = new Transaction
               {
                     UserId = goal.UserId,
                     AccountId = dto.AccountId,
                     TransactionType = "Expense",
                     TransactionTitle = $"{goal.GoalName} hedefine katkı",
                     TransactionCategory = "Tasarruf",
                     TransactionAmount = dto.Amount,
                     TransactionNote = dto.Note,
                     TransactionDate = DateTime.UtcNow,
                     TransactionTime = DateTime.UtcNow.TimeOfDay
               };

               _context.Transactions.Add(transaction);
               await _context.SaveChangesAsync();

               return Ok(new
               {
                     message = "Katkı başarıyla eklendi.",
                     goal = goal,
                     newAccountBalance = account.AccountBalance
               });
            }
            catch (Exception ex)
            {
               return StatusCode(500, new
               {
                     message = "Bir hata oluştu.",
                     error = ex.Message
               });
            }
         }

        // DELETE: api/Goals/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGoal(int id)
        {
            var goal = await _context.Goals.FindAsync(id);
            if (goal == null)
                return NotFound();

            _context.Goals.Remove(goal);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}

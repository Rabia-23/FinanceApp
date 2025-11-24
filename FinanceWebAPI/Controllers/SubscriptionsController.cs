using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Data;
using FinanceWebAPI.Models;
using FinanceWebAPI.DTOs;
using System.Threading.Tasks;
using System.Linq;

namespace FinanceWebAPI.Controllers
{
   [Route("api/[controller]")]
   [ApiController]
   public class SubscriptionsController : ControllerBase
   {
      private readonly AppDbContext _context;

      public SubscriptionsController(AppDbContext context)
      {
         _context = context;
      }

      // GET: api/Subscriptions/{userId}
      [HttpGet("{userId}")]
      public async Task<IActionResult> GetSubscriptions(int userId)
      {
            var subs = await _context.Subscriptions
               .Where(s => s.UserId == userId)
               .OrderBy(s => s.PaymentDay)
               .ToListAsync();

            return Ok(subs);
      }

      // POST: api/Subscriptions
      [HttpPost]
      public async Task<IActionResult> CreateSubscription([FromBody] CreateSubscriptionDto dto)
      {
         if (!ModelState.IsValid)
            return BadRequest(ModelState);

         var today = DateTime.UtcNow;
         var nextPayment = new DateTime(today.Year, today.Month, dto.PaymentDay);
         
         if (nextPayment < today)
         {
            nextPayment = nextPayment.AddMonths(1);
         }

         nextPayment = DateTime.SpecifyKind(nextPayment, DateTimeKind.Utc);

         var sub = new Subscription
         {
            UserId = dto.UserId,
            SubscriptionName = dto.SubscriptionName,
            SubscriptionCategory = dto.SubscriptionCategory,
            MonthlyFee = dto.MonthlyFee,
            PaymentDay = dto.PaymentDay,
            NextPaymentDate = nextPayment,
            IsOverdue = false
         };

         _context.Subscriptions.Add(sub);
         await _context.SaveChangesAsync();

         return Ok(sub);
      }

      // PUT: api/Subscriptions/{id}
      [HttpPut("{id}")]
      public async Task<IActionResult> UpdateSubscription(int id, [FromBody] UpdateSubscriptionDto dto)
      {
            var sub = await _context.Subscriptions.FindAsync(id);
            if (sub == null)
               return NotFound();

            sub.SubscriptionName = dto.SubscriptionName;
            sub.SubscriptionCategory = dto.SubscriptionCategory;
            sub.MonthlyFee = dto.MonthlyFee;
            sub.PaymentDay = dto.PaymentDay;

            await _context.SaveChangesAsync();
            return Ok(sub);
      }

      // DELETE: api/Subscriptions/{id}
      [HttpDelete("{id}")]
      public async Task<IActionResult> DeleteSubscription(int id)
      {
            var sub = await _context.Subscriptions.FindAsync(id);
            if (sub == null)
               return NotFound();

            _context.Subscriptions.Remove(sub);
            await _context.SaveChangesAsync();

            return NoContent();
      }

      // POST: api/Subscriptions/{id}/pay
      // POST: api/Subscriptions/{id}/pay
      [HttpPost("{id}/pay")]
      public async Task<IActionResult> PaySubscription(int id, [FromBody] PaySubscriptionDto dto)
      {
         try
         {
            var subscription = await _context.Subscriptions.FindAsync(id);
            if (subscription == null)
                  return NotFound("Abonelik bulunamadı.");

            var account = await _context.Accounts.FindAsync(dto.AccountId);
            if (account == null)
                  return NotFound("Hesap bulunamadı.");

            if (account.AccountBalance < subscription.MonthlyFee)
                  return BadRequest("Yetersiz bakiye.");

            account.AccountBalance -= subscription.MonthlyFee;

            var transaction = new Transaction
            {
               UserId = subscription.UserId,
               AccountId = dto.AccountId,
               TransactionType = "Expense",
               TransactionTitle = $"{subscription.SubscriptionName} abonelik ödemesi",
               TransactionCategory = subscription.SubscriptionCategory,
               TransactionAmount = subscription.MonthlyFee,
               TransactionNote = dto.Note,
               TransactionDate = DateTime.SpecifyKind(DateTime.Now, DateTimeKind.Utc), // ✅ UTC olarak belirt
               TransactionTime = DateTime.UtcNow.TimeOfDay
            };

            _context.Transactions.Add(transaction);

            subscription.NextPaymentDate = DateTime.SpecifyKind(
               subscription.NextPaymentDate.AddMonths(1), 
               DateTimeKind.Utc
            ); // ✅ Bu da UTC olmalı
            subscription.IsOverdue = false;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                  message = "Ödeme başarıyla yapıldı.",
                  subscription = subscription,
                  newAccountBalance = account.AccountBalance
            });
         }
         catch (Exception ex)
         {
            // ✅ DETAYLI HATA MESAJI
            return StatusCode(500, new
            {
                  message = "Bir hata oluştu.",
                  error = ex.Message,
                  innerError = ex.InnerException?.Message, // ✅ Bu önemli
                  stackTrace = ex.StackTrace // ✅ Debugging için
            });
         }
      }

      // POST: api/Subscriptions/{id}/skip
      [HttpPost("{id}/skip")]
      public async Task<IActionResult> SkipSubscription(int id)
      {
         try
         {
            var subscription = await _context.Subscriptions.FindAsync(id);
            if (subscription == null)
                  return NotFound("Abonelik bulunamadı.");

            subscription.NextPaymentDate = DateTime.SpecifyKind(
                  subscription.NextPaymentDate.AddMonths(1), 
                  DateTimeKind.Utc
            ); // ✅ UTC olarak belirt
            subscription.IsOverdue = false;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                  message = "Ödeme atlandı.",
                  subscription = subscription
            });
         }
         catch (Exception ex)
         {
            return StatusCode(500, new
            {
                  message = "Bir hata oluştu.",
                  error = ex.Message,
                  innerError = ex.InnerException?.Message
            });
         }
      }
   }
}

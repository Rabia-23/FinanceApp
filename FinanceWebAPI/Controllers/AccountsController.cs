using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Data;
using FinanceWebAPI.Models;
using FinanceWebAPI.DTOs;
using System.Linq;
using System.Threading.Tasks;

namespace FinanceWebAPI.Controllers
{
    [Route("api/[controller]")] // /api/Accounts
    [ApiController]
    public class AccountsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AccountsController(AppDbContext context)
        {
            _context = context;
        }

        // GET /api/Accounts/{userId}
        [HttpGet("{userId}")]
         public async Task<ActionResult<IEnumerable<AccountDto>>> GetAccountsByUserId(int userId)
         {
            var accounts = await _context.Accounts
               .Where(a => a.UserId == userId)
               .ToListAsync();

            var accountDtos = accounts.Select(a => new AccountDto
            {
               AccountId = a.AccountId,
               UserId = a.UserId,
               AccountName = a.AccountName,
               AccountBalance = a.AccountBalance,
               Currency = a.Currency
            }).ToList();

            return Ok(accountDtos);
         }


        // POST /api/Accounts
        [HttpPost]
        public async Task<IActionResult> CreateAccount([FromBody] CreateAccountDto dto)
        {
            var user = await _context.Users.FindAsync(dto.UserId);
            if (user == null)
                return NotFound("Kullanici bulunamadi.");

            var newAccount = new Account
            {
                UserId = dto.UserId,
                AccountName = dto.AccountName,
                AccountBalance = dto.AccountBalance,
                Currency = dto.Currency
            };

            _context.Accounts.Add(newAccount);
            await _context.SaveChangesAsync();

            return Ok(newAccount);
        }

        // PUT /api/Accounts/{accountId}
        [HttpPut("{accountId}")]
        public async Task<IActionResult> UpdateAccount(int accountId, [FromBody] UpdateAccountDto dto)
        {
            var account = await _context.Accounts.FindAsync(accountId);
            if (account == null)
                return NotFound("Hesap bulunamadi.");

            account.AccountName = dto.AccountName;
            account.AccountBalance = dto.AccountBalance;
            account.Currency = dto.Currency;

            await _context.SaveChangesAsync();
            return Ok(account);
        }

        // DELETE /api/Accounts/{accountId}
        [HttpDelete("{accountId}")]
        public async Task<IActionResult> DeleteAccount(int accountId)
        {
            var account = await _context.Accounts.FindAsync(accountId);
            if (account == null)
                return NotFound("Hesap bulunamadi.");

            _context.Accounts.Remove(account);
            await _context.SaveChangesAsync();

            return Ok("Hesap basariyla silindi.");
        }
    }
}

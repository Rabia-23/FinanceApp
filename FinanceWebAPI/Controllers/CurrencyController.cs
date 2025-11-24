using Microsoft.AspNetCore.Mvc;
using FinanceWebAPI.DTOs;
using FinanceWebAPI.Services;
using System.Threading.Tasks;

namespace FinanceWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CurrencyController : ControllerBase
    {
        private readonly CurrencyService _currencyService;

        public CurrencyController(CurrencyService currencyService)
        {
            _currencyService = currencyService;
        }

        // GET /api/Currency
        [HttpGet]
        public async Task<ActionResult<CurrencyDto>> GetCurrencies()
        {
            try
            {
                var data = await _currencyService.GetLatestCurrenciesAsync();
                return Ok(data);
            }
            catch (System.Exception ex)
            {
                return StatusCode(500, new { message = "Error fetching currencies", error = ex.Message });
            }
        }
    }
}

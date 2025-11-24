using Microsoft.AspNetCore.Mvc;
using FinanceWebAPI.DTOs;
using FinanceWebAPI.Models;
using FinanceWebAPI.Services;

namespace FinanceWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        public AuthController(IUserService userService)
        {
            _userService = userService;
        }

        // POST: api/Auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] UserRegisterDto registerDto)
        {
            if (string.IsNullOrEmpty(registerDto.Username) ||
                string.IsNullOrEmpty(registerDto.Email) ||
                string.IsNullOrEmpty(registerDto.Password))
            {
                return BadRequest(new { message = "Tüm alanları doldurun" });
            }

            if (await _userService.IsEmailTakenAsync(registerDto.Email))
            {
                return BadRequest(new { message = "Bu email zaten kayıtlı" });
            }

            var user = await _userService.RegisterUserAsync(
                registerDto.Username,
                registerDto.Email,
                registerDto.Password
            );

            return Ok(new { message = "Kayıt başarılı", userId = user.UserId });
        }

        // POST: api/Auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] UserLoginDto loginDto)
        {
            if (string.IsNullOrEmpty(loginDto.Email) || string.IsNullOrEmpty(loginDto.Password))
            {
                return BadRequest(new { message = "Email ve şifre boş olamaz" });
            }

            var user = await _userService.LoginUserAsync(loginDto.Email, loginDto.Password);

            if (user == null)
            {
                return Unauthorized(new { message = "Email veya şifre hatalı" });
            }

            var token = _userService.GenerateJwtToken(user);

            return Ok(new
            {
                message = "Giriş başarılı",
                token,
                userId = user.UserId,
                username = user.Username,
                email = user.Email
            });
        }
    }
}

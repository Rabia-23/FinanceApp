using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using FinanceWebAPI.Data;
using FinanceWebAPI.Models;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace FinanceWebAPI.Services
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _context;
        private readonly string _jwtKey = string.Empty;
        private readonly string? _jwtAudience = string.Empty;
        private readonly string? _jwtIssuer = string.Empty;

        public UserService(AppDbContext context, IConfiguration config)
        {
            _context = context;
            _jwtKey = config["Jwt:Key"] ?? throw new Exception("JWT Key missing!");
            _jwtAudience = config["Jwt:Audience"] ?? throw new Exception("JWT Audience missing!");
            _jwtIssuer = config["Jwt:Issuer"] ?? throw new Exception("JWT Issuer missing!");
        }

        private string HashPassword(string password)
        {
            using var sha256 = SHA256.Create();
            var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }

        public async Task<User> RegisterUserAsync(string username, string email, string password)
        {
            var hashedPassword = HashPassword(password);

            var user = new User
            {
                Username = username,
                Email = email,
                PasswordHash = hashedPassword,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            return user;
        }

        public async Task<User?> LoginUserAsync(string email, string password)
        {
            var hashedPassword = HashPassword(password);
            return await _context.Users.FirstOrDefaultAsync(
                u => u.Email == email && u.PasswordHash == hashedPassword
            );
        }

        public async Task<bool> IsEmailTakenAsync(string email)
        {
            return await _context.Users.AnyAsync(u => u.Email == email);
        }

        public string GenerateJwtToken(User user)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.UserId.ToString()),
                new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
                new Claim(JwtRegisteredClaimNames.Email, user.Email)
            };

            var token = new JwtSecurityToken(
               issuer: _jwtIssuer,
               audience: _jwtAudience,
               claims: claims,
               expires: DateTime.UtcNow.AddMinutes(60),
               signingCredentials: creds
            );
            Console.WriteLine($"Issuer: {_jwtIssuer}, Audience: {_jwtAudience}, Key: {_jwtKey}");

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}

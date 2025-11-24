namespace FinanceWebAPI.DTOs
{
   public class UserDto
   {
      public string Username { get; set; } = string.Empty; // Register sayfası için
      public string Email { get; set; } = string.Empty; // Register + Login için
      public string Password { get; set; } = string.Empty; // Düz metin halinde frontend'den geliyor
   }
}

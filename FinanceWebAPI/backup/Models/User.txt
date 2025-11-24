using System;

namespace FinanceWebAPI.Models
{
   public class User
   {
      public int UserId { get; set; } // PRIMARY KEY
      public string Username { get; set; } = string.Empty; // Kullanıcı adı
      public string Email { get; set; } = string.Empty; // Email
      public string PasswordHash { get; set; } = string.Empty; // Şifre hashlenmiş şekilde saklanacak
      public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // kullanici olusturma zamani
   }
}

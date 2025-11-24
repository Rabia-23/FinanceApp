using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Models;

namespace FinanceWebAPI.Data
{
   public class AppDbContext : DbContext
   {
      public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

      // Tablolar
      public DbSet<User> Users { get; set; }
      public DbSet<Account> Accounts { get; set; }
      public DbSet<Budget> Budgets { get; set; }
      public DbSet<Transaction> Transactions { get; set; }
      public DbSet<Subscription> Subscriptions { get; set; }
      public DbSet<Goal> Goals { get; set; }

      // Model ilişkileri
      protected override void OnModelCreating(ModelBuilder modelBuilder)
      {
         base.OnModelCreating(modelBuilder);

         // USER → ACCOUNT ilişkisi
         modelBuilder.Entity<Account>()
            .HasOne(a => a.User) // her account bir user'a bagli
            .WithMany() // bir user'in birden fazla account'ı olabilir
            .HasForeignKey(a => a.UserId) // UserId foreign key
            .OnDelete(DeleteBehavior.Cascade); // user silinirse tum account'lar silinir

         // USER → TRANSACTION ilişkisi
         modelBuilder.Entity<Transaction>()
            .HasOne(t => t.User) // her transaction bir user'a bagli
            .WithMany() // bir user'in birden fazla transaction'i olabilir
            .HasForeignKey(t => t.UserId) // UserId foreign key
            .OnDelete(DeleteBehavior.Cascade); // user silinirse tum transaction'lar silinir

         // ACCOUNT → TRANSACTION ilişkisi
         modelBuilder.Entity<Transaction>()
            .HasOne(t => t.Account) // her transaction bir account'a bagli
            .WithMany() // bir account'in birden fazla transaction'i olabilir
            .HasForeignKey(t => t.AccountId) // AccountId foreign key
            .OnDelete(DeleteBehavior.Cascade); // account silinirse tum transaction'lar silinir

         // USER → BUDGET ilişkisi
         modelBuilder.Entity<Budget>()
            .HasOne(b => b.User) // her budget bir user'a bagli
            .WithMany() // bir user'in birden fazla budget'i olabilir
            .HasForeignKey(b => b.UserId) // UserId foreign key
            .OnDelete(DeleteBehavior.Cascade); // user silinirse tum budget'lar silinir

         // USER → SUBSCRIPTION ilişkisi
         modelBuilder.Entity<Subscription>()
            .HasOne(s => s.User) // her subscription bir user'a bagli
            .WithMany() // bir user'in birden fazla subscription'i olabilir
            .HasForeignKey(s => s.UserId) // UserId foreign key
            .OnDelete(DeleteBehavior.Cascade); // user silinirse tum subscription'lar silinir

         // USER → GOAL ilişkisi
         modelBuilder.Entity<Goal>()
            .HasOne(g => g.User) // her goal bir user'a bagli
            .WithMany() // bir user'in birden fazla goal'u olabilir
            .HasForeignKey(g => g.UserId) // UserId foreign key
            .OnDelete(DeleteBehavior.Cascade); // user silinirse tum goal'lar silinir
      }
   }
}

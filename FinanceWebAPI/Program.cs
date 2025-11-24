using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.OpenApi.Models;
using System.IdentityModel.Tokens.Jwt;

using FinanceWebAPI.Data;
using Microsoft.EntityFrameworkCore;
using FinanceWebAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// PostgreSQL bağlantısı
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Servisler
builder.Services.AddScoped<IUserService, UserService>();
var jwtSettings = builder.Configuration.GetSection("Jwt");

builder.Services.AddScoped<CurrencyService>();
builder.Services.AddHttpClient();

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"]!))
    };

    // Geliştirilmiş debug
    options.Events = new JwtBearerEvents
   {
      OnMessageReceived = context =>
      {
         var token = context.Request.Headers["Authorization"].FirstOrDefault()?.Split(" ").Last();
         Console.WriteLine($"OnMessageReceived - Token: {token}");
         
         // ÖNEMLİ: Token'ı context'e set et
         if (!string.IsNullOrEmpty(token))
         {
               context.Token = token;
         }
         
         Console.WriteLine($"OnMessageReceived - context.Token: {context.Token}");
         return Task.CompletedTask;
      },
      OnAuthenticationFailed = context =>
      {
         Console.WriteLine($"Authentication FAILED: {context.Exception.Message}");
         Console.WriteLine($"Exception Type: {context.Exception.GetType().Name}");
         if (context.Exception.InnerException != null)
         {
               Console.WriteLine($"Inner Exception: {context.Exception.InnerException.Message}");
         }
         return Task.CompletedTask;
      },
      OnTokenValidated = context =>
      {
         Console.WriteLine("Token VALIDATED successfully!");
         
         // Tüm claim'leri yazdır
         if (context.Principal != null)
         {
            Console.WriteLine("All Claims:");
            foreach (var claim in context.Principal.Claims)
            {
                  Console.WriteLine($"  Type: {claim.Type}, Value: {claim.Value}");
            }
            
            var userId = context.Principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            Console.WriteLine($"User ID from token (Sub): {userId}");
            
            // Alternatif claim type'ları da dene
            var userIdAlt = context.Principal.FindFirst("sub")?.Value;
            Console.WriteLine($"User ID from token (sub lowercase): {userIdAlt}");
         }
         else
         {
            Console.WriteLine("context.Principal is NULL!");
         }
         
         return Task.CompletedTask;
      },
      OnChallenge = context =>
      {
         Console.WriteLine($"OnChallenge - Error: {context.Error}");
         Console.WriteLine($"OnChallenge - ErrorDescription: {context.ErrorDescription}");
         return Task.CompletedTask;
      }
   };
});



builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "FinanceWebAPI", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,  // ← Tekrar Http yaptık
        Scheme = "bearer",  // ← Küçük harfle "bearer"
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header. Enter your token below."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// 1️⃣ CORS servisini ekle
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Swagger (isteğe bağlı)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Statik dosyalar (frontend)
app.UseDefaultFiles(); 
app.UseStaticFiles();



app.UseRouting(); // HTTP isteklerini Controller'a yonlendirir
// 2️⃣ CORS middleware’ini ekle
app.UseCors();
app.UseAuthentication();
app.UseAuthorization(); // yetkilendirme kontrolu (su an auth yok)
app.MapControllers(); // controller endpoint'lerini aktif eder

app.Run();

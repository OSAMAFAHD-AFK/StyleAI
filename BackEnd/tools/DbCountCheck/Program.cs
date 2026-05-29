using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using StyleAI.Infrastructure.Persistence;

var config = new ConfigurationBuilder()
    .SetBasePath(@"D:\StyleAI\BackEnd\src\StyleAI.Api")
    .AddJsonFile("appsettings.Development.json")
    .Build();

var conn = config.GetConnectionString("DefaultConnection")!;
await using var db = new AppDbContext(new DbContextOptionsBuilder<AppDbContext>().UseNpgsql(conn).Options);
var searchLogs = await db.SearchLogs.CountAsync();
var clicks = await db.ClickTrackings.CountAsync();
Console.WriteLine($"SearchLogs={searchLogs} ClickTrackings={clicks}");
if (searchLogs > 0 && clicks > 0) Environment.Exit(0);
Environment.Exit(1);

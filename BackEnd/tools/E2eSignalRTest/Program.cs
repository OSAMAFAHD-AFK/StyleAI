using System.Text.Json;
using Microsoft.AspNetCore.SignalR.Client;

var baseUrl = (args.Length > 0 ? args[0] : "http://localhost:5045").TrimEnd('/');
var requestId = args.Length > 1 ? args[1] : throw new Exception("Usage: E2eSignalRTest <baseUrl> <requestId>");

var offerCount = 0;
var searchCompleted = false;
var searchStarted = false;

var connection = new HubConnectionBuilder()
    .WithUrl($"{baseUrl}/hubs/search-offers")
    .WithAutomaticReconnect()
    .Build();

connection.On<JsonElement>("SearchStarted", _ => searchStarted = true);
connection.On<JsonElement>("OfferReceived", _ => Interlocked.Increment(ref offerCount));
connection.On<JsonElement>("SearchCompleted", _ => searchCompleted = true);

await connection.StartAsync();
await connection.InvokeAsync("JoinSearchGroup", requestId);

using var http = new HttpClient();
http.DefaultRequestHeaders.Add("X-Country-Code", "SA");
http.DefaultRequestHeaders.Add("X-Device-Token", "flutter-e2e-test-device");

var startResponse = await http.PostAsync($"{baseUrl}/api/search/{requestId}/offers/start", null);
if (!startResponse.IsSuccessStatusCode)
{
    Console.WriteLine($"FAIL: offers/start returned {(int)startResponse.StatusCode}");
    Environment.Exit(1);
}

var deadline = DateTime.UtcNow.AddSeconds(25);
while (DateTime.UtcNow < deadline && !searchCompleted)
{
    await Task.Delay(200);
}

await connection.StopAsync();

if ((searchStarted || offerCount > 0) && offerCount > 0 && searchCompleted)
{
    Console.WriteLine($"PASS: SignalR SearchStarted={searchStarted} OfferReceived={offerCount} SearchCompleted={searchCompleted}");
    Environment.Exit(0);
}

Console.WriteLine($"FAIL: SignalR SearchStarted={searchStarted} OfferReceived={offerCount} SearchCompleted={searchCompleted}");
Environment.Exit(1);

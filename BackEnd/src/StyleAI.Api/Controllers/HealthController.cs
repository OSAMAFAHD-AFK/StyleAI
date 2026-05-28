using Microsoft.AspNetCore.Mvc;

namespace StyleAI.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() =>
        Ok(new
        {
            status = "healthy",
            service = "StyleAI.Api",
            timestamp = DateTimeOffset.UtcNow
        });
}

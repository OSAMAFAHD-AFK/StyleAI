using Microsoft.AspNetCore.Mvc;
using StyleAI.Application.Common.Interfaces;

namespace StyleAI.Api.Controllers;

[ApiController]
[Route("api/thrift")]
public sealed class ThriftController : ControllerBase
{
    private const string DeviceTokenHeaderName = "X-Device-Token";

    private readonly IThriftCounterService _thriftCounterService;

    public ThriftController(IThriftCounterService thriftCounterService)
    {
        _thriftCounterService = thriftCounterService;
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummaryAsync(CancellationToken cancellationToken)
    {
        var deviceToken = Request.Headers[DeviceTokenHeaderName].FirstOrDefault();
        var summary = await _thriftCounterService.GetSummaryAsync(deviceToken, cancellationToken);

        return Ok(new
        {
            summary.UserId,
            totalSavings = summary.TotalSavings,
            currency = summary.Currency,
            totalClicks = summary.TotalClicks,
            convertedClicks = summary.ConvertedClicks
        });
    }
}

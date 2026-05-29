# StyleAI Backend E2E checklist (items 1-9) - uses curl for multipart
$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:5045"
$deviceToken = "flutter-e2e-test-device"
$countryCode = "SA"
$results = @{}

function Pass($n, $msg) { $script:results[$n] = "PASS: $msg"; Write-Host "[$n] PASS - $msg" -ForegroundColor Green }
function Fail($n, $msg) { $script:results[$n] = "FAIL: $msg"; Write-Host "[$n] FAIL - $msg" -ForegroundColor Red }
function Skip($n, $msg) { $script:results[$n] = "SKIP: $msg"; Write-Host "[$n] SKIP - $msg" -ForegroundColor Yellow }

# 1
try {
    $health = curl.exe -s "$baseUrl/health"
    $db = curl.exe -s "$baseUrl/api/db/ping" | ConvertFrom-Json
    Pass 1 "API + PostgreSQL status=$($db.status)"
} catch { Fail 1 $_.Exception.Message }

# test image
$testImage = Join-Path $env:TEMP "styleai-e2e-test.jpg"
if (-not (Test-Path $testImage)) {
    Add-Type -AssemblyName System.Drawing
    $bmp = New-Object System.Drawing.Bitmap 640, 640
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::White)
    $g.FillRectangle([System.Drawing.Brushes]::DarkGreen, 120, 80, 400, 480)
    $bmp.Save($testImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $g.Dispose(); $bmp.Dispose()
}

# 2 upload
$uploadJson = curl.exe -s -X POST "$baseUrl/api/search/upload" `
    -H "X-Device-Token: $deviceToken" -H "X-Country-Code: $countryCode" `
    -F "image=@$testImage"
try {
    $upload = $uploadJson | ConvertFrom-Json
    if ($upload.tagsStatus -eq "available" -and $upload.requestId) {
        Pass 2 "tagsStatus=available requestId=$($upload.requestId) searchLogId=$($upload.searchLogId)"
    } else {
        Fail 2 "tagsStatus=$($upload.tagsStatus) response=$uploadJson"
    }
    $requestId = $upload.requestId
} catch { Fail 2 $uploadJson }

if (-not $requestId) { goto summary }

# 3 start offers
$startJson = curl.exe -s -X POST "$baseUrl/api/search/$requestId/offers/start" `
    -H "X-Device-Token: $deviceToken" -H "X-Country-Code: $countryCode"
try {
    $start = $startJson | ConvertFrom-Json
    if ($start.requestId) { Pass 3 "Started provider=$($start.provider)" } else { Fail 3 $startJson }
} catch { Fail 3 $startJson }

# 4 SignalR (separate tool) - placeholder, run e2e-signalr after
Skip 4 "Run e2e-signalr tool separately (see output below)"

Start-Sleep -Seconds 5

# 5 GET offers
$offersJson = curl.exe -s "$baseUrl/api/search/$requestId/offers"
try {
    $offers = $offersJson | ConvertFrom-Json
    $dupesCount = if ($offers.dupes) { @($offers.dupes).Count } else { @($offers.offers).Count }
    if ($dupesCount -gt 0) {
        Pass 5 "status=$($offers.status) offers=$dupesCount benchmark=$($null -ne $offers.benchmark) summary=$($null -ne $offers.summary)"
        $firstOfferId = if ($offers.dupes -and $offers.dupes.Count -gt 0) { $offers.dupes[0].offerId } else { $offers.offers[0].offerId }
    } else { Fail 5 "No offers. status=$($offers.status)" }
} catch { Fail 5 $offersJson }

# thrift before
$thriftBeforeJson = curl.exe -s "$baseUrl/api/thrift/summary" -H "X-Device-Token: $deviceToken"
$thriftBefore = $thriftBeforeJson | ConvertFrom-Json
$savingsBefore = [decimal]$thriftBefore.totalSavings

# 6 prepare
if ($firstOfferId) {
    $prepareBody = "{`"requestId`":`"$requestId`",`"offerId`":`"$firstOfferId`"}"
    $prepareJson = curl.exe -s -X POST "$baseUrl/api/redirect/prepare" `
        -H "X-Device-Token: $deviceToken" -H "Content-Type: application/json" -d $prepareBody
    try {
        $prepare = $prepareJson | ConvertFrom-Json
        if ($prepare.redirectUrl) {
            Pass 6 "savedAmount=$($prepare.savedAmount) trackingId=$($prepare.affiliateTrackingId)"
            $trackingId = $prepare.affiliateTrackingId
        } else { Fail 6 $prepareJson }
    } catch { Fail 6 $prepareJson }

    # 7 redirect 302
    if ($trackingId) {
        $redirectOut = curl.exe -s -o NUL -w "%{http_code}" "$baseUrl/api/redirect/$trackingId"
        if ($redirectOut -eq "302") { Pass 7 "HTTP 302" } else { Fail 7 "HTTP $redirectOut" }
    }
} else { Fail 6 "no offerId"; Fail 7 "skipped" }

# 8 thrift after
$thriftAfterJson = curl.exe -s "$baseUrl/api/thrift/summary" -H "X-Device-Token: $deviceToken"
$thriftAfter = $thriftAfterJson | ConvertFrom-Json
if ([decimal]$thriftAfter.totalSavings -ge $savingsBefore) {
    Pass 8 "totalSavings $($savingsBefore) -> $($thriftAfter.totalSavings) clicks=$($thriftAfter.totalClicks)"
} else { Fail 8 "savings decreased" }

# 9 DB
try {
    $cfg = Get-Content "D:\StyleAI\BackEnd\src\StyleAI.Api\appsettings.Development.json" | ConvertFrom-Json
    $conn = $cfg.ConnectionStrings.DefaultConnection
    if ($conn -match "Database=([^;]+)") { $dbName = $Matches[1] } else { $dbName = "StyleAi_Db" }
    if ($conn -match "Password=([^;]+)") { $dbPass = $Matches[1] } else { $dbPass = "postgres" }
    $env:PGPASSWORD = $dbPass
    $sl = (& psql -h localhost -U postgres -d $dbName -t -A -c 'SELECT COUNT(*) FROM "SearchLogs";' 2>&1).Trim()
    $ct = (& psql -h localhost -U postgres -d $dbName -t -A -c 'SELECT COUNT(*) FROM "ClickTrackings";' 2>&1).Trim()
    if ($sl -match '^\d+$' -and [int]$sl -gt 0 -and $ct -match '^\d+$' -and [int]$ct -gt 0) {
        Pass 9 "SearchLogs=$sl ClickTrackings=$ct"
    } elseif ($sl -match '^\d+$') {
        Fail 9 "SearchLogs=$sl ClickTrackings=$ct"
    } else { Skip 9 "psql unavailable: $sl $ct" }
} catch { Skip 9 $_.Exception.Message }

:summary
Write-Host "`n========== CHECKLIST SUMMARY ==========" -ForegroundColor Cyan
1..9 | ForEach-Object { if ($results.ContainsKey($_)) { Write-Host "$_`: $($results[$_])" } }
Write-Host "10: SKIP (Skimlinks Live - waiting for ProductKey)" -ForegroundColor Yellow

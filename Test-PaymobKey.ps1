# 🧪 Test Paymob API Key - PowerShell Script
# Usage: .\Test-PaymobKey.ps1 -ApiKey "YOUR_API_KEY"

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey
)

Write-Host "`n🔍 اختبار Paymob API Key..." -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

Write-Host "📌 API Key: $($ApiKey.Substring(0, [Math]::Min(30, $ApiKey.Length)))..." -ForegroundColor Yellow
Write-Host "📏 Length: $($ApiKey.Length) characters" -ForegroundColor Yellow
Write-Host "`n🔗 Connecting to Paymob...`n" -ForegroundColor Cyan

# Prepare request body
$body = @{
    api_key = $ApiKey
} | ConvertTo-Json

# Send request
try {
    $response = Invoke-RestMethod -Uri "https://accept.paymob.com/api/auth/tokens" `
                                  -Method Post `
                                  -ContentType "application/json" `
                                  -Body $body `
                                  -ErrorAction Stop

    Write-Host "📥 Response received`n" -ForegroundColor Green

    if ($response.token) {
        Write-Host "✅ SUCCESS! API Key is valid" -ForegroundColor Green
        Write-Host "🎉 You can now use Paymob payment`n" -ForegroundColor Green

        $tokenPreview = $response.token.Substring(0, [Math]::Min(50, $response.token.Length))
        Write-Host "🎫 Token: $tokenPreview..." -ForegroundColor Cyan

        Write-Host "`n📝 Next steps:" -ForegroundColor Yellow
        Write-Host "   1. Open: lib\core\config\api_config.dart" -ForegroundColor White
        Write-Host "   2. Update line ~94 with this API Key" -ForegroundColor White
        Write-Host "   3. Run: flutter clean && flutter pub get && flutter run" -ForegroundColor White
    }
    else {
        Write-Host "⚠️  Unexpected response format" -ForegroundColor Yellow
        Write-Host ($response | ConvertTo-Json -Depth 5)
    }
}
catch {
    $errorResponse = $_.ErrorDetails.Message

    Write-Host "❌ FAILED: Authentication Error`n" -ForegroundColor Red

    if ($errorResponse -match "incorrect credentials") {
        Write-Host "💡 The API Key is incorrect or expired`n" -ForegroundColor Yellow
        Write-Host "Solutions:" -ForegroundColor Cyan
        Write-Host "   1. Login to: https://accept.paymob.com/portal2/en/login" -ForegroundColor White
        Write-Host "   2. Go to: Settings → Account Info" -ForegroundColor White
        Write-Host "   3. Copy the API Key" -ForegroundColor White
        Write-Host "   4. If it doesn't work, click 'Regenerate' to get a new key" -ForegroundColor White
        Write-Host "   5. Make sure you're in LIVE mode (not Test mode)`n" -ForegroundColor White
    }
    elseif ($_.Exception.Response.StatusCode -eq 403) {
        Write-Host "💡 Access Forbidden (403)`n" -ForegroundColor Yellow
        Write-Host "   Your account might not have the required permissions" -ForegroundColor White
    }
    else {
        Write-Host "Error details: $errorResponse" -ForegroundColor Red
    }
}

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "✅ Test completed`n" -ForegroundColor Green

# Example usage
Write-Host "📝 Example usage:" -ForegroundColor Yellow
Write-Host '   .\Test-PaymobKey.ps1 -ApiKey "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJ..."' -ForegroundColor Gray

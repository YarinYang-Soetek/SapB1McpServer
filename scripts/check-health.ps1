[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try {
    $res = Invoke-RestMethod -Uri "http://localhost:5005/health" -TimeoutSec 3
    Write-Host "[OK] Health Response:" -ForegroundColor Green
    $res | ConvertTo-Json
} catch {
    Write-Host "[FAIL] Unable to connect: $($_.Exception.Message)" -ForegroundColor Yellow
}

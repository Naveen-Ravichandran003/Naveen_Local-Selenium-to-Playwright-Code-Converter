# CODEVERSE Launcher
Write-Host "🚀 Launching CodeVerse Converter..." -ForegroundColor Cyan

# Check if Ollama is running
try {
    $null = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -ErrorAction Stop
    Write-Host "✅ Ollama connected." -ForegroundColor Green
}
catch {
    Write-Host "❌ Ollama not detected at http://localhost:11434" -ForegroundColor Red
    Write-Host "Please start Ollama and try again." -ForegroundColor Yellow
    exit
}

# Start the proxy server in a new window
Write-Host "📡 Starting proxy server..." -ForegroundColor Gray
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File .\tools\server.ps1" -WindowStyle Hidden

# Give the server a second to start
Start-Sleep -Seconds 2

# Open the UI
$Url = "http://localhost:8081"
Write-Host "🌐 Opening UI at $Url" -ForegroundColor Green
Start-Process $Url

Write-Host "💡 All systems operational!" -ForegroundColor Gray

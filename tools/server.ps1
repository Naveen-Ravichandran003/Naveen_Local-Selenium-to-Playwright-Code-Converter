$port = 8081
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "🚀 CODEVERSE Proxy Server started on http://localhost:$port" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop." -ForegroundColor Gray

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath
        
        if ($path -eq "/" -or $path -eq "/index.html") {
            $content = [System.IO.File]::ReadAllText("$pwd/index.html", [System.Text.Encoding]::UTF8)
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        elseif ($path -eq "/index.css") {
            $content = [System.IO.File]::ReadAllText("$pwd/index.css", [System.Text.Encoding]::UTF8)
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentType = "text/css; charset=utf-8"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        elseif ($path -eq "/api/convert" -and $request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream)
            $body = $reader.ReadToEnd()
            $reader.Close()

            $InputData = $body | ConvertFrom-Json
            
            $TargetLang = "typescript"
            if ($InputData.target_lang) { $TargetLang = $InputData.target_lang }
            
            $TmpFile = ".tmp/ui_input.txt"
            if (-not (Test-Path ".tmp")) { New-Item -ItemType Directory -Path ".tmp" | Out-Null }
            [System.IO.File]::WriteAllText($TmpFile, $InputData.source_code)
            
            $ResJson = powershell -ExecutionPolicy Bypass -File .\tools\main_converter.ps1 -SourcePath $TmpFile -TargetLang $TargetLang
            
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($ResJson)
            $response.ContentType = "application/json"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
}
finally {
    $listener.Stop()
}

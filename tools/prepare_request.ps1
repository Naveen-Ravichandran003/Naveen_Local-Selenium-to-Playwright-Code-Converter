param($SourcePath, $TargetLang = "typescript")
$Model = "tinyllama:latest"
$Src = Get-Content -Raw -Path $SourcePath
$Pfx = "Convert Selenium Java to Playwright $TargetLang. Use async/await.`n`nSource Code:`n"
$Pmt = $Pfx + $Src
$Body = @{ model = $Model; prompt = $Pmt; stream = $false }
$Json = $Body | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText("$pwd/.tmp/request.json", $Json)

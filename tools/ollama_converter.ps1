param($SourcePath, $TargetLang = 'typescript')

$Url = 'http://localhost:11434/api/generate'
$TagsUrl = 'http://localhost:11434/api/tags'

$Model = 'tinyllama:latest'
try {
    $Tags = (Invoke-RestMethod -Uri $TagsUrl).models.name
    if ($Tags -contains 'llama3.2:1b') { $Model = 'llama3.2:1b' }
    elseif ($Tags -contains 'llama3.2:3b') { $Model = 'llama3.2:3b' }
}
catch { }

$Src = Get-Content -Raw -Path $SourcePath
$Pmt = @"
You are an expert QA Automation Engineer.
Task: Convert the provided Selenium Java code to Playwright $TargetLang.
Rules:
1. ONLY output the code. No explanations.
2. Use async/await.
3. Use page.locator() and standard Playwright assertions.

Source Code:
$Src
"@
$Body = @{ model = $Model; prompt = $Pmt; stream = $false; options = @{ temperature = 0 } } | ConvertTo-Json -Compress

try {
    $Res = Invoke-RestMethod -Uri $Url -Method Post -Body $Body -ContentType 'application/json'
    $Out = $Res.response
    if ($Out -match '```(?:\w+)?\s*([\s\S]*?)```') { $Out = $Matches[1] }
    Write-Output $Out
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
}

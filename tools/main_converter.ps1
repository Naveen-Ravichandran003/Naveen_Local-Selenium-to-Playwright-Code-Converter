param($SourcePath, $TargetLang = 'typescript', $ProjectName = 'converted_playwright_test')

$BaseDir = "$pwd/$ProjectName"
if (-not (Test-Path $BaseDir)) { 
    New-Object -TypeName PSObject
    New-Item -ItemType Directory -Path $BaseDir | Out-Null 
    
    # Create package.json
    $PkgJson = @{
        name            = $ProjectName
        version         = "1.0.0"
        devDependencies = @{ "@playwright/test" = "^1.40.0" }
        scripts         = @{ test = "npx playwright test" }
    } | ConvertTo-Json
    [System.IO.File]::WriteAllText("$BaseDir/package.json", $PkgJson)

    # Create playwright.config.ts
    $PwConfig = @"
import { defineConfig, devices } from '@playwright/test';
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  reporter: 'html',
  use: { trace: 'on-first-retry', screenshot: 'only-on-failure' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
"@
    [System.IO.File]::WriteAllText("$BaseDir/playwright.config.ts", $PwConfig)

    # Create tsconfig.json
    $TsConfig = @"
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "CommonJS",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "types": ["node", "@playwright/test"]
  },
  "include": ["tests/**/*.ts", "playwright.config.ts"]
}
"@
    [System.IO.File]::WriteAllText("$BaseDir/tsconfig.json", $TsConfig)
}

$TestsDir = "$BaseDir/tests"
if (-not (Test-Path $TestsDir)) { New-Item -ItemType Directory -Path $TestsDir | Out-Null }

if (-not (Test-Path $SourcePath)) { exit 1 }
$Src = Get-Content -Raw -Path $SourcePath

$Model = 'tinyllama:latest'
try {
    $Tags = (Invoke-RestMethod -Uri 'http://localhost:11434/api/tags').models.name
    if ($Tags -contains 'llama3.2:3b') { $Model = 'llama3.2:3b' }
    elseif ($Tags -contains 'llama3.2:1b') { $Model = 'llama3.2:1b' }
}
catch { }

$Pmt = @"
You are a Senior Playwright Automation Engineer. 
Task: Convert Selenium Java to Clean, Idiomatic Playwright $TargetLang.

MENTAL MODEL SHIFT (Selenium -> Playwright):
- Driver-based -> Fixture-based (Use { page })
- Manual waits -> Auto-wait & Smart Assertions
- Fragile locators -> Smart locators (page.locator)
- Boilerplate -> Lean & Fast

STRICT CONVERSION RULES:
1. NEVER use `chromium.launch()`, `browser.close()`, or manual setup inside tests. Playwright manages this via fixtures.
2. ALWAYS use the `({ page })` fixture.
3. NEVER use `maximizeWindow()`. If requested, ignore it or set viewport in config.
4. NEVER use hard sleeps like `Thread.sleep()` or `setTimeout`. Use Playwright's auto-waiting.
5. Navigation: Ensure `page.goto()` occurs BEFORE any element interactions.
6. Mappings:
   - .sendKeys("text") -> await locator.fill("text")
   - .submit() -> await locator.press("Enter")
   - .click() -> await locator.click()
   - driver.get("url") -> await page.goto("url")
   - driver.findElement(By.name("q")) -> page.locator('[name="q"]')
7. Assertions: Use web-first assertions like `await expect(page).toHaveTitle(/value/)` or `await expect(locator).toBeVisible()`.

PERFECT EXAMPLE:
Source (Selenium):
WebDriver driver = new ChromeDriver();
driver.get("https://google.com");
driver.findElement(By.name("q")).sendKeys("Playwright");
driver.findElement(By.name("q")).submit();
driver.quit();

Target (Playwright):
import { test, expect, Page } from '@playwright/test';

test('Google search', async ({ page }: { page: Page }) => {
  await page.goto('https://www.google.com');
  const searchBox = page.locator('[name="q"]');
  await searchBox.fill('Playwright');
  await searchBox.press('Enter');
  await expect(page).toHaveTitle(/Playwright/);
});

Source Code to Convert:
$Src
"@

$ReqBody = @{ 
    model   = $Model
    prompt  = $Pmt
    stream  = $false
    options = @{ temperature = 0 }
}
$JsonBody = $ReqBody | ConvertTo-Json -Depth 10 -Compress

try {
    $Res = Invoke-RestMethod -Uri 'http://localhost:11434/api/generate' -Method Post -Body $JsonBody -ContentType 'application/json'
    $Code = $Res.response
    if ($Code -match '```(?:\w+)?\s*([\s\S]*?)```') { $Code = $Matches[1] }
    
    # If no backticks found and output looks like conversational text, it might be a refusal
    # But with temperature 0 and strict prompt, it should be fine.
    # Trim content
    $Code = $Code.Trim()

    $Ext = 'spec.js'
    if ($TargetLang -eq 'typescript') { $Ext = 'spec.ts' }
    $Path = "$TestsDir/test.$Ext"
    [System.IO.File]::WriteAllText($Path, $Code)

    @{ status = 'success'; path = $Path; model = $Model; converted_code = $Code } | ConvertTo-Json
}
catch {
    @{ status = 'error'; msg = $_.Exception.Message } | ConvertTo-Json
}

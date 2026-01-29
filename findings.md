## Discoveries
- Project initiated following BLAST protocol.
- Conversion requires mapping TestNG annotations to Playwright hooks.
- Selenium `WebDriver` actions map to Playwright `Locator` actions.
- TestNG `Assert` needs mapping to Playwright `expect()`.

## Mapping Patterns
| Selenium (Java/TestNG) | Playwright (JS/TS) |
| :--- | :--- |
| `@Test` | `test('name', async ({ page }) => { ... })` |
| `@BeforeMethod` | `test.beforeEach(async ({ page }) => { ... })` |
| `@AfterMethod` | `test.afterEach(async ({ page }) => { ... })` |
| `driver.get(url)` | `await page.goto(url)` |
| `driver.findElement(By.id("id"))` | `page.locator('#id')` |
| `element.sendKeys("val")` | `await locator.fill("val")` |
| `element.click()` | `await locator.click()` |
| `Assert.assertEquals(act, exp)` | `expect(act).toBe(exp)` |

## Constraints
- Target: Selenium Java
- Output: Playwright with Javascript/Typescript
- Source: UI Input
- **Local environment:** 2.2 GiB available RAM.
- **Model selection:** `llama3.2:3b` requires 2.7 GiB (fails). Attempting `llama3.2:1b` (1.3 GiB) or `tinyllama:latest` (637 MiB).
- **Execution:** PowerShell selected for local tooling due to absence of Node.js/Python in PATH.

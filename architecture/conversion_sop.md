# SOP: Selenium Java to Playwright Conversion (via Ollama)

## Objective
Convert Selenium Java (TestNG) code into Playwright (JS/TS) using the local Ollama LLM (`llama3.2:3b`).

## Input
- RAW Java Source Code (TestNG annotations, Selenium WebDriver commands).

## Conversion Logic (Layer 2)
1.  **Preprocessing:** Clean the input code (remove unnecessary imports/comments if they clutter the prompt).
2.  **Prompt Engineering:**
    - Role: Expert QA Automation Engineer.
    - Instructions: 
        - Convert TestNG `@Test`, `@BeforeMethod`, `@AfterMethod` to Playwright `test`, `beforeEach`, `afterEach`.
        - Map `By` locators to `page.locator()`.
        - Map `sendKeys` to `fill()`, `click` to `click()`.
        - Ensure `async/await` is used correctly.
        - Prioritize readability and idiomatic Playwright.
3.  **Refinement:** Post-process the LLM output to extract code blocks and ensure basic syntax correctness.

## Output
- Valid `.spec.js` or `.spec.ts` file content.
- Log of the conversion process.

## Edge Cases
- **Custom Utility Classes:** If the Java code uses custom wrappers, the LLM should attempt to inline the logic or flag it.
- **Complexity:** Extremely long files should be chunked if they exceed local context windows.

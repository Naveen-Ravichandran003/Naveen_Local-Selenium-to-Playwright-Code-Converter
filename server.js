const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs-extra');
const axios = require('axios');

const app = express();
const PORT = 8082;

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// API endpoint for conversion
app.post('/api/convert', async (req, res) => {
    const { source_code, target_lang = 'typescript' } = req.body;

    if (!source_code) {
        return res.status(400).json({ status: 'error', msg: 'No source code provided' });
    }

    try {
        const result = await performConversion(source_code, target_lang);
        res.json(result);
    } catch (error) {
        console.error('Conversion error:', error);
        res.status(500).json({ status: 'error', msg: error.message });
    }
});

async function performConversion(sourceCode, targetLang) {
    const projectName = 'converted_playwright_test';
    const baseDir = path.join(__dirname, projectName);
    const testsDir = path.join(baseDir, 'tests');

    // Ensure directory structure
    if (!fs.existsSync(baseDir)) {
        await fs.ensureDir(baseDir);

        // package.json for generated project
        await fs.writeJson(path.join(baseDir, 'package.json'), {
            name: projectName,
            version: "1.0.0",
            devDependencies: { "@playwright/test": "^1.40.0" },
            scripts: { test: "npx playwright test" }
        }, { spaces: 2 });

        // playwright.config.ts
        const pwConfig = `import { defineConfig, devices } from '@playwright/test';
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  reporter: 'html',
  use: { trace: 'on-first-retry', screenshot: 'only-on-failure' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});`;
        await fs.writeFile(path.join(baseDir, 'playwright.config.ts'), pwConfig);

        // tsconfig.json
        const tsConfig = `{
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
}`;
        await fs.writeFile(path.join(baseDir, 'tsconfig.json'), tsConfig);
    }

    await fs.ensureDir(testsDir);

    // Get model info from Ollama
    let model = 'tinyllama:latest';
    try {
        const tagsRes = await axios.get('http://localhost:11434/api/tags');
        const models = tagsRes.data.models.map(m => m.name);
        if (models.includes('llama3.2:1b')) model = 'llama3.2:1b';
        else if (models.includes('llama3.2:3b')) model = 'llama3.2:3b';
        else if (models.includes('tinyllama:latest')) model = 'tinyllama:latest';
    } catch (e) {
        console.warn('Ollama not reachable, using default model mapping');
    }

    const prompt = `### Role
You are a Senior Playwright Automation Engineer.
### Task
Convert the provided Selenium Java (TestNG) code into modern, idiomatic Playwright TypeScript.

### STRICT RULES:
1. Use Playwright Test runner style: test('description', async ({ page }) => { ... });
2. Import correctly: import { test, expect } from '@playwright/test';
3. Use page.goto() for navigation.
4. Use page.locator('selector') and perform actions: .fill(), .click().
5. Use web-first assertions: await expect(page).toHaveTitle('...'), await expect(locator).toBeVisible().
6. NO manual browser launching. NO decorators like @Test.
7. Wrap tests in test.describe if multiple tests are found.

### Example Conversion:
#### Input (Selenium):
@Test
public void loginTest() {
    driver.get("url");
    driver.findElement(By.id("u")).sendKeys("user");
    Assert.assertEquals(driver.getTitle(), "Home");
}
#### Output (Playwright):
test('login test', async ({ page }) => {
    await page.goto('url');
    await page.locator('#u').fill('user');
    await expect(page, "Should have correct title").toHaveTitle('Home');
});

### Code to Convert:
${sourceCode}`;

    const generateRes = await axios.post('http://localhost:11434/api/generate', {
        model: model,
        prompt: prompt,
        stream: false,
        options: { temperature: 0 }
    });

    let code = generateRes.data.response.trim();
    const codeMatch = code.match(/```(?:\w+)?\s*([\s\S]*?)```/);
    if (codeMatch) code = codeMatch[1].trim();

    const ext = targetLang === 'typescript' ? 'spec.ts' : 'spec.js';
    const filePath = path.join(testsDir, `test.${ext}`);
    await fs.writeFile(filePath, code);

    return {
        status: 'success',
        path: filePath,
        model: model,
        converted_code: code
    };
}

app.listen(PORT, () => {
    console.log(`\x1b[36m🚀 Node.js Server started on http://localhost:${PORT}\x1b[0m`);
    console.log(`Press Ctrl+C to stop.`);
});

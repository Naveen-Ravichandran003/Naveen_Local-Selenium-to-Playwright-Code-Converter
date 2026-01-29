import { test, expect } from '@playwright/test';

test('login test', async ({ page }) => {
  await page.goto('https://example.com/login');
  const usernameInput = page.locator('#username');
  const passwordInput = page.locator('#password');
  const loginButton = page.locator('#loginBtn');

  await usernameInput.fill('testuser');
  await passwordInput.fill('password123');
  await loginButton.click();

  const expectedTitle = 'Dashboard';
  const actualTitle = await page.title();
  expect(actualTitle).toBe(expectedTitle, "Login Failed!");
});
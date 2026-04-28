// @ts-check
import { test, expect } from '@playwright/test';

function requiredEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Missing required env var: ${name}`);
  return v;
}

async function loginToApex(page) {
  const loginUrl = requiredEnv('APEX_LOGIN_URL');
  const workspace = requiredEnv('APEX_WORKSPACE');
  const username = requiredEnv('APEX_USERNAME');
  const password = requiredEnv('APEX_PASSWORD');

  await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

  // Prefer accessibility-based selectors (APEX often has hidden *LABEL inputs).
  const workspaceInput = page.getByRole('textbox', { name: /^workspace$/i });
  const userInput = page.getByRole('textbox', { name: /^database username$/i });
  const passInput = page.getByRole('textbox', { name: /^password$/i });

  await workspaceInput.fill(workspace);
  await userInput.fill(username);
  await passInput.fill(password);

  await Promise.all([
    page.waitForLoadState('networkidle').catch(() => {}),
    page.getByRole('button', { name: /sign in|log in|login/i }).first().click().catch(async () => {
      await page.locator('button[type="submit"], input[type="submit"]').first().click();
    }),
  ]);
}

test.describe('APEX user administration', () => {
  test('create user', async ({ page }) => {
    await loginToApex(page);

    const createUserUrl = requiredEnv('APEX_CREATE_USER_URL');
    const newUsername = requiredEnv('APEX_NEW_USER_USERNAME');
    const newEmail = process.env.APEX_NEW_USER_EMAIL ?? '';
    const newPassword = requiredEnv('APEX_NEW_USER_PASSWORD');

    await page.goto(createUserUrl, { waitUntil: 'domcontentloaded' });

    // These are intentionally label/placeholder driven so you can adapt quickly.
    await page.getByLabel(/username/i).fill(newUsername);
    if (newEmail) await page.getByLabel(/email/i).fill(newEmail);
    await page.getByLabel(/^password$/i).fill(newPassword).catch(async () => {
      await page.getByLabel(/password/i).fill(newPassword);
    });

    await page.getByRole('button', { name: /create|save|add/i }).click();

    // Basic success signal; customize for your APEX page (success message or redirect).
    await expect(page.getByText(/success|created|saved/i)).toBeVisible({ timeout: 30_000 });
  });

  test('unlock user', async ({ page }) => {
    await loginToApex(page);

    const unlockUserUrl = requiredEnv('APEX_UNLOCK_USER_URL');
    const targetUsername = requiredEnv('APEX_TARGET_USERNAME');

    await page.goto(unlockUserUrl, { waitUntil: 'domcontentloaded' });

    // Common pattern: search user then click unlock.
    await page.getByLabel(/username|user/i).fill(targetUsername);
    await page.getByRole('button', { name: /search|find|go/i }).click().catch(() => {});
    await page.getByRole('button', { name: /unlock/i }).click();

    await expect(page.getByText(/success|unlocked|updated/i)).toBeVisible({ timeout: 30_000 });
  });

  test('change password', async ({ page }) => {
    await loginToApex(page);

    const changePasswordUrl = requiredEnv('APEX_CHANGE_PASSWORD_URL');
    const targetUsername = requiredEnv('APEX_TARGET_USERNAME');
    const newPassword = requiredEnv('APEX_TARGET_NEW_PASSWORD');

    await page.goto(changePasswordUrl, { waitUntil: 'domcontentloaded' });

    await page.getByLabel(/username|user/i).fill(targetUsername);
    await page.getByLabel(/new password/i).fill(newPassword);
    await page.getByLabel(/confirm password/i).fill(newPassword).catch(() => {});

    await page.getByRole('button', { name: /change|reset|save|update/i }).click();

    await expect(page.getByText(/success|changed|updated/i)).toBeVisible({ timeout: 30_000 });
  });
});


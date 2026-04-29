import 'dotenv/config';

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var: ${name}`);
  return value;
}

export async function createUserFromEnv(page) {
  const loginUrl = requiredEnv('APEX_LOGIN_URL');
  const workspace = requiredEnv('APEX_WORKSPACE');
  const username = requiredEnv('APEX_USERNAME');
  const password = requiredEnv('APEX_PASSWORD');

  const newUserUsername = requiredEnv('APEX_NEW_USER_USERNAME');
  const newUserEmail = requiredEnv('APEX_NEW_USER_EMAIL');
  const newUserPassword = requiredEnv('APEX_NEW_USER_PASSWORD');

  await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

  // Prefer tolerant selectors (labels/casing can vary by APEX version/theme).
  const workspaceInput = page.getByRole('textbox', { name: /^workspace$/i });
  const userInput = page.getByRole('textbox', { name: /^database username$/i });
  const passInput = page.getByRole('textbox', { name: /^password$/i });

  await workspaceInput.fill(workspace);
  await userInput.fill(username);
  await passInput.fill(password);

  await Promise.all([
    // APEX sometimes does not do a full navigation; this keeps us safe in both cases.
    page.waitForLoadState('networkidle').catch(() => {}),
    page.getByRole('button', { name: /sign in|log in|login/i }).first().click().catch(async () => {
      await page.locator('button[type="submit"], input[type="submit"]').first().click();
    }),
  ]);


    await page.getByRole('button', { name: 'Administration' }).click();
    await page.getByRole('menuitem', { name: 'Manage Users and Groups' }).click();
    await page.getByRole('button', { name: 'Create User ' }).click();

  await page.locator('input#F4350_P52_USER_NAME').fill(newUserUsername);

  // Optional email on some APEX pages; only fill if present.
  await page.locator('input#F4350_P52_EMAIL_ADDRESS').fill(newUserEmail).catch(() => {});

  await page
    .locator('input#F4350_P52_WEB_PASSWORD')
    .fill(newUserPassword)
    .catch(async () => {
      await page.locator('input#F4350_P52_WEB_PASSWORD').first().fill(newUserPassword);
    });

  await page.locator('input#F4350_P52_PASSWD_CONFIRM').fill(newUserPassword).catch(() => {});

  await page.locator('button#B63568042920578435').click();
}
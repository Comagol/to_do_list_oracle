import 'dotenv/config';

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var: ${name}`);
  return value;
}

export async function unlockUserFromEnv(page) {
  const loginUrl = requiredEnv('APEX_LOGIN_URL');
  const workspace = requiredEnv('APEX_WORKSPACE');
  const username = requiredEnv('APEX_USERNAME');
  const password = requiredEnv('APEX_PASSWORD');

  const targetUsername = requiredEnv('APEX_TARGET_USERNAME');

    //go to the login page
    await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

    //get the workspace, username, and password inputs
    const workspaceInput = page.getByRole('textbox', { name: /^workspace$/i });
    const userInput = page.getByRole('textbox', { name: /^database username$/i });
    const passInput = page.getByRole('textbox', { name: /^password$/i });


    //fill the workspace, username, and password
    await workspaceInput.fill(workspace);
    await userInput.fill(username);
    await passInput.fill(password);

    //click the sign in button
    await Promise.all([
        page.waitForLoadState('networkidle').catch(() => {}),
        page.getByRole('button', { name: /sign in|log in|login/i }).first().click().catch(async () => {
            await page.locator('button[type="submit"], input[type="submit"]').first().click();
        }),
    ]);

    //click the administration button
    await page.getByRole('button', { name: 'Administration' }).click();

    //click the manage users and groups button
    await page.getByRole('menuitem', { name: 'Manage Users and Groups' }).click();

    //click the specific user link
    await page.getByRole('link', { name: targetUsername }).click();

    //select the account availability option
    await page.getByLabel('Account Availability', { exact: true }).selectOption('N');

    //click the apply changes button
    await page.getByRole('button', { name: 'Apply Changes' }).click();
}





/**
 * 
 * //this is the code generated with playwright codegen
 * import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('https://g72e895f580b78d-du9gypcf1cci20nt.adb.sa-saopaulo-1.oraclecloudapps.com/ords/r/apex/workspace-sign-in/oracle-apex-sign-in?session=116203985086840');
  await page.getByRole('textbox', { name: 'Workspace' }).click();
  await page.getByRole('textbox', { name: 'Workspace' }).press('CapsLock');
  await page.getByRole('textbox', { name: 'Workspace' }).fill('*******');
  await page.getByRole('textbox', { name: 'Workspace' }).press('Tab');
  await page.getByRole('textbox', { name: 'Database Username' }).fill('*******');
  await page.getByRole('textbox', { name: 'Database Username' }).press('Tab');
  await page.getByRole('textbox', { name: 'Password' }).fill('*******');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.getByRole('button', { name: 'Administration' }).click();
  await page.getByRole('menuitem', { name: 'Manage Users and Groups' }).click();
  await page.getByRole('link', { name: '*******' }).click();
  await page.getByLabel('Account Availability', { exact: true }).selectOption('Y');
  await page.getByLabel('Account Availability', { exact: true }).selectOption('N');
  await page.getByRole('button', { name: 'Apply Changes' }).click();
});
 */
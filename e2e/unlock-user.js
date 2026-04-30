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


    await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

    //fill the workspace, username, and password
    await page.locator('input#F4350_P52_WORKSPACE').fill(workspace);
    await page.locator('input#F4350_P52_USER_NAME').fill(username);
    await page.locator('input#F4350_P52_WEB_PASSWORD').fill(password);
    await page.locator('button#B63568042920578435').click();
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
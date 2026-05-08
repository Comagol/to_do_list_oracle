import 'dotenv/config';
import { expect } from '@playwright/test';

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var: ${name}`);
  return value;
}

export async function createTableFromEnv(page) {
  const loginUrl = requiredEnv('APEX_LOGIN_URL');
  const workspace = requiredEnv('APEX_WORKSPACE');
  const username = requiredEnv('APEX_USERNAME');
  const password = requiredEnv('APEX_PASSWORD');

  const tableName = requiredEnv('APEX_TABLE_NAME');
  const appName = requiredEnv('APEX_APP_NAME');
  //go to login page
  await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

  //fill workspace, username, and password
  await page.getByRole('textbox', { name: 'Workspace' }).fill(workspace);
  await page.getByRole('textbox', { name: 'Database Username' }).fill(username);
  await page.getByRole('textbox', { name: 'Password' }).fill(password);

  //click sign in button
  await page.getByRole('button', { name: 'Sign In' }).click();

  //search and click on the app
  await page.getByRole('link', { name: appName }).click();

  //click on button to create a new page
  // Use the stable APEX button id for this action.
  const newPageBtn = page.locator('#NEW_PAGE');
  await expect(newPageBtn).toBeVisible();
  await newPageBtn.scrollIntoViewIfNeeded();
  await newPageBtn.click();

  // APEX opens the wizard as a jQuery UI modal dialog containing an iframe.
  // Wait for the dialog container + iframe to appear (more reliable than waiting on the iframe alone).
  const wizardIframe = page.locator('div.ui-dialog--apex iframe[title="Create a Page"]');
  await expect(wizardIframe).toBeVisible({ timeout: 60_000 });

  // Interact with the iframe contents.
  const wizardFrame = page.frameLocator('div.ui-dialog--apex iframe[title="Create a Page"]');
  await wizardFrame.locator('body').waitFor({ state: 'visible', timeout: 60_000 });

  // Select the page type (Form) so the "Name" step appears.
  // Prefer a stable icon class if present; fallback to text-based selection.
  const formTile = wizardFrame.locator('.a-Icon.icon-region-page-form').first();
  if (await formTile.count()) {
    await formTile.click();
  } else {
    // Depending on APEX version/theme, the tile might be a card/link/button.
    await wizardFrame.getByRole('link', { name: /^form$/i }).first().click().catch(async () => {
      await wizardFrame.getByText(/^form$/i).first().click();
    });
  }

  await wizardFrame.getByRole('textbox', { name: /name/i }).fill('form');
  /* Continue wizard here once the steps match your app:
  await wizardFrame.getByRole('combobox', { name: /table \/ view name/i }).fill(tableName);
  await wizardFrame.getByRole('button', { name: /next/i }).click();
  */
}

//import { test, expect } from '@playwright/test';
/*
comment all steps in the test below
test('test', async ({ page }) => {
  await page.goto('https://g72e895f580b78d-du9gypcf1cci20nt.adb.sa-saopaulo-1.oraclecloudapps.com/ords/r/apex/workspace-sign-in/oracle-apex-sign-in?session=114647267361122');
  await page.getByRole('textbox', { name: 'Workspace' }).click();
  await page.getByRole('textbox', { name: 'Workspace' }).fill('*******************');
  await page.getByText('Workspace Database Username').click();
  await page.getByRole('textbox', { name: 'Database Username' }).click();
  await page.getByRole('textbox', { name: 'Database Username' }).fill('*******************');
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).click();
  await page.getByRole('textbox', { name: 'Password' }).fill('*******************');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.getByRole('link', { name: 'Automatic Invoice Handling' }).click();
  await page.getByRole('button', { name: 'Create Page' }).click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().locator('.a-Icon.icon-region-.page-form').click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('textbox', { name: 'Name' }).fill('form');
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('textbox', { name: 'Name' }).press('Tab');
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('combobox', { name: 'Table / View Name' }).click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('combobox', { name: 'Table / View Name' }).fill('table-pass-by-parameter');
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('switch', { name: 'Use Navigation' }).uncheck();
  await page.locator('iframe[title="Create a Page"]').contentFrame().locator('.a-Switch-toggle').first().click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('button', { name: 'Next ' }).click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().locator('#P2501_TABLE_NAME_lov_btn').click();
  await page.getByRole('textbox', { name: 'Search' }).click();
  await page.getByRole('textbox', { name: 'Search' }).fill('table-eter');
  await page.getByRole('textbox', { name: 'Search' }).click();
  await page.getByRole('button', { name: 'Search', exact: true }).click();
  await page.locator('.ui-dialog.ui-dialog-popuplov > .ui-resizable-handle.ui-resizable-e').click();
  await page.getByRole('option', { name: 'table-pass-by-parameter' }).click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('button', { name: 'Next ' }).click();
  await page.locator('iframe[title="Create a Page"]').contentFrame().getByRole('button', { name: 'Create Page' }).click();
});
*/
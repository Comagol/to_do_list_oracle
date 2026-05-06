import 'dotenv/config';

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required env var: ${name}`);
  return value;
}


//import { test, expect } from '@playwright/test';

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
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
  const pageName = requiredEnv('APEX_PAGE_NAME');
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

  // Open Create Page wizard: some skins expose #NEW_PAGE; others only expose the toolbar button.
  const newPageById = page.locator('#NEW_PAGE');
  const newPageByRole = page
    .getByRole('region', { name: /buttons next to search bar of pages/i })
    .getByRole('button', { name: /^create page$/i });

  if ((await newPageById.count()) > 0 && (await newPageById.isVisible())) {
    await newPageById.scrollIntoViewIfNeeded();
    await newPageById.click();
  } else {
    await expect(newPageByRole).toBeVisible();
    await newPageByRole.scrollIntoViewIfNeeded();
    await newPageByRole.click();
  }

  // Wizard iframe title can be "Create a Page", later steps may use other titles — match any iframe in the APEX dialog.
  const wizardIframe = page.locator('div.ui-dialog--apex .ui-dialog-content iframe').first();
  await expect(wizardIframe).toBeVisible({ timeout: 60_000 });

  const wizardFrame = page.frameLocator('div.ui-dialog--apex .ui-dialog-content iframe').first();
  await wizardFrame.locator('body').waitFor({ state: 'visible', timeout: 60_000 });

  // Select page type "Form" (APEX IconList: li with data-value matches the page type).
  const formOption = wizardFrame.locator('li[data-value="FORM"]');
  await formOption.waitFor({ state: 'visible', timeout: 30_000 });
  await formOption.click();

  // Page title — use exact "Name" (regex /name/i matches Table / View Name too).
  await wizardFrame.getByRole('textbox', { name: 'Name', exact: true }).fill(pageName);

  // Table / View Name: open LOV. "Table / View Name" appears twice (e.g. Local DB vs REST) — use the first (local) row.
  await wizardFrame
    .getByRole('combobox', { name: 'Table / View Name', exact: true })
    .first()
    .locator('xpath=following-sibling::button[contains(@class,"a-Button--popupLOV")]')
    .click();

  const lovDlg = page.locator('.ui-dialog.ui-dialog-popuplov');
  await lovDlg.getByRole('textbox', { name: 'Search' }).fill(tableName);
  await lovDlg.getByRole('button', { name: 'Search', exact: true }).click();
  await lovDlg.locator(`li[data-id="${tableName}"][role="option"]`).click();
  await wizardFrame.getByRole('button', { name: 'Next ' }).click();
  await wizardFrame.getByRole('button', { name: 'Create Page' }).click();
  await page.waitForTimeout(10000);
}
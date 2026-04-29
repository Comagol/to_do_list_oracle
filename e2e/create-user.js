import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('https://g72e895f580b78d-du9gypcf1cci20nt.adb.sa-saopaulo-1.oraclecloudapps.com/ords/r/apex/workspace-sign-in/oracle-apex-sign-in?session=103293202757293');
  await page.getByRole('textbox', { name: 'Workspace' }).click();
  await page.getByRole('textbox', { name: 'Workspace' }).fill('comagol');
  await page.getByRole('textbox', { name: 'Workspace' }).press('Tab');
  await page.getByRole('textbox', { name: 'Database Username' }).click();
  await page.getByRole('textbox', { name: 'Database Username' }).fill('admin_user');
  await page.getByRole('textbox', { name: 'Database Username' }).press('Tab');
  await page.getByRole('textbox', { name: 'Password' }).fill('Cleopatra991');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.getByRole('button', { name: 'Administration' }).click();
  await page.getByRole('menuitem', { name: 'Manage Users and Groups' }).click();
  await page.getByRole('button', { name: 'Create User ' }).click();
  await page.getByRole('textbox', { name: 'Username' }).fill('pepito');
  await page.getByRole('textbox', { name: 'Username' }).press('Tab');
  await page.getByRole('textbox', { name: 'Email Address' }).fill('pepito@gmail.com');
  await page.getByRole('textbox', { name: 'Email Address' }).press('Tab');
  await page.getByRole('textbox', { name: 'Password', exact: true }).click();
  await page.getByRole('textbox', { name: 'Password', exact: true }).fill('superpass123');
  await page.getByRole('textbox', { name: 'Password', exact: true }).press('Tab');
  await page.locator('#F4350_P52_WEB_PASSWORD_CONTAINER').getByRole('button', { name: 'Show Password' }).press('Tab');
  await page.getByRole('textbox', { name: 'Confirm Password' }).fill('superpass123');
  await page.getByRole('button', { name: 'Create User' }).click();
});
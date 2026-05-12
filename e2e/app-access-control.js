import 'dotenv/config';
import { expect } from '@playwright/test';

function requiredEnv(name) {
    const value = process.env[name];
    if (!value) throw new Error(`Missing required env var: ${name}`);
    return value;
  }

export async function createAppAccessControlFromEnv(page) {
    const loginUrl = requiredEnv('APEX_LOGIN_URL');
    const workspace = requiredEnv('APEX_WORKSPACE');
    const username = requiredEnv('APEX_USERNAME');
    const password = requiredEnv('APEX_PASSWORD');

    const appName = requiredEnv('APEX_APP_NAME');

    //go to the login page
    await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

    //fill the workspace, username, and password
    await page.getByRole('textbox', { name: 'Workspace' }).fill(workspace);
    await page.getByRole('textbox', { name: 'Database Username' }).fill(username);
    await page.getByRole('textbox', { name: 'Password' }).fill(password);

    //click the sign in button
    await page.getByRole('button', { name: 'Sign In' }).click();

    //search and click on the app
    await page.getByRole('link', { name: appName }).click();


    //search and click on shared components
    await page.getByText('Shared Components').click();

    //search and click on application access control
    await page.getByText('Application Access Control').click();

    //search and click on add user role assignment
    await expect(page.getByText('Add User Role Assignment')).toBeVisible();
    await page.getByText('Add User Role Assignment').click();

    //expect the page to show the popup
    await expect(page.getByText('User Assignment')).toBeVisible();

    //click the apply changes button
    await page.waitForTimeout(10000);
  }
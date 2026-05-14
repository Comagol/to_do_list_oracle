import 'dotenv/config';
import { expect } from '@playwright/test';

function requiredEnv(name) {
    const value = process.env[name];
    if (!value) throw new Error(`Missing required env var: ${name}`);
    return value;
}

export async function deleteUserRoleFromEnv(page) {
    const loginUrl = requiredEnv('APEX_LOGIN_URL');
    const workspace = requiredEnv('APEX_WORKSPACE');
    const username = requiredEnv('APEX_USERNAME');
    const password = requiredEnv('APEX_PASSWORD');

    const appName = requiredEnv('APEX_APP_NAME');
    const userName = requiredEnv('APP_ACCESS_CONTROL_USER_NAME');
    
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

    //search the user name and click on the user
    await page.getByText(userName).click();

    //click on the user dialog
    const userDialog = page.getByRole('dialog', { name: 'User' });
    await expect(userDialog).toBeVisible({ timeout: 30_000 });
    const userFrame = userDialog.frameLocator('iframe');

    //click on the delete role button
    await userFrame.getByRole('button', { name: 'Delete' }).click();

    //click on the ok button
    const okButton = page.getByRole('button', { name: 'OK' });
    await expect(okButton).toBeVisible({ timeout: 30_000 });
    await okButton.click();

    await page.waitForTimeout(6000);
}
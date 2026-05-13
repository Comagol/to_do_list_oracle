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
    const appAccessControlUserName = requiredEnv('APP_ACCESS_CONTROL_USER_NAME');
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

    // Region tabs: ensure the assignments panel is active, then click only that panel's button
    // (avoids flaky matches when APEX keeps multiple regions in the DOM or the strip is mid-transition).
    await page.getByRole('tab', { name: 'User Role Assignments' }).click();
    const assignmentsPanel = page.getByRole('tabpanel', { name: 'User Role Assignments' });
    const addAssignment = assignmentsPanel.getByRole('button', { name: 'Add User Role Assignment' });
    await expect(addAssignment).toBeVisible({ timeout: 30_000 });
    await addAssignment.click();

    const assignmentDialog = page.getByRole('dialog', { name: 'User Assignment' });
    await expect(assignmentDialog).toBeVisible({ timeout: 30_000 });
    const assignmentFrame = assignmentDialog.frameLocator('iframe');

    await assignmentFrame.getByRole('textbox', { name: 'User Name', exact: true }).fill(appAccessControlUserName);
    await assignmentFrame.getByRole('checkbox', { name: 'administrator' }).click();
    await assignmentFrame.getByRole('button', { name: 'Create Assignment' }).click();
    await page.waitForTimeout(1000);
  }
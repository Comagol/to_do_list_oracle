import 'dotenv/config';
import { expect } from '@playwright/test';

function requiredEnv(name) {
    const value = process.env[name];
    if (!value) throw new Error(`Missing required env var: ${name}`);
    return value;
}

export async function createRoleFromEnv(page) {
    const loginUrl = requiredEnv('APEX_LOGIN_URL');
    const workspace = requiredEnv('APEX_WORKSPACE');
    const username = requiredEnv('APEX_USERNAME');
    const password = requiredEnv('APEX_PASSWORD');

    const appName = requiredEnv('APEX_APP_NAME');
    const roleName = requiredEnv('APEX_ROLE_NAME');

    //go to the login page
    await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });

    //fill the workspace, username, and password
    await page.getByRole('textbox', { name: 'Workspace' }).fill(workspace);
    await page.getByRole('textbox', { name: 'Database Username' }).fill(username);
    await page.getByRole('textbox', { name: 'Password' }).fill(password);
    
    //click the sign in button
}
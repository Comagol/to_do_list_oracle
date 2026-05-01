import 'dotenv/config';

function requiredEnv(name) {
    const value = process.env[name];
    if (!value) throw new Error(`Missing required env var ${name}`);
    return value;
}

export async function changePasswordFromEnv(page) {
    const loginUrl = requiredEnv('APEX_LOGIN_URL');
    const workspace = requiredEnv('APEX_WORKSPACE');
    const username = requiredEnv('APEX_USERNAME');
    const password = requiredEnv('APEX_PASSWORD');

    const targetUsername = requiredEnv('APEX_TARGET_USERNAME');
    const newPassword = requiredEnv('APEX_TARGET_NEW_PASSWORD');

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
    
    //fill the new password input
    await page.locator('#F4350_P56_WEB_PASSWORD').fill(newPassword);

    //fill the confirm password input
    await page.locator('#"F4350_P56_USER_PASSWORD"').fill(newPassword);

    //click the apply changes button
    await page.getByRole('button', { name: 'Apply Changes' }).click();
}
import { test } from '@playwright/test';
import { addAdminRoleFromEnv } from './add_admin_role.js';

test('add admin role', async ({ page }) => {
    test.setTimeout(90_000);
    await addAdminRoleFromEnv(page);
});
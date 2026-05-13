import { test } from '@playwright/test';
import { createAppAccessControlFromEnv } from './add_admin_role.js';

test('create app access control', async ({ page }) => {
    test.setTimeout(90_000);
    await createAppAccessControlFromEnv(page);
});
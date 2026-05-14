import { test } from '@playwright/test';
import { deleteUserRoleFromEnv } from './delete_user_role.js';

test('delete user role', async ({ page }) => {
    test.setTimeout(60_000);
    await deleteUserRoleFromEnv(page);
});
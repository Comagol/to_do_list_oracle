import { test } from '@playwright/test';
import { createRoleFromEnv } from './create_role.js';

test('create role', async ({ page }) => {
    test.setTimeout(60_000);
    await createRoleFromEnv(page);
});
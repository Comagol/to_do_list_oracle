import { test } from '@playwright/test';
import { changePasswordFromEnv } from './change-password.js';

test('change password (codegen)', async ({ page }) => {
  await changePasswordFromEnv(page);
});
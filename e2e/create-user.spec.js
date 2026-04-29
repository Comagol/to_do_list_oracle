import { test } from '@playwright/test';
import { createUserFromEnv } from './create-user.js';

test('create user (codegen)', async ({ page }) => {
  await createUserFromEnv(page);
});


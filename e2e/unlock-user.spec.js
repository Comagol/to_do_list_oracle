import { test } from '@playwright/test';
import { unlockUserFromEnv } from './unlock-user.js';

test('unlock user (codegen)', async ({page}) => {
  await unlockUserFromEnv(page);
});
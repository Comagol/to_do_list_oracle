import { test } from '@playwright/test';
import { createTableFromEnv } from './tables.js';

test('create table (codegen)', async ({ page }) => {
    await createTableFromEnv(page);
});
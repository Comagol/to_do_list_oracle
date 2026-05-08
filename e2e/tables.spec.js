import { test } from '@playwright/test';
import { createTableFromEnv } from './tables.js';

test('create table (codegen)', async ({ page }) => {
    test.setTimeout(90_000);
    await createTableFromEnv(page);
});
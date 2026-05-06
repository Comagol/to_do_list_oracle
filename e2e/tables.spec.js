import { test } from '@playwright/test';
import { createTableFromEnv } from './create-table.js';

test('create table (codegen)', async ({ page }) => {
    await createTableFromEnv(page);
});
---
name: apex-playwright-admin
description: Automates Oracle APEX workspace admin (create user, unlock user, change password, App Builder create table/form page) with Playwright. Uses .env for login and task inputs. Runnable tests in e2e/*.spec.js; flows in e2e/*.js helpers.
---

# APEX Playwright Admin

## What this skill is for

This project automates **Oracle APEX** with Playwright:

- **Create user** — `e2e/create-user.spec.js` → `e2e/create-user.js` (`createUserFromEnv`)
- **Unlock user** — `e2e/unlock-user.spec.js` → `e2e/unlock-user.js` (`unlockUserFromEnv`)
- **Change password** — `e2e/change-password.spec.js` → `e2e/change-password.js` (`changePasswordFromEnv`)
- **Create table (Form page via App Builder wizard)** — `e2e/tables.spec.js` → `e2e/tables.js` (`createTableFromEnv`)

**Layout**

- `e2e/*.js` — exported async functions: login + UI steps + APEX-specific locators (`id`, `getByRole`, `frameLocator`, etc.).
- `e2e/*.spec.js` — thin Playwright tests that call those functions (this is what `@playwright/test` runs).

Playwright is configured with `testDir: './e2e'` in `playwright.config.js` (repo root).

## Prereqs

- Work from repo root: `to_do_list_oracle/` (the folder that contains `package.json`, `playwright.config.js`, `e2e/`, `.env`).
- Dependencies: `@playwright/test`, `dotenv`, `playwright`.
- Copy env template and fill secrets locally:

```bash
cp .env.example .env
```

## `.env` variables used by the current `e2e` flows

### Shared (login for all flows that sign in)

| Variable | Purpose |
|----------|---------|
| `APEX_LOGIN_URL` | Full URL of the workspace sign-in page |
| `APEX_WORKSPACE` | Workspace name |
| `APEX_USERNAME` | Database username (admin) |
| `APEX_PASSWORD` | Password |

### Create user only (`create-user.js`)

| Variable | Purpose |
|----------|---------|
| `APEX_NEW_USER_USERNAME` | New account username |
| `APEX_NEW_USER_EMAIL` | New account email |
| `APEX_NEW_USER_PASSWORD` | New account password |

The current implementation navigates via the **Administration → Manage Users and Groups** UI (no `APEX_CREATE_USER_URL` needed).

### Unlock user (`unlock-user.js`)

| Variable | Purpose |
|----------|---------|
| `APEX_TARGET_USERNAME` | Username to unlock |

Uses UI navigation after login (no `APEX_UNLOCK_USER_URL` in code).

### Change password (`change-password.js`)

| Variable | Purpose |
|----------|---------|
| `APEX_TARGET_USERNAME` | User whose password changes |
| `APEX_TARGET_NEW_PASSWORD` | New password |

Uses UI navigation after login (no `APEX_CHANGE_PASSWORD_URL` in code).

### Create Form / table page (`tables.js`)

| Variable | Purpose |
|----------|---------|
| `APEX_APP_NAME` | Exact link text of the application to open (App Builder home) |
| `APEX_PAGE_NAME` | New page **Name** in the Create Form wizard |
| `APEX_TABLE_NAME` | Table or view to pick in the **Table / View Name** LOV (`data-id` on the option row, e.g. `EMP`) |

Flow summary in code: sign in → open app by link → **Create Page** (`#NEW_PAGE` or toolbar button) → wait for `div.ui-dialog--apex .ui-dialog-content iframe` → choose **Form** (`li[data-value="FORM"]`) → fill **Name** → open first **Table / View Name** LOV (`.first()` disambiguates Local DB vs REST) → search in `.ui-dialog-popuplov` → click `li[data-id="${APEX_TABLE_NAME}"]` → **Next** / **Create Page**.

`.env.example` may still list URL placeholders for older setups; align your real `.env` with the tables above.

## Running the tasks

Always run commands from **`to_do_list_oracle/`** (repo root).

### npm scripts

```bash
npm run apex:create-user
npm run apex:unlock-user
npm run apex:change-password
npm run apex:create-table
```

### Equivalent Playwright CLI (single browser)

```bash
npx playwright test create-user.spec.js --project=chromium
npx playwright test unlock-user.spec.js --project=chromium
npx playwright test change-password.spec.js --project=chromium
npx playwright test tables.spec.js --project=chromium
```

### Full e2e suite

```bash
npm run test:e2e
```

## Debugging / adapting selectors

1. UI mode:

```bash
npm run test:e2e:ui
```

2. Step through with the Playwright Inspector:

```bash
PWDEBUG=1 npx playwright test create-user.spec.js --project=chromium --headed
```

3. Regenerate snippets from a real session:

```bash
npx playwright codegen "$APEX_LOGIN_URL"
```

4. **Where to edit** when labels or item IDs change: **`e2e/create-user.js`**, **`e2e/unlock-user.js`**, **`e2e/change-password.js`**, **`e2e/tables.js`** — not only the `.spec.js` wrappers.

Oracle APEX often exposes stable **`id`** attributes on inputs (for example `#F4350_P52_USER_NAME`). Prefer those when accessibility labels diverge across themes or browsers. For **App Builder** wizards, item numbers (`P2501_*`) can differ between apps; `tables.js` avoids hardcoding LOV button ids where possible (first **Table / View Name** combobox + following popup LOV button).

## Notes

- Keep `.env` out of git; it contains credentials.
- If a step fails intermittently after login, add explicit waits (`locator.waitFor`, `expect(...).toBeVisible`) against the **next** screen you expect, rather than relying only on `networkidle`.
- `tables.spec.js` may use a longer test timeout; App Builder dialogs and LOVs can be slow.

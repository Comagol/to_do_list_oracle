---
name: apex-playwright-admin
description: Automates Oracle APEX user administration with Playwright using a .env file (workspace, username, password). Use when the user asks to connect to APEX and do repetitive tasks like create a user, unlock a user, or change passwords via Playwright in this repo.
---

# APEX Playwright Admin

## What this skill is for

Use Playwright in this repo to connect to Oracle APEX (workspace/username/password from `.env`) and run these repetitive admin tasks:
- create a user
- unlock an user
- change passwords

## Prereqs

- The repo root is `to_do_list_oracle/`
- Playwright is installed as a dev dependency
- A `.env` exists at repo root (copy from `.env.example`)

## Setup

1. From repo root:

```bash
cp .env.example .env
```

2. Fill in `.env` values:
- `APEX_LOGIN_URL`
- `APEX_WORKSPACE`
- `APEX_USERNAME`
- `APEX_PASSWORD`
- the 3 task URLs (`APEX_CREATE_USER_URL`, `APEX_UNLOCK_USER_URL`, `APEX_CHANGE_PASSWORD_URL`)

## Running the tasks

Always run from repo root.

### Create a user

```bash
npm run apex:create-user
```

### Unlock an user

```bash
npm run apex:unlock-user
```

### Change passwords

```bash
npm run apex:change-password
```

## Debugging / making it work with your APEX pages

If a task fails because elements don’t match your APEX UI:

1. Run the same command in UI mode:

```bash
npm run test:e2e:ui
```

2. Use codegen to capture correct selectors for your pages:

```bash
npx playwright codegen "$APEX_LOGIN_URL"
```

3. Update selectors in `e2e/apex-admin.spec.js` to match your app’s labels/buttons.

## Notes

- This skill assumes the APEX admin pages are already accessible via the URLs in `.env` after login.
- Keep `.env` local only (it’s gitignored).


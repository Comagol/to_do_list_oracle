## Playwright + APEX automation (project skill)

This repo includes a **project Skill** that teaches a Cursor agent how to run Playwright against Oracle APEX to:
- create a user
- unlock an user
- change passwords

### Where the skill lives

- `.cursor/skills/apex-playwright-admin/SKILL.md`

### Quick start

From the repo root:

```bash
cp .env.example .env
npm run apex:create-user
```

If selectors don’t match your APEX UI, open UI mode and adjust `e2e/apex-admin.spec.js`:

```bash
npm run test:e2e:ui
```


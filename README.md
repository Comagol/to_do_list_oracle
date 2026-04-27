# APEX Developer Learning Track

This folder is your practical roadmap to become an Oracle APEX developer by building real features in a connected way.

## Suggested Execution Order

1. `02-weekly-sales-excel-upload`
2. `01-authentication-multi-scheme`
3. `05-centralized-authorization`
4. `03-dynamic-navigation-menu`
5. `04-notification-management`
6. `06-office-printer-monthly-sales`
7. `07-back-to-back-rest-apis`

## Track Overview

- `01-authentication-multi-scheme`: local auth + Google sign-in + SAML 2.0
- `02-weekly-sales-excel-upload`: template download, upload, parse, preview, validate, process
- `03-dynamic-navigation-menu`: metadata-driven menu with icon/CSS/JS support
- `04-notification-management`: email, in-app, push, WhatsApp, SMS
- `05-centralized-authorization`: role/object/user authorization matrix
- `06-office-printer-monthly-sales`: printable monthly sales reports with charts
- `07-back-to-back-rest-apis`: consume external API and expose local REST endpoints

## Shared Business Domain

Use a single "Weekly Sales Operations" app domain so each project builds on previous work:

- Supervisors upload weekly store sales using an Excel template
- The app validates and previews data before commit
- Successful processing triggers notifications
- Monthly output is generated for management reporting

## Recommended Learning Rhythm

- Complete one folder at a time (`README.md` -> `plan.md` -> `checklist.md`)
- Keep a short "what I learned" note after each milestone
- Demo each completed feature to yourself as if presenting to a team lead

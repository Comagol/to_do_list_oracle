# 01 - Authentication Multi-Scheme

## Objective

Build an Oracle APEX application that supports three authentication schemes:

- Custom authentication with local tables
- Google social sign-in (OAuth2/OIDC)
- SAML 2.0 with dynamic runtime configuration and certificate data

## Why This Matters

Most enterprise apps must support multiple identity providers during migrations, acquisitions, or partner integrations.

## Scope

- Local user table, password policy, lockout and reset flow
- Google identity provider integration
- SAML identity provider integration with dynamic metadata/cert handling
- Unified login experience and fallback behavior

## Suggested Data Model

- `POC_USERS`
- `POC_AUTH_PROVIDER`
- `POC_AUTH_PROVIDER_CERT`
- `POC_AUTH_LOGIN_AUDIT`

## Key Deliverables

- Login process that supports provider selection
- Secure credential handling and audit trail
- Admin UI for provider config and certificate rotation

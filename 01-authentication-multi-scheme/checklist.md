# Checklist

## Build Checklist

- [ ] Local user table and auth packages are created
- [ ] Passwords are stored hashed and never in plain text
- [ ] Lockout policy is implemented (attempt threshold, lock duration, and lock reason tracking)
- [ ] Unlock/reset flows are implemented (admin unlock, self-service reset token, forced password change after reset)
- [ ] Password expiration fields and enforcement are implemented (`password_changed_at`, `password_expires_at`, forced-change flow)
- [ ] Password history child table is implemented and checked against last N passwords (current password remains in `users`)
- [ ] Admin page is implemented with user search/filter, lock status, unlock/reset/expire actions, and recent auth-event visibility
- [ ] Google OAuth2/OIDC client registration and callback integration are implemented
- [ ] Google provider configuration works via APEX Web Credentials
- [ ] Google provider configuration also works via table-driven settings in local schema
- [ ] Users authenticated via Google/OAuth2 are created or mapped in `users` with `login_type` (`PASSWORD`, `GOOGLE`, etc.)
- [ ] SAML 2.0 settings are stored in table-driven configuration (metadata, entity IDs, cert/public key, ACS, active flag, rollover dates)
- [ ] SAML login works with runtime provider resolution from table data
- [ ] SAML certificate rollover and provider fallback can be executed without app redeploy
- [ ] Unified login page shows separate actions for Password, Google, and SAML login
- [ ] Login audit entries are created for success/failure

## Validation Checklist

- [ ] Failed login attempts increment counters and trigger lockout according to policy
- [ ] Admin unlock and self-service reset flows restore access only after required password-change checks
- [ ] Password change rejects reuse from password history window
- [ ] Expired passwords trigger forced password change before normal app access
- [ ] Google login succeeds for at least two test users and records `login_type = GOOGLE`
- [ ] OAuth2 tokens/claims validation rejects expired or invalid values safely
- [ ] SAML login succeeds with active table-driven settings and fails safely when provider is disabled
- [ ] SAML certificate rollover dates can be switched and validated in runtime
- [ ] Unified login buttons route to the correct provider-specific auth flow
- [ ] Logout terminates session and clears sensitive state
- [ ] External provider outage shows user-friendly error and follows fallback logic

## Done Criteria

- [ ] All three auth schemes are available in one login flow
- [ ] Admin can manage lockout/unlock/reset operations from the admin page
- [ ] Admin can manage OAuth2 and SAML provider configuration through APEX credentials or table-driven settings without code change
- [ ] Security review notes are documented

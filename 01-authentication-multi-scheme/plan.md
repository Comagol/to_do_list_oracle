# Plan

## Stakeholder requirements (POC scope)

### Authentication priority

- **Primary:** Custom authentication (username + password against local tables).
- **Secondary:** SSO (e.g. Gmail / Google). SSO is optional on the same login experience, not the default path.

### Data model (`XX_` prefix)

| Table | Purpose |
|-------|--------|
| **XX_USERS** | Minimal person profile: names, birth date, `is_active`, and other core user fields; single row per logical person granted app access. |
| **XX_USER_PASSWORDS** | Current and historical password material for custom auth: use **DBMS_CRYPTO** (or equivalent agreed algorithm) per team standard; support **old password history** with **`is_active`** (only one active current credential per user at a time; history rows inactive). |
| **XX_USER_ACCESS_REQUEST** | For **SSO-only** identities: when a user signs in with SSO but **does not** yet exist in **XX_USERS**, capture a **request** here until an admin approves / creates the **XX_USERS** row (workflow TBD: status columns, approver, timestamps). |

Supporting objects (from original plan, still recommended):

- Login audit / failed-attempt tracking (table + package), aligned with lockout policy.
- Optional: token table or columns for forget-password flow (see Page 1003) — store **hashed** token + expiry, not raw token in clear text.

### APEX application map (POC)

| Page | Purpose |
|------|--------|
| **Login** | Username + password (primary). **SSO button** at bottom (secondary). **Forgot password** link. |
| **Page 1 – Landing** | If user authenticated via **SSO** and **not** in **XX_USERS**, show a **form to request access** (writes to **XX_USER_ACCESS_REQUEST** or equivalent process). |
| **Page 2 – Home** | After full access: simple POC message, e.g. “You got in.” |
| **Page 1000 – Admin** | Admin hub / entry to admin functions (navigation to 1001–1003, 1100 as needed). |
| **Page 1001 – Users** | Report or grid listing **XX_USERS** (and relevant status). |
| **Page 1002 – User details** | Form to **create/edit** a user in **XX_USERS** (and related password lifecycle if in scope for this page or separate flow). |
| **Page 1003 – Forgot password** | Target of Forgot password link; reset via **valid encrypted/hashed token** that **expires after configurable duration** (see App Settings). |
| **Page 1100 – App settings** | **Interactive Grid** on parameters table, e.g. **`FORGET_PASSWORD_TOKEN_EXPIRATION`** (and other tunables: lockout thresholds, token length, etc., as agreed). |

### Flow summary

1. Password users: Login → (optional email verification if still in scope) → Home (Page 2).
2. SSO users with existing **XX_USERS** row: SSO → Home (or Landing then Home if you always show Landing first — clarify in build).
3. SSO users **without** **XX_USERS** row: SSO → **Page 1** access request → wait for admin → admin creates user → next SSO login → Home.

---

## Phase 1 - Foundation

- Define **XX_USERS**, **XX_USER_PASSWORDS**, **XX_USER_ACCESS_REQUEST** (and indexes on lookup keys: email/username, SSO subject id if stored, request status).
- Implement password handling with **DBMS_CRYPTO** per standard; document algorithm, salt/pepper approach, and rotation rules; enforce validation rules (length, complexity) in a package.
- Add **password history** in **XX_USER_PASSWORDS** using **`is_active`** for current vs historical rows.
- Add login audit table and helper package (failed attempts, success timestamps, optional IP/user agent if allowed).
- Add **app parameters** table (or reuse existing pattern) backing **Page 1100**; seed **`FORGET_PASSWORD_TOKEN_EXPIRATION`** (and related keys).

## Phase 2 - Custom Authentication (primary)

- Build **custom authentication** function in APEX (delegating to package): validate against active row in **XX_USER_PASSWORDS** / **XX_USERS**, respect **`is_active`** and lockout flags.
- Implement lockout policy: max failed attempts, lock duration, optional permanent-lock threshold, and lock reason codes.
- Implement unlock/reset flows:
  - Admin unlock account action (from Admin / User details as appropriate)
  - **Self-service password reset** token flow (see Page 1003): generate token, store hash, email link, validate expiry using **`FORGET_PASSWORD_TOKEN_EXPIRATION`** from app settings
  - Force password change on first login after admin unlock/reset
- Implement password expiration policy (if required for POC): track `password_changed_at` / `password_expires_at` on **XX_USERS** or related table; enforce grace period and forced change when expired.
- Implement password history validation: on change, compare new hash against last N inactive rows in **XX_USER_PASSWORDS**.
- **Login page:** username + password as default; **Forgot password** link → Page 1003.

## Phase 3 - SSO secondary (e.g. Gmail / Google)

- Register OAuth2/OIDC client in Google Cloud (or corporate IdP).
- Use Oracle APEX references as examples:
  - Rittman Mead: Oracle APEX Social Login
  - Pretius: Google Identity Services in Oracle APEX
- Configure **Social Sign-In** (or chosen SSO) as **secondary** entry on login page (button below password form).
- Map identity claims to **XX_USERS** when row exists; if not, redirect or branch to **Page 1** to submit **XX_USER_ACCESS_REQUEST**.
- Store enough SSO identity to avoid duplicates (e.g. provider + subject id), not email alone if possible.
- Admin path: **Page 1001 / 1002** (or 1000) to approve requests and create **XX_USERS** (+ optional initial password or SSO-only flag).

## Phase 4 - Admin UX and POC pages

- **Page 1000 (Admin):** layout and navigation to Users, User details, Forgot-password admin tools (if any), App settings.
- **Page 1001 (Users):** list **XX_USERS** with filters (`is_active`, login type if tracked).
- **Page 1002 (User details):** maintain **XX_USERS**; integrate unlock / force reset / access-request approval if in scope.
- **Page 1003 (Forgot password):** public or unauthenticated-safe page; token in URL or entry field; validate against hashed token + **FORGET_PASSWORD_TOKEN_EXPIRATION** from **Page 1100** parameters.
- **Page 1100 (App settings):** Interactive Grid on parameters; include **`FORGET_PASSWORD_TOKEN_EXPIRATION`** and extend as needed.
- **Page 1 (Landing)** and **Page 2 (Home):** implement SSO-not-registered flow and POC success message.

## Phase 5 - SAML 2.0 Dynamic Provider (post-POC / extension)

- Create SAML provider table(s) for metadata URL/XML, entity identifiers, certificates/public keys, ACS details, active flag, and rollover dates.
- Implement runtime resolver that loads the active SAML provider from table-driven settings.
- Support certificate rollover process and fallback behavior without application redeploy.

## Phase 6 - Unified login UX (hardening of entry)

- Ensure single login page story: password primary, SSO secondary, consistent errors.
- Apply provider visibility/defaulting rules when needed (environment, tenant).
- Define fallback path when external IdP is unavailable.
- Add throttling and suspicious login detection.
- Validate session timeout and logout behavior.
- Review audit and compliance requirements.

---

## Implementation checklist (quick reference)

- [ ] **XX_USERS** / **XX_USER_PASSWORDS** / **XX_USER_ACCESS_REQUEST** + indexes
- [ ] Package: auth, password change, history, lockout, reset token
- [ ] Custom authentication scheme (current)
- [ ] SSO scheme + Web Credentials; login page layout
- [ ] Page 1 / 2 / 1000 / 1001 / 1002 / 1003 / 1100
- [ ] App parameters + **FORGET_PASSWORD_TOKEN_EXPIRATION**
- [ ] (Later) SAML, throttling, full hardening

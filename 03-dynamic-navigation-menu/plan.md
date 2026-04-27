# Plan

## Phase 1 - Data Model

- Create `POC_NAVIGATION_MENU` with parent hierarchy support
- Add columns for label, target, icon, CSS class, JS action, sequence
- Add status fields (`is_active`, `valid_from`, `valid_to`)

## Phase 2 - Admin Management

- Build admin page to create/update menu entries
- Add validations for cycles in parent tree
- Add preview mode to test menu rendering

## Phase 3 - Runtime Rendering

- Build PL/SQL service to fetch menu JSON/tree
- Render dynamic menu in shared component or region
- Wire icon and CSS class output safely

## Phase 4 - JavaScript Action Support

- Define safe pattern for allowed JS callbacks
- Support function names plus parameter payload
- Add client-side guardrails for missing handlers

## Phase 5 - Security and Access

- Add role/object filters tied to authorization layer
- Hide unauthorized entries at query time
- Log menu clicks for audit and UX analytics

# Plan

## Phase 1 - Authorization Schema

- Create tables for users, roles, objects, and role-object grants
- Create user-role assignment table with effective dates
- Add audit fields and change history tracking

## Phase 2 - APEX Object Discovery

- Query APEX metadata views for pages, regions, processes, and lists
- Build refresh process to synchronize object catalog
- Mark custom/non-APEX objects for extensibility

## Phase 3 - Admin Management

- Build role management page
- Build role-object assignment matrix
- Build user-role assignment page

## Phase 4 - Runtime Enforcement

- Implement reusable authorization function/package
- Attach checks to pages, components, and processes
- Integrate with dynamic navigation menu visibility

## Phase 5 - Governance

- Add export/report for current permissions
- Add regression tests for critical access paths
- Document role design standards

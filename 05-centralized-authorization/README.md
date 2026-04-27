# 05 - Centralized Authorization

## Objective

Implement a centralized authorization model ("one scheme to rule them all") that maps:

- Roles to APEX objects
- Users to roles

## Scope

- Discover application objects from internal APEX metadata views
- Store object-level access rules in local tables
- Provide admin pages to assign permissions and memberships
- Integrate with menu and page/process visibility checks

## Reference Direction

This track follows the style of metadata-driven authorization where APEX objects are queryable and assignable to reusable roles.

## Deliverables

- Object catalog refresh process
- Role/object matrix management UI
- User/role assignment UI
- Reusable authorization function used across the app

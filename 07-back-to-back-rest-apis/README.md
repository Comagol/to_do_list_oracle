# 07 - Back-to-Back REST APIs

## Objective

Create a learning project that consumes an external REST API and exposes local REST endpoints in Oracle APEX/ORDS for create/update scenarios.

## Learning Scenario

- GET a list of users from an external service
- POST a new local user through your API
- PUT updates to an existing local user through your API

## Scope

- REST consumption and mapping
- Local REST endpoint creation
- Validation, error handling, and response standards
- Logging and observability for requests/responses

## Deliverables

- External service consumer module
- Local `POST` and `PUT` endpoints
- API test collection and sample payloads
- Error and monitoring dashboard

## Quick Start (What To Run First)

1. Run `01_schema_and_logs.sql` in your schema.
2. Review and finalize `api_contract.md`.
3. Review mapping rules in `external_to_local_mapping.md`.
4. Configure `{{baseUrl}}` in `users_api.http`.
5. Start implementing ORDS handlers for `POST /users` and `PUT /users/{id}`.

## Starter Assets Included

- `api_contract.md`
- `external_to_local_mapping.md`
- `sample_payloads.json`
- `01_schema_and_logs.sql`
- `users_api.http`

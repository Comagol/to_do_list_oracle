# API Contract (v1)

## Versioning Strategy

- Base path: `/ords/poc/v1`
- Version included in URL for explicit contract control
- Backward-incompatible changes require `/v2`

## Endpoints

### `POST /users`

Create a local user record.

Request body:

```json
{
  "email": "ana@example.com",
  "firstName": "Ana",
  "lastName": "Lopez",
  "status": "ACTIVE"
}
```

Success response:

- `201 Created`
- Body:

```json
{
  "id": 101,
  "email": "ana@example.com",
  "firstName": "Ana",
  "lastName": "Lopez",
  "status": "ACTIVE",
  "createdAt": "2026-02-17T10:00:00Z"
}
```

Validation errors:

- `400 Bad Request`
- Missing/invalid fields

Duplicate user:

- `409 Conflict`
- Email already exists

### `PUT /users/{id}`

Update an existing local user.

Request body:

```json
{
  "firstName": "Ana Maria",
  "lastName": "Lopez",
  "status": "INACTIVE"
}
```

Success response:

- `200 OK`
- Updated user payload

Not found:

- `404 Not Found`
- User id does not exist

## Standard Error Payload

All non-success responses must follow this structure:

```json
{
  "errorCode": "USR_001",
  "message": "Email is required",
  "details": [
    "Field email must not be null"
  ],
  "correlationId": "e7c91f77-ef9f-4af7-9be4-c95c14a1c253",
  "timestamp": "2026-02-17T10:01:00Z"
}
```

## Basic Validation Rules

- `email`: required, valid format, max 320 chars, unique
- `firstName`: required for POST, max 100 chars
- `lastName`: required for POST, max 100 chars
- `status`: optional on POST, defaults to `ACTIVE`; allowed values: `ACTIVE`, `INACTIVE`

# Plan

## Phase 1 - Data Model

- Create tables for notification types, channels, templates, and config
- Separate channel enablement from server/credential configuration
- Add event log table for dispatch tracking

## Phase 2 - Admin Pages

- Build page to define notification types and method mapping
- Build configuration page with per-channel settings
- Add `Test` action to send a sample message per method

## Phase 3 - Dispatch Engine

- Implement routing package by method (email/in-app/push/WhatsApp/SMS)
- Add retry and dead-letter handling for failures
- Store delivery status and provider responses

## Phase 4 - Sales Upload Trigger

- Emit event when weekly sales file processing completes
- Build message payload with totals and result status
- Dispatch notifications to configured recipients/channels

## Phase 5 - Operations

- Create dashboard for sent/failed/pending notifications
- Add controls to re-send failed notifications
- Document runbook for WhatsApp/SMS server issues

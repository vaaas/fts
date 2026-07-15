# Database Conventions

Tags: #backend #database #conventions

We use PostgreSQL for durable state and treat migrations as append-only.

## Naming

Tables are plural and snake_case (`user_sessions`). Primary keys are named
`id`. Foreign keys are `<singular>_id`, for example `user_id`.

## Migrations

Every schema change ships as a numbered migration. Migrations must be
reversible; if a change cannot be reversed cleanly, split it into two.

## Indexing

Add an index for every foreign key and for any column used in a `WHERE` clause
on a hot path. Measure before adding composite indexes — they are not free.

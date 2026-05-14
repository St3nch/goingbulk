# GoingBulk Drizzle migrations

This folder mixes Drizzle-generated migrations with one hand-written
governance migration. **Read this before running `drizzle-kit generate`
or editing anything under `meta/`.**

## Current contents

| File                         | Source                   | Notes                                                                                |
| ---------------------------- | ------------------------ | ------------------------------------------------------------------------------------ |
| `0000_wakeful_cammi.sql`     | `drizzle-kit generate`   | Base schema. Tables, enums, FKs, base indexes.                                       |
| `0001_auth_rls_scaffold.sql` | Hand-written             | Functions, triggers, RLS policies, GRANTs, audit immutability, supplement dedup idx. |
| `meta/_journal.json`         | Drizzle (edited by hand) | Both `0000_wakeful_cammi` and `0001_auth_rls_scaffold` are listed here.              |
| `meta/0000_snapshot.json`    | `drizzle-kit generate`   | Schema snapshot after `0000`.                                                        |
| `meta/0001_snapshot.json`    | (intentionally absent)   | See "Why no 0001 snapshot" below.                                                    |

`pnpm db:migrate` (= `drizzle-kit migrate`) reads `_journal.json` plus
the `.sql` files. It does NOT read `meta/*.json` snapshots at apply time.
So both migrations apply cleanly with the journal as currently written.

## Why no 0001 snapshot

`0001_auth_rls_scaffold.sql` only adds objects that Drizzle's schema
diff does not track in the TS schema:

- `CREATE FUNCTION` (RLS helpers, audit immutability, updated_at)
- `CREATE TRIGGER`
- `CREATE POLICY` (RLS)
- `GRANT` / `REVOKE`
- One partial/expression `CREATE INDEX` for supplement dedup

None of these are represented in `src/db/schema/*.ts`. If we wrote a
snapshot for `0001`, it would be identical to `0000`'s and would just
encourage `drizzle-kit generate` to think the schema is unchanged --
which it is, as far as Drizzle TS sees.

## Rules for the next person running `drizzle-kit generate`

1. Before generating, **commit your current state**. The generator can
   produce surprising drops.
2. Drizzle does not know about anything in `0001_auth_rls_scaffold.sql`.
   If you change the TS schema and run `drizzle-kit generate`, it will
   diff against `0000_snapshot.json` (the last snapshot it sees) and
   emit a new `0002_*.sql` plus `meta/0002_snapshot.json`. That is fine.
3. **Never** let `drizzle-kit generate` propose dropping RLS policies,
   functions, triggers, grants, or the `idx_supplement_logs_dedup` index.
   If it does, you regenerated against a database where the manual
   migration was never applied. Reset and rerun `pnpm db:migrate`.
4. If the TS schema _does_ require adding or modifying RLS / triggers /
   grants, prefer writing a new hand-written `NNNN_*.sql` next to
   `0001_auth_rls_scaffold.sql` and adding a matching entry to
   `_journal.json` by hand. Do not try to coax `drizzle-kit generate`
   into producing it.

## If you need to renumber or rename a generated migration

Editing the file on disk is not enough. Drizzle's `migrate()` looks
up the `.sql` filename via the `tag` field in `_journal.json`. If you
rename or regenerate the base migration, update the `tag` in
`_journal.json` to match the new filename, or `migrate()` will fail
with no SQL ever reaching Postgres -- the failure mode that motivated
this README.

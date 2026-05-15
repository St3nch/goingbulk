# GoingBulk Drizzle migrations

This folder mixes Drizzle-generated migrations with hand-written governance
migrations. **Read this before running `drizzle-kit generate` or editing
anything under `meta/`.**

## Current contents

| File                               | Source                   | Notes                                                                                                             |
| ---------------------------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `0000_wakeful_cammi.sql`           | `drizzle-kit generate`   | Base schema. Tables, enums, FKs, base indexes.                                                                    |
| `0001_auth_rls_scaffold.sql`       | Hand-written             | Functions, triggers, RLS policies, GRANTs, audit immutability, supplement dedup idx, visibility auditing.         |
| `0002_easy_thena.sql`              | `drizzle-kit generate`   | Experiment workflow child tables: `experiment_interventions`, `experiment_outcomes`, `experiment_evidence_links`. |
| `0003_experiment_workflow_rls.sql` | Hand-written             | updated_at triggers, API grants, and parent-inherited RLS policies for the three experiment child tables.         |
| `meta/_journal.json`               | Drizzle (edited by hand) | All four migrations are listed here.                                                                              |
| `meta/0000_snapshot.json`          | `drizzle-kit generate`   | Schema snapshot after `0000`.                                                                                     |
| `meta/0001_snapshot.json`          | (intentionally absent)   | See "Why no 0001/0003 snapshot" below.                                                                            |
| `meta/0002_snapshot.json`          | `drizzle-kit generate`   | Schema snapshot after `0002`. `prevId` points to `0000`'s id — see note below.                                    |
| `meta/0003_snapshot.json`          | (intentionally absent)   | See "Why no 0001/0003 snapshot" below.                                                                            |

`pnpm db:migrate` (= `drizzle-kit migrate`) reads `_journal.json` plus
the `.sql` files. It does NOT read `meta/*.json` snapshots at apply time.
All four migrations apply cleanly with the journal as currently written.

## Why no 0001/0003 snapshot

`0001_auth_rls_scaffold.sql` and `0003_experiment_workflow_rls.sql` only
add objects that Drizzle's schema diff does not track in the TS schema:

- `CREATE FUNCTION` (RLS helpers, audit triggers, updated_at)
- `CREATE TRIGGER`
- `CREATE POLICY` (RLS)
- `GRANT` / `REVOKE`
- `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
- One expression `CREATE INDEX` for supplement dedup (in `0001`)

None of these are represented in `src/db/schema/*.ts`. If we wrote a
snapshot for `0001` or `0003`, it would be identical to the previous
generated snapshot and would just confuse `drizzle-kit generate` into
thinking no TS schema changes had occurred.

## Why `0002_snapshot.json.prevId` appears to skip `0001`

`0002_snapshot.json` has a `prevId` that points to `0000_snapshot.json`'s
id, not `0001`. This is **expected and correct**. Because `0001` is a
hand-written governance migration with no Drizzle snapshot, `drizzle-kit
generate` diffed the TS schema against the last snapshot it knew about
(`0000`). The result is that the snapshot chain has a documented intentional
gap at `0001` (and again at `0003`). Drizzle's `migrate()` does not care
about snapshot chain continuity at apply time — it only reads the journal
tags and the `.sql` files.

## Rules for the next person running `drizzle-kit generate`

1. Before generating, **commit your current state**. The generator can
   produce surprising drops.
2. Drizzle does not know about anything in `0001_auth_rls_scaffold.sql`
   or `0003_experiment_workflow_rls.sql`. If you change the TS schema and
   run `drizzle-kit generate`, it will diff against `0002_snapshot.json`
   (the last snapshot it sees) and emit a new `0004_*.sql` plus
   `meta/0004_snapshot.json`. That is fine.
3. **Never** let `drizzle-kit generate` propose dropping RLS policies,
   functions, triggers, grants, or the `idx_supplement_logs_dedup` index.
   If it does, you regenerated against a database where the manual
   migrations were never applied. Reset and rerun `pnpm db:migrate`.
4. If the TS schema _does_ require adding or modifying RLS / triggers /
   grants, prefer writing a new hand-written `NNNN_*.sql` alongside the
   existing governance migrations and adding a matching entry to
   `_journal.json` by hand. Do not try to coax `drizzle-kit generate`
   into producing governance SQL.
5. Hand-written governance migrations must be idempotent. Use
   `DROP TRIGGER IF EXISTS` before `CREATE TRIGGER` and
   `DROP POLICY IF EXISTS` before `CREATE POLICY` so the migration can
   be safely re-run after a partial failure.

## If you need to renumber or rename a generated migration

Editing the file on disk is not enough. Drizzle's `migrate()` looks
up the `.sql` filename via the `tag` field in `_journal.json`. If you
rename or regenerate a migration, update the `tag` in `_journal.json`
to match the new filename, or `migrate()` will fail with no SQL ever
reaching Postgres — the failure mode that motivated this README.

## Pattern: Drizzle-generated table + hand-written RLS

`0002` creates the experiment child tables (Drizzle-generated).
`0003` enables RLS, adds triggers, sets grants, and adds policies
(hand-written).

This split is intentional. Drizzle generates clean DDL for tables it
tracks; governance objects live in hand-written migrations so they are
explicit, reviewable, and version-controlled alongside the schema they
govern. Both files must be present for the tables to be correctly secured.

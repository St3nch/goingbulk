# GoingBulk Migration and Deployment Strategy

## Purpose

This document defines how GoingBulk should manage database migrations, environments, deployments, backups, and schema discipline while using Vercel and Supabase.

The goal is to prevent production drift, manual dashboard edits, and schema spaghetti.

## Core Rule

```text
If the app depends on it, it belongs in a migration.
```

Supabase is allowed to make development faster, but the production database schema must be controlled by migrations.

## Recommended Platform Stack

MVP default:

```text
Hosting: Vercel
Database: Supabase Postgres
Auth: Supabase Auth
Storage: Supabase Storage
DNS: Cloudflare or Vercel DNS
Tables/UI: TanStack Table + shadcn/ui
```

## Migration Tooling Decision

Recommended default:

```text
Drizzle ORM + Drizzle migrations
```

Why Drizzle fits GoingBulk:

- TypeScript-first;
- SQL-friendly;
- lighter than Prisma;
- works well with Postgres/Supabase;
- supports migration files;
- aligns with schema governance philosophy;
- avoids treating the Supabase dashboard as the schema authority.

## Environment Strategy

GoingBulk should have three environments:

```text
local
development/staging
production
```

### Local

Used for development and testing.

Should support:

- local Supabase where practical;
- seed data;
- migration testing;
- fake health data;
- RLS testing.

### Staging

Used before production.

Should support:

- production-like schema;
- non-sensitive fake data;
- preview deployments;
- RLS validation;
- import testing;
- API testing.

### Production

Real data only.

No manual schema edits unless emergency and followed by migration reconciliation.

## Deployment Flow

Recommended flow:

```text
feature branch
-> local migration/test
-> pull request
-> Vercel preview deployment
-> staging migration/test
-> review
-> merge to main
-> production deployment
-> production migration
-> smoke test
```

## Migration Rules

### Required

- migrations are committed to git;
- migrations are reviewed before production;
- destructive migrations require backup first;
- production migrations are logged;
- rollback plan exists for risky changes;
- RLS policies are included in migrations;
- enums are migration-controlled.

### Forbidden

- ad hoc production schema edits through Supabase dashboard;
- untracked column creation;
- deleting columns without export/backup;
- changing enum values without migration plan;
- changing RLS policies without tests;
- exposing new tables publicly without visibility/RLS review.

## Schema Change Checklist

Before applying a migration:

```text
[ ] Domain and purpose clear?
[ ] Migration file created?
[ ] Local migration tested?
[ ] Staging migration tested?
[ ] RLS impact reviewed?
[ ] Visibility impact reviewed?
[ ] API impact reviewed?
[ ] Existing data migration needed?
[ ] Rollback plan documented?
[ ] Backup taken if destructive?
```

## RLS Migration Rule

If a table contains sensitive or potentially sensitive records, the migration must include:

- visibility column where relevant;
- RLS enabled;
- select policies;
- insert/update/delete policies;
- tests or documented verification plan.

No sensitive table should ship with RLS forgotten.

## Seeding Strategy

Use fake data for local and staging.

Seed data should include:

- sample nutrition logs;
- sample workout sessions;
- sample supplement logs;
- sample experiments;
- sample visibility states;
- sample public/private/professional records;
- sample import batch;
- sample product/review record.

Do not seed production with fake data unless explicitly marked as demo and not mixed with real logs.

## Backup Strategy

Production needs automated backups.

Minimum:

- Supabase daily backups if plan supports it;
- manual backup before destructive migrations;
- periodic export of key data;
- documented restore procedure;
- test restore at least occasionally.

Backups should cover:

- database;
- storage files;
- MDX/content files in git;
- environment variable inventory, without exposing secret values.

## Rollback Strategy

Not every migration can be rolled back cleanly.

For each risky migration, classify:

```text
safe rollback
manual rollback
irreversible/destructive
```

Destructive migrations require:

- backup;
- export of affected data;
- explicit approval;
- post-migration verification.

## Vercel Deployment Considerations

Use Vercel for:

- preview deployments;
- production deployments;
- environment variables;
- serverless/route handlers;
- Next.js app hosting.

Rules:

- service role keys only in server-side env vars;
- never expose Supabase service key to browser;
- separate env vars by environment;
- preview deployments should not connect to production DB unless intentionally read-only and safe.

## Supabase Storage Deployment Rules

Storage buckets should be created through migration/config where practical.

Buckets:

```text
public-assets
private-documents
progress-photos
exports
```

Policies must be reviewed before any bucket receives real health documents.

## Content Deployment

MVP content should use MDX where practical.

Benefits:

- version controlled;
- reviewed through git;
- statically renderable;
- easier to audit.

Long-form content can move to DB/CMS later if needed.

## Emergency Procedure

If private data is exposed:

1. remove public access immediately;
2. revoke relevant keys if needed;
3. identify affected records/files;
4. check logs;
5. rotate secrets if exposure involved credentials;
6. document incident;
7. correct RLS/API policy;
8. review whether notice is required.

## Deployment Smoke Test

After production deploy:

```text
[ ] homepage loads
[ ] public experiment page loads
[ ] private admin requires login
[ ] public user cannot access private API data
[ ] public user cannot access private storage files
[ ] Cronometer import page works for owner
[ ] medical disclaimer appears
[ ] affiliate disclosure works where expected
[ ] sitemap/robots valid
```

## Core Principle

```text
Fast deployment is good. Untracked production drift is poison.
```

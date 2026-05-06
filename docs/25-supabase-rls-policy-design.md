# GoingBulk Supabase RLS Policy Design

## Purpose

This document defines the Row Level Security posture for GoingBulk on Supabase/Postgres.

GoingBulk will contain sensitive health, fitness, product, sponsor, and private operational data. RLS must be designed before production launch.

## Core Rule

```text
Default private. Public only by explicit promotion.
```

Sensitive records must not become public because a table was exposed accidentally or a query forgot a visibility filter.

## Access Model

### Anonymous Public User

Can access only records explicitly marked:

```text
visibility = public
```

### Professional Viewer

Future role. Can access:

```text
visibility IN ('public', 'professional')
```

Professional access should be invite-only or magic-link based in Phase 2.

### Admin / Owner

Can access all records required to operate the site.

For MVP, there may only be one owner account.

### Service Role

Used only by trusted server-side application code. Never exposed to browser, public assistant, LLM tool, or client-side code.

## Visibility Enum

Recommended enum:

```sql
CREATE TYPE visibility_enum AS ENUM (
  'private',
  'internal',
  'professional',
  'public'
);
```

Meaning:

| Value | Meaning |
|---|---|
| private | visible only to owner/admin |
| internal | visible to internal tools/admin workflows |
| professional | visible to approved professional viewers |
| public | visible to anonymous public users |

## Role Enum

Recommended enum:

```sql
CREATE TYPE user_role_enum AS ENUM (
  'owner',
  'admin',
  'editor',
  'professional_viewer',
  'public'
);
```

MVP can begin with:

```text
owner
public
```

Add professional roles later.

## User Profile Table

Supabase Auth provides auth users, but GoingBulk should maintain an app profile table.

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  role user_role_enum DEFAULT 'public',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## RLS Helper Functions

Use stable helper functions for readability.

```sql
CREATE OR REPLACE FUNCTION current_user_role()
RETURNS user_role_enum AS $$
  SELECT role FROM user_profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

```sql
CREATE OR REPLACE FUNCTION is_owner_or_admin()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_profiles
    WHERE id = auth.uid()
    AND role IN ('owner', 'admin')
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

```sql
CREATE OR REPLACE FUNCTION can_view_visibility(record_visibility visibility_enum)
RETURNS boolean AS $$
  SELECT CASE
    WHEN record_visibility = 'public' THEN true
    WHEN record_visibility = 'professional' THEN current_user_role() IN ('owner', 'admin', 'professional_viewer')
    WHEN record_visibility = 'internal' THEN current_user_role() IN ('owner', 'admin', 'editor')
    WHEN record_visibility = 'private' THEN current_user_role() IN ('owner', 'admin')
    ELSE false
  END;
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

## Default RLS Pattern

For every sensitive table:

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

### Select Policy

```sql
CREATE POLICY "select_by_visibility"
ON table_name FOR SELECT
USING (can_view_visibility(visibility));
```

### Insert Policy

```sql
CREATE POLICY "owner_admin_insert"
ON table_name FOR INSERT
WITH CHECK (is_owner_or_admin());
```

### Update Policy

```sql
CREATE POLICY "owner_admin_update"
ON table_name FOR UPDATE
USING (is_owner_or_admin())
WITH CHECK (is_owner_or_admin());
```

### Delete Policy

```sql
CREATE POLICY "owner_admin_delete"
ON table_name FOR DELETE
USING (is_owner_or_admin());
```

## Tables That Require Visibility

These tables should have `visibility visibility_enum DEFAULT 'private'`:

```text
nutrition_logs
workout_sessions
exercise_sets if directly queried
supplement_logs
measurements
body_metric_logs
bloodwork_results
dexa_results
progress_photo_sessions
progress_photos
experiments
claims
confounder_logs
products
services
product_usage_windows
product_reviews
reports
datasets
dataset_exports
pages
```

Some tables may default differently:

```text
published pages: public
affiliate disclosure pages: public
sponsor relationships: internal/private by default, public summary on review pages
```

## Public Content Tables

Public pages can be selected when:

```text
status = published
AND visibility = public
```

Example:

```sql
CREATE POLICY "public_can_read_published_pages"
ON pages FOR SELECT
USING (status = 'published' AND visibility = 'public');
```

## Private Admin Tables

These should not be publicly readable:

```text
nutrition_import_batches
nutrition_import_rows
audit_log
approval_queue
api_keys
api_key_usage
sponsor_relationships
raw device imports
private notes
```

Admin-only policy:

```sql
CREATE POLICY "admin_only"
ON table_name FOR ALL
USING (is_owner_or_admin())
WITH CHECK (is_owner_or_admin());
```

## Public API vs Direct Supabase Access

Public pages should prefer application API/server-side queries that apply business logic.

RLS is a safety net, not a replacement for API design.

Correct pattern:

```text
Next.js server component or API route
-> Supabase server client
-> RLS enforced
-> app-level validation and filtering
```

Forbidden:

```text
public client directly querying sensitive tables with broad access
```

## LLM / Agent Access

LLMs and agents must not receive Supabase credentials.

They access GoingBulk through API keys and scoped GoingBulk APIs.

RLS protects the database, but agent access must be constrained before the database layer.

## Storage RLS

Supabase Storage buckets must also be designed carefully.

Suggested buckets:

```text
public-assets
private-documents
progress-photos
exports
```

### public-assets

Public read allowed.

### private-documents

Owner/admin only.

Examples:

- raw bloodwork PDFs;
- raw DEXA reports;
- unredacted documents.

### progress-photos

Default private. Public versions should be watermarked, stripped of EXIF, and explicitly promoted.

### exports

Public exports should be generated intentionally. Private exports should require owner/admin.

## RLS Testing Requirements

Before launch, test each role:

```text
anonymous
owner
professional_viewer later
```

For each sensitive table, verify:

- anonymous can only read public records;
- anonymous cannot insert/update/delete;
- owner can read/write all;
- professional can only read professional/public records when role exists;
- service role is not used in browser;
- private records are never returned by public APIs.

## Test Dataset

Create fake records with each visibility level:

```text
private
internal
professional
public
```

Run automated tests to ensure policies behave correctly.

## Common RLS Pitfalls

Avoid:

- leaving RLS disabled on sensitive tables;
- using service role in client-side code;
- relying only on frontend hiding;
- forgetting storage bucket policies;
- forgetting derived views/materialized views;
- allowing public access to raw import rows;
- making professional visibility public by accident;
- assuming generated Supabase APIs are safe without policies.

## Derived Views and RLS

Views and materialized views like `daily_facts` need explicit access handling.

Options:

1. create public/professional variants;
2. query source tables through APIs and apply visibility logic;
3. materialize only public-safe data for public views.

Recommended MVP:

```text
do not expose daily_facts publicly until visibility behavior is tested
```

## MVP RLS Scope

MVP should implement:

- owner/admin full access;
- anonymous public read for published public pages and public datasets only;
- private default for health logs;
- no professional role until Phase 2;
- no public raw import access;
- no client-side service role.

## Core Principle

```text
RLS is not decoration. It is the safety boundary between private health records and the public internet.
```

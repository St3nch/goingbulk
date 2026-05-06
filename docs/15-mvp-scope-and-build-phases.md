# GoingBulk MVP Scope and Build Phases

## Purpose

This document defines the first buildable version of GoingBulk and separates the true MVP from later platform ambition.

This document has been revised after the Claude audit. The original MVP scope was too large and has been tightened.

## MVP Objective

The MVP should prove this loop:

```text
log or import data
-> normalize it safely
-> summarize it clearly
-> publish one trustworthy public experiment/report
```

The MVP does not need to prove the full long-term entity graph, professional explorer, product review engine, lab/device ecosystem, or VedaOps integration.

## True MVP Scope

The MVP is the smallest version that proves GoingBulk can run for one real month.

### Required Public Pages

```text
/
/about
/experiments/baseline-30-days
/data/baseline-30-days
/methodology
/medical-disclaimer
/affiliate-disclosure
/privacy
```

Optional if time allows:

```text
/nutrition
/training
/supplements
```

### Required Admin Areas

```text
/admin
/admin/imports/cronometer
/admin/bodyweight
/admin/workouts
/admin/supplements
/admin/experiments
```

### Required Data Capture

MVP capture features:

- Cronometer CSV import;
- import preview;
- import deduplication by file hash;
- import approval;
- bodyweight logging;
- simplified workout logging;
- supplement taken/missed logging;
- basic baseline experiment setup;
- optional simple confounder notes.

### Required Public Output

MVP public output:

- homepage with project status;
- creator/about page;
- baseline 30-day experiment page;
- baseline dataset page;
- server-rendered summary table;
- CSV export for the baseline dataset;
- methodology explanation;
- visible medical disclaimer;
- affiliate disclosure even if affiliate links are not active yet.

## MVP Non-Scope

Do not build these first:

- native mobile apps;
- full food database replacement;
- barcode scanning;
- full wearable API integrations;
- bloodwork import/OCR;
- automatic DEXA parsing;
- Hume API/import pipeline;
- public chatbot;
- sponsor portal;
- paid user accounts;
- professional accounts;
- professional data explorer;
- saved views;
- advanced filters;
- AG Grid;
- full product database;
- full service database;
- full entity graph UI;
- schema management UI;
- multi-user roles beyond owner/public;
- full VedaOps integration before VedaOps is ready.

## MVP Data Model

Required MVP tables:

```text
user_profiles
nutrition_import_batches
nutrition_import_rows
nutrition_logs
measurements
workout_sessions
exercise_sets
supplements
supplement_logs
experiments
datasets
audit_log
```

Tables that may exist later but are not MVP blockers:

```text
entities
entity_relationships
page_entities
internal_links
schema_records
product_reviews
sponsor_relationships
professional_saved_views
approval_queue
api_keys
api_key_usage
```

## MVP Security Requirements

The MVP must include:

- Supabase Auth owner account;
- RLS enabled on sensitive tables;
- private default visibility;
- anonymous access only to public pages/data;
- no service role key in browser;
- storage buckets private by default;
- audit logging for imports and public visibility promotion;
- medical disclaimer visible on every public page.

## MVP Content Model Decision

Use MDX for MVP long-form content.

```text
Long-form public content = MDX
Structured logs/imports/experiments/datasets = Postgres
Metadata = frontmatter first, DB later where needed
```

This avoids building a CMS before the first public dataset exists.

## Phase 1: Foundation MVP

Goal: prove the data-to-report loop.

Includes:

- Next.js app shell;
- Vercel deployment;
- Supabase Postgres/Auth/Storage;
- Drizzle migration setup;
- owner/admin auth;
- Cronometer import pipeline;
- basic bodyweight logging;
- simplified workout logging;
- supplement checklist;
- baseline experiment page;
- baseline dataset page;
- CSV export;
- legal/disclaimer pages;
- basic public homepage.

## Phase 2: Structured Reporting and Data Depth

Goal: make GoingBulk repeatable after the first baseline report.

Includes:

- weekly/monthly report templates;
- daily_facts materialized view;
- better nutrition/training summaries;
- source/confidence labels across more tables;
- Quick Facts blocks;
- server-rendered summary tables;
- DEXA records;
- Hume manual imports;
- bloodwork summaries;
- product/service review pages;
- internal link suggestions;
- first entity pages.

## Phase 3: Professional Explorer

Goal: let professionals filter and interrogate data.

Includes:

- professional data explorer;
- advanced filters;
- column visibility;
- compare date ranges;
- source/confidence filters;
- confounder filters;
- CSV/JSON exports;
- optional professional accounts;
- saved views.

## Phase 4: Product, Sponsor, and Entity Graph Expansion

Goal: deepen monetization and entity architecture.

Includes:

- product usage windows;
- affiliate link management;
- sponsor/product review workflow;
- richer entity graph tables;
- page/entity relationships;
- schema records;
- product/service hubs;
- Hume vs DEXA experiment.

## Phase 5: LLM and VedaOps Integration

Goal: connect GoingBulk to governed agents and the larger VedaOps environment.

Includes:

- GoingBulk API surface;
- API key scopes;
- MCP-compatible tool design;
- LLM report drafting;
- LLM claim-safety checks;
- no direct LLM database access;
- V Forge handoff alignment;
- VEDA observability after public launch;
- Project V planning integration when ready.

## Launch Criteria

The first public launch should have:

- working public site;
- working admin login;
- working Cronometer import;
- working bodyweight logging;
- working simple workout logging;
- working supplement checklist;
- one baseline experiment page;
- one baseline dataset page;
- CSV export;
- methodology page;
- medical disclaimer;
- privacy page;
- affiliate disclosure;
- no obvious private data leaks;
- RLS tested for anonymous vs owner access.

## Core Rule

```text
The MVP is not the dream. The MVP proves the machine can run for one real month.
```

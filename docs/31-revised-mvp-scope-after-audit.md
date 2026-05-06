# GoingBulk Revised MVP Scope After Audit

## Purpose

This document revises the GoingBulk MVP scope after Claude's external audit.

The original MVP plan was strategically strong but too large. It included many Phase 2 and Phase 3 features under the MVP label.

This document defines the smaller version that proves the core GoingBulk machine works.

## Core Audit Finding

The original MVP was closer to:

```text
MVP + Phase 2 + Phase 3 + early platform architecture
```

The revised MVP should prove only the essential loop:

```text
capture/import data
-> normalize data
-> summarize data
-> publish one trustworthy public experiment/report
```

## Revised MVP Goal

Launch the smallest version of GoingBulk that proves:

1. data can be logged or imported consistently;
2. data can be stored cleanly;
3. data can produce a public report;
4. the report can be read by normal users and serious data-minded users;
5. the project can publish without creating obvious legal/privacy risk.

## Revised MVP Public Pages

Only these pages are required for first launch:

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

Not MVP:

```text
full glossary
full entity graph
professional data explorer
product review system
multiple experiments
large topical wiki
public chatbot
VedaOps integration
```

## Revised MVP Admin Features

Required:

```text
/admin/imports/cronometer
/admin/bodyweight
/admin/workouts
/admin/supplements
/admin/experiments
```

MVP admin capabilities:

- upload Cronometer CSV;
- preview import;
- detect duplicate file hash;
- approve import;
- view nutrition daily summary;
- log bodyweight;
- log simplified workout sessions;
- log supplement taken/missed;
- create/edit one baseline experiment;
- mark selected summary data as public.

## Revised MVP Data Model

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
reports or simple report metadata
```

Required governance/support tables:

```text
audit_log
api_keys later only if agent/API access exists
```

Defer:

```text
entities
entity_relationships
page_entities
internal_links
schema_records
product_reviews
sponsor_relationships
professional saved views
approval_queue unless needed for MVP writes
```

## Revised MVP Content Model

Decision:

```text
Use MDX for MVP long-form content.
Use frontmatter for metadata.
Use Postgres for structured logs/imports/experiments/datasets.
```

Reason:

- faster launch;
- version control;
- no CMS needed;
- simpler review;
- easier to create public pages early.

## Revised MVP Data Sources

MVP data sources:

```text
Cronometer CSV export
manual bodyweight log
manual workout log
manual supplement checklist
manual confounder notes if simple
```

Not MVP:

```text
DEXA import
bloodwork import
Hume API/import
Samsung wearable import
CGM data
progress photo system
```

These can be mentioned as future roadmap items, not required at launch.

## Revised MVP Experiment

First experiment:

```text
Baseline 30 Days
```

Purpose:

```text
Establish a public starting point for GoingBulk by tracking nutrition, bodyweight, training, supplements, and basic confounders for 30 days.
```

Required sections:

- Quick Facts;
- N=1 disclaimer;
- methodology summary;
- date range;
- data sources;
- nutrition summary;
- bodyweight summary;
- workout summary;
- supplement summary;
- confounders;
- limitations;
- next phase.

## Revised MVP Dataset Page

First dataset:

```text
/data/baseline-30-days
```

Required:

- summary;
- date range;
- data source list;
- field/column list;
- server-rendered summary table;
- CSV export;
- limitations;
- visibility note;
- not medical advice note.

## Revised MVP Security Requirements

MVP must include:

- Supabase Auth owner account;
- RLS enabled on sensitive tables;
- private default visibility;
- anonymous access only to public pages/data;
- no service role key in browser;
- storage buckets private by default;
- audit logging for import approval and visibility promotion;
- medical disclaimer visible on every public page.

## Revised MVP SEO/GEO Requirements

MVP should include:

- clean metadata;
- crawlable text summaries;
- Quick Facts on experiment page;
- Article/WebPage schema where appropriate;
- no advanced Dataset schema unless tested;
- sitemap;
- robots.txt;
- canonical URLs;
- noindex for admin/private routes.

Defer:

- full entity graph;
- schema records table;
- full topical map;
- broad glossary;
- professional explorer indexing strategy.

## Revised MVP Success Metrics

MVP is successful if:

```text
Cronometer import works weekly without corrupting data.
Daily bodyweight logging takes under 10 seconds.
Workout logging is usable during real workouts.
Supplement logging is one tap or close.
Baseline experiment page is understandable.
CSV export opens cleanly in Excel/Google Sheets.
No private data leaks publicly.
Medical/disclaimer language is present.
Creator can sustain the workflow for 30 days.
```

## Phase 2 After MVP

Add only after the revised MVP works:

- professional data explorer;
- daily_facts materialized view;
- compare periods;
- DEXA records;
- Hume manual imports;
- bloodwork summaries;
- product/service review pages;
- entity graph tables;
- internal link management;
- saved views;
- newsletter/report cadence.

## Phase 3 Later

- LLM assistant;
- VedaOps/V Forge integration;
- public chatbot;
- sponsor packages;
- advanced data exports;
- wearable API integrations;
- native mobile app if PWA is insufficient.

## Cut List

Do not build in MVP:

```text
public chatbot
professional accounts
advanced saved views
AG Grid
full product database
full service database
bloodwork OCR
DEXA parser
wearable integrations
complex entity graph UI
schema management UI
multi-user roles beyond owner/public
```

## Core Rule

```text
The MVP is not the dream. The MVP proves the machine can run for one real month.
```

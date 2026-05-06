# GoingBulk System Architecture

## Preferred Stack

GoingBulk should be built as a real application, not a WordPress plugin stack.

Recommended foundation:

```text
Next.js
PostgreSQL
Tailwind / shadcn-ui
PWA-capable mobile experience
Object storage for files and images
API layer for future VedaOps/MCP integration
```

## Core Architecture

```text
Next.js App
  - public website
  - mobile logging app
  - admin dashboard
  - API routes/server actions

PostgreSQL
  - nutrition logs
  - workout logs
  - supplement logs
  - body metrics
  - experiments
  - products and affiliates
  - pages/entities/content metadata

Object Storage
  - progress photos
  - bloodwork documents
  - DEXA reports
  - downloadable reports

Future VedaOps Connector
  - governed API/MCP access
  - read summaries
  - prepare handoffs
  - support V Forge execution work
```

## App Areas

### Public Area

Routes for public users:

```text
/
/dashboard
/experiments
/experiments/[slug]
/supplements
/supplements/[slug]
/products
/products/[slug]
/bloodwork
/methodology
/data-dictionary
/for-professionals
/sponsorship-policy
/affiliate-disclosure
/roadmap
```

### Admin Area

Private routes:

```text
/admin
/admin/imports/cronometer
/admin/workouts
/admin/programs
/admin/nutrition
/admin/supplements
/admin/body-metrics
/admin/experiments
/admin/products
/admin/pages
/admin/entities
/admin/schema
/admin/reports
```

### Mobile Logging Area

Can be part of the same Next.js app but optimized as a PWA.

```text
/app/today
/app/food
/app/workout
/app/body
/app/supplements
/app/notes
```

## Database Design Principle

GoingBulk should separate planned data from actual data.

Examples:

```text
planned_meals vs nutrition_logs
workout_templates vs workout_sessions
program_schedule vs completed_workouts
supplement_schedule vs supplement_logs
scheduled_tests vs test_results
```

This enables adherence tracking and planned-vs-actual reporting.

## Core Data Domains

### Health and Fitness Data

- daily logs;
- nutrition logs;
- food records;
- workout sessions;
- exercise sets;
- body metrics;
- supplement logs;
- bloodwork results;
- DEXA results;
- wearable/device metrics;
- progress photos;
- confounder notes.

### Experiment Data

- claims;
- research sources;
- baseline windows;
- intervention windows;
- follow-up windows;
- metrics;
- confounders;
- confidence ratings;
- verdicts.

### Product and Monetization Data

- products;
- brands;
- affiliate links;
- sponsor relationships;
- product usage windows;
- review records;
- disclosure status.

### Website and Content Data

- pages;
- entities;
- page-entity relationships;
- internal links;
- schema records;
- content summaries;
- quick facts;
- citation-ready summaries.

## API-First Posture

GoingBulk should expose internal APIs for major data access.

This matters because future VedaOps/MCP access should not query the database directly.

Future tools should call GoingBulk APIs such as:

```text
get_recent_nutrition_summary
get_active_experiments
compare_experiment_periods
get_page_graph
get_product_review_status
get_schema_status
get_publication_summary
```

## Public vs Private Data

Not all collected data should be public by default.

Suggested visibility levels:

```text
private
internal
professional
public
```

Examples:

- exact raw lab PDFs may stay private;
- summarized bloodwork values may be public;
- sponsor negotiations stay private;
- product disclosure status is public;
- progress photos can be selectively public.

## Build Principle

Start boring and reliable.

The first version should prioritize:

- easy imports;
- easy logging;
- clean database structure;
- simple dashboards;
- repeatable reports;
- clear public methodology.

Fancy automation can come later.

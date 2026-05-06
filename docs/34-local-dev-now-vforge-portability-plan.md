# GoingBulk Local Development Now and V Forge Portability Plan

## Purpose

This document defines how GoingBulk can start development locally now without waiting for VedaOps/V Forge to be fully ready.

The goal is to build GoingBulk as a clean standalone Next.js project that can later be imported into, coordinated by, or built through VedaOps/V Forge without major rework.

## Core Decision

GoingBulk does not need to wait for VedaOps before development starts.

The safest path is:

```text
Build GoingBulk locally as an independent, cleanly structured project.
Preserve clear boundaries.
Document decisions.
Avoid coupling to unfinished VedaOps internals.
Port/integrate with V Forge later when the ecosystem is ready.
```

## Core Principle

```text
Standalone now. VedaOps-compatible later.
```

GoingBulk should be independently runnable, deployable, testable, and understandable before it becomes a child project inside the larger VedaOps workflow.

## Why This Is Safe

Starting now is safe if GoingBulk avoids premature coupling.

Good early work:

- Next.js app foundation;
- Vercel/Supabase setup;
- Drizzle migrations;
- MVP schema;
- RLS policies;
- Cronometer import pipeline;
- local admin UI;
- public MVP pages;
- experiment pre-registration;
- methodology changelog;
- baseline experiment flow.

Risky early work:

- direct dependency on VedaOps database schema;
- assuming Project V data models are final;
- building custom V Forge adapters too early;
- letting LLM/agents access the database directly;
- mixing GoingBulk health data into VedaOps storage;
- designing around unfinished VedaOps APIs.

## Local Development Project Shape

Recommended local path:

```text
C:\dev\goingbulk
```

Suggested structure:

```text
goingbulk/
  app/
  components/
  lib/
  db/
  drizzle/
  scripts/
  content/
  docs/
  public/
  tests/
  package.json
  README.md
  .env.example
```

## Recommended Stack

```text
Next.js
TypeScript
Vercel
Supabase Postgres
Supabase Auth
Supabase Storage
Drizzle ORM + migrations
TanStack Table later
shadcn/ui
MDX for MVP content
```

## Portability Rules

### 1. Keep GoingBulk Independently Runnable

A developer should be able to run GoingBulk without VedaOps.

```text
pnpm install
pnpm dev
pnpm db:migrate
```

If VedaOps is unavailable, GoingBulk should still function.

### 2. Use Environment Variables Cleanly

Use `.env.example` and documented env vars.

Example:

```text
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
DATABASE_URL=
```

Never hardcode VedaOps paths, secrets, or API assumptions.

### 3. Keep Database Ownership Clear

GoingBulk owns its own product database.

VedaOps may later coordinate, observe, or generate work for GoingBulk, but GoingBulk data should not be dumped into VedaOps by default.

Correct future pattern:

```text
VedaOps / V Forge / agent
-> GoingBulk API
-> GoingBulk database
```

Forbidden pattern:

```text
VedaOps / agent
-> direct GoingBulk database access
```

### 4. Build APIs Before Agent Integration

Do not design agent behavior around direct Supabase access.

Future V Forge/VedaOps tools should call GoingBulk APIs.

### 5. Prefer Documented Contracts

Anything V Forge may need later should be documented as a contract:

- routes;
- API endpoints;
- env vars;
- migration commands;
- test commands;
- build commands;
- data boundaries;
- agent/tool permissions.

## V Forge Import Readiness

GoingBulk should eventually provide a handoff package.

Suggested future file:

```text
35-vforge-build-handoff.md
```

It should include:

```text
project purpose
MVP scope
stack
routes
schema summary
commands
env vars
security rules
non-goals
known risks
acceptance criteria
```

## Local Build Phases

### Local Phase A: Repository Foundation

Goal:

```text
Create a clean Next.js app shell and project structure.
```

Tasks:

```text
initialize Next.js project
add TypeScript
add linting/formatting
add shadcn/ui
add Supabase client setup
add Drizzle setup
add .env.example
add README
commit baseline
```

### Local Phase B: Database Foundation

Goal:

```text
Implement MVP schema with migrations and RLS posture.
```

Tasks:

```text
create user_profiles
create nutrition import tables
create nutrition_logs
create measurements
create workout tables
create supplement tables
create experiments
datasets/dataset_exports
audit_log
add RLS policies
add seed data
```

### Local Phase C: Admin MVP

Goal:

```text
Create enough admin UI to log/import real data.
```

Tasks:

```text
admin auth
Cronometer CSV upload
import preview
approve import
bodyweight logger
simple workout logger
supplement checklist
baseline experiment editor
```

### Local Phase D: Public MVP Pages

Goal:

```text
Create the first public-facing GoingBulk site.
```

Tasks:

```text
homepage
about page
methodology page
methodology changelog
medical disclaimer
privacy page
affiliate disclosure
baseline pre-registration
baseline experiment page
baseline dataset page
```

### Local Phase E: Baseline Run

Goal:

```text
Run the first real 30-day baseline period.
```

Tasks:

```text
log daily bodyweight
import Cronometer exports
log workouts
log supplements
track confounders
fix friction immediately
publish baseline report after completion
```

## What Not To Build Locally Yet

Do not build early:

```text
professional accounts
public Ask My Data assistant
VedaOps agent integration
full entity graph UI
product review engine
bloodwork import
DEXA parser
wearable integrations
sponsor dashboard
community voting
```

These can wait until the MVP loop works.

## VedaOps/V Forge Future Integration

When VedaOps/V Forge is ready, GoingBulk can be brought in as:

```text
existing standalone child project
with docs, repo, schema, routes, APIs, and build commands already defined
```

V Forge should not need to guess what GoingBulk is.

It should receive a documented handoff.

## Migration Into V Forge Later

Potential later steps:

1. create Project V entry for GoingBulk;
2. attach GoingBulk docs as project context;
3. register repo path;
4. define build/test commands;
5. define API contracts;
6. define deployment targets;
7. define data boundaries;
8. define agent permissions;
9. let V Forge generate tasks or code against the existing project.

## Guardrails

### Guardrail 1: No Direct DB Access For Agents

No VedaOps/V Forge/LLM agent gets direct database credentials.

### Guardrail 2: No VedaOps Data Contamination

GoingBulk health/product data stays in GoingBulk unless intentionally exported or exposed through APIs.

### Guardrail 3: No Premature Platform Abstractions

Do not build adapters for systems that are not finished.

### Guardrail 4: MVP First

If a task does not help run the first 30-day baseline, it probably waits.

## Core Rule

```text
Build GoingBulk now like a disciplined standalone app, not like a temporary throwaway prototype.
```

That makes it easier to port into VedaOps later, not harder.

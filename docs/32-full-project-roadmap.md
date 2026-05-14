# GoingBulk Full Project Roadmap

## Purpose

This document defines the full GoingBulk roadmap from planning to long-term platform maturity.

GoingBulk starts as a small, buildable MVP, but the long-term vision is much larger: a public data-backed fitness brand, structured N=1 experiment system, entity-first website, professional data explorer, product/service testing platform, and future VedaOps/V Forge-connected project.

This roadmap connects the dream to a practical build sequence.

## Core Roadmap Principle

```text
Start small enough to ship.
Design clean enough to scale.
Log consistently enough to matter.
Publish honestly enough to build trust.
```

The full platform should not be built before the basic data-to-report loop works.

## Roadmap Maintenance Rules

This roadmap is a living control document, not a one-time planning artifact.

Rules:

- Keep this roadmap updated as work is completed.
- Mark completed work explicitly.
- Track in-progress work explicitly.
- Document deferred work instead of losing it.
- Capture major "not now" decisions with the reason they were deferred.
- Keep MVP, post-MVP, and long-term platform work visible in one place.
- Future GPT/Claude/AI assistants should use this roadmap before suggesting major new work.
- Any branch that completes or materially changes roadmap scope should update this document.

## Current Implementation Status

Last updated: 2026-05-14

### Completed Foundation Milestones

- [x] Documentation-first project planning foundation
- [x] GitHub repository and professional branch/PR workflow
- [x] Next.js app foundation
- [x] Supabase local development setup
- [x] Drizzle migration foundation
- [x] MVP schema foundation
- [x] Supabase RLS foundation
- [x] Ownership-aware RLS model
- [x] Self-promotion prevention
- [x] Explicit API grant/revoke hardening
- [x] Immutable audit log enforcement
- [x] Role-change audit logging
- [x] Visibility-transition audit logging
- [x] Behavioral database hammer tests
- [x] CI database rebuild smoke tests
- [x] Windows local Supabase reserved-port workaround
- [x] Missing local seed file added
- [x] Current security posture snapshot
- [x] Literature/evidence pipeline planning document
- [x] Experiment workflow planning document drafted
- [x] Experiment workflow child tables implemented (experiment_interventions, experiment_outcomes, experiment_evidence_links)
- [x] Experiment child-table parent-inherited RLS (ownership and visibility inherited from experiments row)
- [x] Experiment child-table hammer coverage (ownership, cross-user denial, anon private/public visibility, parent visibility transition propagation)
- [x] Migration idempotence: hand-written governance migrations use DROP ... IF EXISTS guards
- [x] CI: second db:migrate run to verify idempotence/no-op behavior
- [x] CI: pnpm audit --audit-level=high added to verify pipeline
- [x] Hammer: non-ephemeral database guard added

### Current Active Focus

- [ ] Build admin UI for experiment creation and management
- [ ] Build Cronometer CSV import pipeline
- [ ] Connect experiment workflow to real baseline data

### Next Three Priorities

1. Build the admin import flow for Cronometer CSV.
2. Build bodyweight, workout, and supplement logging admin views.
3. Wire the baseline experiment record to real logged data.

### Deferred But Tracked Work

These items are intentionally not forgotten. They are deferred until the prerequisites are ready.

- [ ] Experiment child-table write audit triggers (intervention added/changed, outcome added/changed, evidence link added)
- [ ] Experiment lifecycle/status audit triggers (planned → active → completed → published)
- [ ] Stronger experiment outcome provenance: post-hoc outcome editing currently leaves no audit trail; add audit trigger for experiment_outcomes writes before public reporting workflow ships
- [ ] Import approval/rejection audit events
- [ ] Professional/internal visibility hammer coverage
- [ ] Full literature ingestion tables and APIs
- [ ] Automated paper search / PubMed / Crossref / OpenAlex integration
- [ ] Advanced statistical inference
- [ ] Bayesian or causal modeling
- [ ] Multi-participant study support
- [ ] Public dataset release workflow
- [ ] Curated public projection tables/views
- [ ] Professional data explorer
- [ ] Entity graph/content management system
- [ ] Governed LLM assistant APIs
- [ ] Community experiment suggestions
- [ ] Sponsor/product testing workflow
- [ ] Backup/restore CI
- [ ] Migration hash verification
- [ ] Golden schema drift detection
- [ ] pgTAP or SQL-first test suite split
- [ ] Audit hash-chain / cryptographic tamper evidence

## Roadmap Summary

```text
Phase 0: Project foundation and decisions
Phase 1: True MVP
Phase 2: Repeatable reporting and stronger data model
Phase 3: Device, lab, and product-review expansion
Phase 4: Professional data explorer
Phase 5: Entity graph, SEO/GEO, and content scale
Phase 6: LLM assistant and agent/API integration
Phase 7: VedaOps/V Forge integration
Phase 8: Monetization, sponsors, and authority building
Phase 9: Mature GoingBulk platform
```

## Phase 0: Project Foundation and Decisions

### Goal

Finish the decisions required before build starts.

### Key Outcomes

- clear creator positioning;
- hosting stack selected;
- MVP scope locked;
- schema discipline locked;
- privacy/legal posture drafted;
- development workflow decided;
- docs reconciled after audit.

### Required Decisions

```text
creator identity: real name, persona, or pseudonym
public data boundaries
first 30-day baseline start date
Vercel + Supabase setup
Drizzle migration setup
MDX content strategy
Supabase RLS approach
legal/disclaimer wording for launch
```

### Required Docs

```text
24-creator-positioning-and-credentials.md
25-supabase-rls-policy-design.md
26-api-security-and-agent-access.md
27-writing-style-guide.md
28-privacy-policy-and-legal-disclaimers.md
29-migration-and-deployment-strategy.md
31-revised-mvp-scope-after-audit.md
32-full-project-roadmap.md
```

### Exit Criteria

```text
MVP scope is stable.
Hosting stack is chosen.
Public/private data rules are understood.
Creator positioning draft exists.
Schema governance is accepted.
```

## Phase 1: True MVP

### Goal

Prove the GoingBulk data-to-report loop for one real month.

### Core Loop

```text
capture/import data
-> normalize data
-> summarize data
-> publish one trustworthy baseline report
```

### Required Build

#### App Foundation

```text
Next.js app
Vercel deployment
Supabase project
Supabase Auth owner account
Supabase Storage buckets
Drizzle migrations
basic admin layout
basic public layout
```

#### MVP Admin

```text
/admin
/admin/imports/cronometer
/admin/bodyweight
/admin/workouts
/admin/supplements
/admin/experiments
```

#### MVP Data Features

```text
Cronometer CSV upload
import preview
file hash deduplication
import approval
normalized nutrition logs
manual bodyweight logging
simple workout session logging
exercise set logging
supplement taken/missed logging
optional confounder logging
baseline experiment record
baseline dataset export
```

#### MVP Public Pages

```text
/
/about
/experiments/baseline-30-days
/experiments/baseline-30-days/pre-registration
/data/baseline-30-days
/methodology
/methodology/changelog
/medical-disclaimer
/affiliate-disclosure
/privacy
```

Optional MVP pages:

```text
/nutrition
/training
/supplements
```

### MVP Security Requirements

```text
RLS enabled on sensitive tables
private default visibility
public data only by explicit promotion
service role never exposed to browser
audit logging for import approval and visibility changes
admin routes require owner login
private storage buckets by default
```

### MVP Content Requirements

- About page explains who is behind GoingBulk;
- methodology explains the data collection process;
- baseline experiment page includes Quick Facts;
- baseline experiment has a pre-registration page before results are known;
- methodology changelog exists before measurement methods start changing;
- dataset page includes crawlable summary table;
- medical disclaimer is visible and linked;
- affiliate disclosure exists even if links are not active yet.

### Exit Criteria

```text
30 days of baseline data can be collected.
Cronometer import works more than once without duplicate corruption.
Bodyweight logging takes under 10 seconds.
Workout logging is usable during real workouts.
Supplement logging is fast enough to use daily.
Baseline dataset exports as CSV.
Public pages do not leak private data.
RLS anonymous-vs-owner tests pass.
```

## Phase 2: Repeatable Reporting and Stronger Data Model

### Goal

Turn the MVP into a repeatable reporting system.

### Key Features

```text
weekly report template
monthly report template
experiment report template
better summary calculations
improved source/confidence labels
public/private visibility workflow
CSV exports for selected periods
data quality checks
simple dashboard cards
```

### Data Model Additions

```text
daily_facts materialized view
report metadata
confounder summaries
more formal dataset exports
possibly approval_queue
```

### Content Expansion

```text
/nutrition
/training
/supplements
/reports/monthly/[yyyy-mm]
/methodology/nutrition-logging
/methodology/workout-logging
/methodology/supplement-tracking
/methodology/data-confidence-labels
```

### Exit Criteria

```text
Monthly reports can be generated repeatedly.
The baseline report is not a one-off manual miracle.
Summary tables are consistent.
Source/confidence labels are visible.
Public exports are controlled.
```

## Phase 3: Device, Lab, and Product-Review Expansion

### Goal

Add richer data sources and begin controlled product/service documentation.

### Device and Lab Data

Add manually first, automate later.

```text
DEXA record entry
bloodwork summary entry
Hume manual entry/import
Samsung wearable manual import if needed
blood pressure measurements
progress photo session metadata
```

### Required Safety Work

Before publishing lab/device data:

```text
redaction checklist tested
storage privacy tested
medical disclaimer blocks added
source/confidence labels refined
public summary format defined
```

### Product/Service Modeling

Add first product/service tables only when real usage exists.

```text
brands
products
services
product_usage_windows
affiliate_links
product_reviews
sponsor_relationships later
```

### First Likely Product/Device Content

```text
/devices/hume-pod
/devices/hume-band
/body-composition/dexa
/services/cronometer
/products/hume-pod-review
/services/cronometer-review
```

### Exit Criteria

```text
At least one device/lab data type is entered safely.
No raw lab/PDF data is publicly exposed accidentally.
At least one product/service page has usage-window context.
Affiliate/sponsor disclosure components work.
```

## Phase 4: Professional Data Explorer

### Goal

Give doctors, nutritionists, coaches, and serious data-minded viewers a way to filter and inspect data.

### Required Before Build

```text
enough data exists to explore
RLS and visibility model tested
public/professional boundary defined
export policy defined
daily_facts stable enough for querying
```

### Core Features

```text
/pro or /for-professionals/data-explorer
TanStack Table + shadcn/ui
server-side filtering
server-side sorting
pagination
column visibility
date range filters
source filters
confidence filters
confounder filters
supplement/product filters
CSV export
```

### Later Features

```text
saved views
compare periods
professional accounts
JSON exports
PDF summaries
chart builder
AG Grid only if TanStack becomes insufficient
```

### Exit Criteria

```text
A professional can compare baseline vs later periods.
A professional can filter by source/confidence/confounders.
Exports respect visibility rules.
The explorer does not expose private data.
```

## Phase 5: Entity Graph, SEO/GEO, and Content Scale

### Goal

Evolve GoingBulk from a project site into an entity-structured content system.

### Entity System

Add database-backed entity/content graph when enough pages exist to justify it.

```text
entities
entity_relationships
pages
page_entities
internal_links
schema_records
```

### Topical Hubs

Build out:

```text
/nutrition
/training
/supplements
/body-composition
/bloodwork
/devices
/products
/services
/experiments
/data
/glossary
```

### Content Types

```text
entity page
hub page
experiment report
dataset page
methodology page
glossary page
product review
service review
monthly report
quarterly report
```

### SEO/GEO Requirements

```text
crawlable summaries
Quick Facts blocks
citation summaries
server-rendered summary tables
canonical URLs
noindex exploratory filter pages
schema matching visible content
internal links between related entities
```

### Exit Criteria

```text
Core topics have hub pages.
Important concepts have canonical URLs.
Experiment and dataset pages are citeable.
Internal links are intentional, not random.
Thin placeholder content is avoided.
```

## Phase 6: Governed LLM and Advanced Automation, Built Incrementally

### Goal

Add LLM/agent capabilities only after the core data, reporting, security, and API layers are stable.

This phase is not one big implementation bundle. It is an optional, staged capability ladder.

### Required Before Any Agent Build

```text
API security model implemented
API keys/scopes implemented
audit logging implemented
RLS tested
public/private/professional boundaries tested
prompt injection risks understood
approval-sensitive actions identified
```

### Agent Access Pattern

```text
LLM or agent intent
-> governed API client
-> GoingBulk API
-> Supabase/Postgres
```

Forbidden:

```text
LLM or agent
-> direct Supabase SQL/Postgres access
```

### Phase 6A: Read-Only Internal Assistant

Start here if/when useful.

```text
summarize public data
summarize active experiment
draft report outlines
flag missing logs
suggest possible confounders
check claim wording against style guide
```

No public chat.
No write access.
No publishing.
No visibility changes.

### Phase 6B: Owner-Approved Drafting Assistant

Add only after 6A is useful.

```text
draft report sections
suggest internal links
prepare export descriptions
summarize product usage windows
prepare experiment report outlines
```

All outputs remain drafts until the owner approves them.

### Phase 6C: Public Ask-My-Data Interface

Optional later feature.

Only build after:

```text
public dataset is large enough
rate limiting exists
public query APIs exist
visibility boundaries are tested
query logging is acceptable
```

This should only query public data.

### Phase 6D: Advanced Experiment Prediction Features

Optional later feature.

Examples:

```text
Prediction vs Reality
research-based expected outcomes
actual-vs-predicted comparison
LLM-assisted research summaries
```

This should not be implemented before several completed experiments exist.

### Phase 6E: Community Experiment Suggestions

Optional, likely much later.

This should not be part of MVP or early agent work because it introduces moderation, expectation-management, spam, and public voting dynamics.

A lightweight manual version can come first:

```text
private idea backlog
owner-curated experiment queue
public request form later
public voting only if audience size justifies it
```

### Never Automatically Allowed

```text
publish pages
change visibility
approve imports
activate affiliate links
change verdicts
publish bloodwork summaries
change sponsor disclosures
run public user-submitted experiments automatically
```

### Exit Criteria

```text
Each automation stage is useful on its own.
No agent has direct DB access.
All agent calls are scoped and logged.
Sensitive actions require owner approval.
Public-facing automation only uses public data.
```

## Phase 7: VedaOps and V Forge Integration

### Goal

Bring GoingBulk into the larger VedaOps ecosystem when VedaOps is ready.

### Boundary Principle

```text
GoingBulk is a child project planned/managed through VedaOps and built through V Forge, but GoingBulk owns its own product data and app boundaries.
```

### Integration Areas

```text
Project V planning context
V Forge build handoff
VEDA observability after launch
MCP-compatible GoingBulk APIs
agent workflows through APIs only
project status reporting
```

### Key Boundary Rules

- VedaOps docs are context, not GoingBulk product docs;
- GoingBulk data does not automatically belong in VedaOps DB;
- if VedaOps needs access, it uses GoingBulk APIs;
- no direct DB access from VedaOps agents;
- GoingBulk remains independently deployable.

### Exit Criteria

```text
V Forge can build from GoingBulk docs.
GoingBulk APIs are clear enough for tool integration.
VedaOps can observe or manage project work without owning private health data.
```

## Phase 8: Monetization, Sponsors, and Authority Building

### Goal

Turn the transparent data system into a trusted brand and revenue engine without corrupting credibility.

### Revenue Channels

```text
affiliate links
sponsored product tests
sponsored service reviews
YouTube monetization
newsletter sponsorships
consulting/data review opportunities later
product comparison reports
```

### Trust Requirements

```text
affiliate disclosure near links
sponsor disclosure near content
would-use-if-not-paid verdict
usage windows
source/confidence labels
negative results allowed
sponsors cannot buy conclusions
correction/update policy
```

### Authority Building

```text
YouTube videos linked to canonical pages
expert critique pages
professional outreach
brand/product backlinks
dataset/report citations
social clips pointing to reports
monthly/quarterly reports
```

### Exit Criteria

```text
Affiliate links are live without hiding incentives.
At least one product review uses real usage data.
Sponsor rules are public before accepting sponsors.
Trust is not sacrificed for revenue.
```

## Phase 9: Mature GoingBulk Platform

### Goal

GoingBulk becomes a mature public fitness data platform and media brand.

### Mature Capabilities

```text
multi-year public dataset
experiment archive
product/service archive
professional explorer
entity graph/wiki
monthly and quarterly reports
device/lab comparison reports
LLM-assisted operations
VedaOps/V Forge integration
strong social/video ecosystem
trusted sponsor/product review model
```

### Possible Future Extensions

```text
public API for selected datasets
newsletter data briefings
expert commentary pages
community-submitted questions
professional review sessions
paid advanced reports
mobile app if PWA is insufficient
open data packages
```

### Mature Success Indicators

```text
GoingBulk has years of consistent data.
Reports are trusted because methods are visible.
Experts can critique and inspect the dataset.
Product reviews include real usage context.
LLMs/search systems can understand the site structure.
Sponsors value the transparency instead of trying to bypass it.
```

## Cross-Phase Dependencies

### Security Before Exposure

Do not publish sensitive data until RLS, storage privacy, and redaction workflows are tested.

### Data Before Explorer

Do not build the professional explorer before there is enough clean data to explore.

### Usage Before Review

Do not publish serious product reviews before real usage windows exist.

### Entity Graph After Content

Do not build the full entity graph UI before there are enough pages/entities to manage.

### API Before Agent

Do not connect LLM/agent tooling before governed APIs, scopes, and audit logs exist.

### Trust Before Monetization

Do not accept sponsor deals before disclosure and editorial independence rules are public.

## Roadmap Risk Register

### Risk: Overbuilding Before Logging

Mitigation:

```text
Ship MVP around one real baseline month.
Do not build Phase 3 systems before Phase 1 works.
```

### Risk: Database Spaghetti

Mitigation:

```text
Use Drizzle migrations.
Follow schema governance.
Avoid JSON junk drawers.
Review schema before expansion.
```

### Risk: Medical Overclaiming

Mitigation:

```text
Use writing style guide.
Use medical disclaimer components.
Separate observation from causation.
```

### Risk: Privacy Leak

Mitigation:

```text
Private default visibility.
RLS tests.
Storage bucket policies.
Redaction checklist.
Audit logs.
```

### Risk: Monetization Corrupts Trust

Mitigation:

```text
Disclosure near links.
Sponsor policy.
Would-use-if-not-paid verdict.
Negative results allowed.
```

### Risk: SEO Without Substance

Mitigation:

```text
Publish real data and reports first.
Avoid thin placeholder pages.
Use entity structure after content exists.
```

## Recommended Build Order

```text
1. Finalize creator positioning.
2. Create Next.js + Vercel + Supabase foundation.
3. Add Drizzle migrations and MVP schema.
4. Implement auth and RLS basics.
5. Build Cronometer import pipeline.
6. Build bodyweight, workout, and supplement logging.
7. Build baseline experiment and dataset pages.
8. Run 30-day baseline.
9. Publish baseline report and CSV export.
10. Add repeatable monthly reports.
11. Add richer data sources and product/service pages.
12. Add professional explorer.
13. Add entity graph/content scale.
14. Add governed LLM tools.
15. Integrate with VedaOps/V Forge when ready.
```

## Core Rule

```text
GoingBulk should become massive by proving small loops repeatedly, not by building a massive system before the first loop works.
```

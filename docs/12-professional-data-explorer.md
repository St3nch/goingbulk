# GoingBulk Professional Data Explorer

## Purpose

The Professional Data Explorer is the advanced data workspace for doctors, dietitians, nutritionists, coaches, researchers, and serious data-minded viewers.

The normal GoingBulk dashboard should explain what changed.

The Professional Data Explorer should let qualified or curious users ask deeper questions, filter the data, compare periods, inspect sources, and export structured views.

## Core Principle

```text
Public dashboard = here is what changed.
Professional data explorer = here is the dataset; slice it however you need.
```

GoingBulk should not assume it knows every question a professional will ask.

The explorer should make the data flexible enough that professionals can compare things the creator may not know matter yet.

## Recommended Table Stack

The default implementation should use:

```text
TanStack Table
+ shadcn/ui
+ server-side filtering/sorting/pagination
+ PostgreSQL-backed APIs or views
```

TanStack Table and shadcn/ui should power the first version because they fit the GoingBulk Next.js/Tailwind app direction and provide strong control over filtering, sorting, column visibility, and admin/public UI.

If the professional explorer later needs spreadsheet-grade behavior, consider adding AG Grid or a similar advanced grid only for specific screens.

## What This Is Not

The Professional Data Explorer is not:

- a simple public chart page;
- a WordPress-style embedded table plugin;
- a raw database dump;
- a medical diagnosis tool;
- a replacement for professional judgment;
- a clinical research platform.

It is a structured, source-labeled, filterable personal dataset explorer.

## Primary Users

### Doctors

May care about:

- blood pressure;
- glucose;
- lipids;
- liver/kidney markers;
- bodyweight changes;
- supplement windows;
- sleep, sodium, caffeine, and stress context;
- confounders around lab results.

### Dietitians and Nutritionists

May care about:

- calories;
- protein;
- carbs;
- fat;
- fiber;
- sodium;
- potassium;
- sugar;
- meal timing;
- adherence;
- weight trends;
- bloodwork context.

### Coaches

May care about:

- workout adherence;
- training volume;
- sets by muscle group;
- performance trends;
- sleep and recovery context;
- nutrition adherence;
- phase labels.

### Sponsors and Product Review Readers

May care about:

- product usage windows;
- dose/adherence;
- before/during/after comparisons;
- related metrics;
- limitations;
- source confidence.

## Main Explorer Route

Potential routes:

```text
/for-professionals/data-explorer
/pro/data-explorer
/dashboard/pro
```

Access level can be decided later.

Possible access modes:

```text
public professional view
private invite-only professional view
admin-only explorer
limited public explorer with exports disabled
```

## Core Layout

Suggested page layout:

```text
Header
  - title
  - date range
  - compare period
  - experiment/phase selector
  - export button

Summary Cards
  - selected period averages
  - adherence values
  - key changes
  - warnings/confounders

Charts
  - selected metrics over time
  - compare periods
  - baseline/intervention/follow-up

Filter Panel
  - date
  - phase
  - experiment
  - metric groups
  - sources
  - confidence
  - confounders
  - supplements/products

Table
  - daily summary or detail rows
  - sortable/filterable columns
  - column visibility controls

Saved Views
  - reusable filter/column/sort presets
```

## Two-Level Data Model

Professionals should not be forced to start with raw rows.

GoingBulk should provide both daily rollups and drill-down tables.

### Level 1: Daily Summary

One row per day.

This is the main professional table.

Example fields:

```text
date
phase
active_experiments
calories
protein_g
carbs_g
fat_g
fiber_g
sodium_mg
bodyweight_lb
sleep_hours
steps
resting_hr
hrv
training_completed
training_volume
sets_completed
supplement_adherence_pct
blood_pressure_systolic_avg
blood_pressure_diastolic_avg
confounder_flags
notes
```

### Level 2: Raw Detail Tables

Drill-down tables should exist for:

```text
nutrition entries
meal logs
workout sessions
exercise sets
supplement doses
body measurements
bloodwork markers
DEXA results
device readings
progress photo sessions
confounder notes
```

## Daily Facts View

GoingBulk should create a derived database view or materialized table called something like:

```text
daily_facts
```

Purpose:

```text
Give the professional explorer a fast, one-row-per-day dataset that combines the most useful metrics across nutrition, training, supplements, body metrics, devices, and confounders.
```

Potential fields:

```text
date
phase_id
experiment_ids
calories
protein_g
carbs_g
fat_g
fiber_g
sodium_mg
water_l
bodyweight_lb
waist_measurement
sleep_hours
steps
resting_hr
hrv
training_completed
training_volume
sets_completed
creatine_taken
supplement_adherence_pct
blood_pressure_systolic_avg
blood_pressure_diastolic_avg
confounder_flags
notes
```

The normalized source tables remain the source of truth. `daily_facts` is an analysis-friendly rollup.

## Core Filters

### Date Filters

Required:

```text
start date
end date
compare period A
compare period B
baseline/intervention/follow-up windows
```

### Phase Filters

Examples:

```text
Baseline
Lean Bulk
Cut
Maintenance
Deload
Creatine Test
Hume vs DEXA
High Protein Protocol
Illness Week
Travel Week
```

### Experiment Filters

Examples:

```text
show active experiment only
show baseline window
show intervention window
show follow-up window
exclude overlapping experiments
```

### Supplement/Product Filters

Examples:

```text
supplement/product used
brand
active date range
dose
adherence status
with period
without period
before/during/after comparison
```

### Metric Group Filters

Suggested groups:

```text
Nutrition
Training
Body Composition
Bloodwork
Blood Pressure
Sleep
Wearable
Supplements
Subjective Notes
Confounders
Products
```

### Source Filters

Examples:

```text
Cronometer
manual log
Hume Pod
Hume Band
Samsung Watch
DEXA
blood lab
manual blood pressure cuff
estimated restaurant meal
```

### Confidence Filters

Examples:

```text
High confidence only
Include medium confidence
Include low confidence estimates
Include experimental device scores
```

### Confounder Filters

Examples:

```text
exclude illness days
exclude travel days
exclude poor sleep days
exclude injury days
show high sodium days
show high stress days
show missed workout days
show missed supplement days
```

## Advanced Filter Examples

Professionals should be able to ask questions like:

```text
Show days where protein was over 180g and sleep was under 6 hours.
```

```text
Compare blood pressure during high-sodium days vs normal-sodium days.
```

```text
Show bodyweight and training volume during creatine use, excluding illness and travel days.
```

```text
Show DEXA-related date windows with nutrition and training context.
```

```text
Show low-fiber days during the baseline period.
```

```text
Show all bloodwork markers with nutrition averages from the prior 14 days.
```

## Saved Views

Saved views should store reusable explorer configurations.

A saved view may include:

```text
name
filters
columns
sort order
date range
comparison period
chart selections
visibility level
notes
```

Potential saved views:

```text
High Sodium Days
Low Sleep Training Days
Creatine Intervention Window
Baseline vs Bulk
Blood Pressure Review
Protein Adherence
DEXA Comparison Window
Bloodwork Context Window
```

## Column Visibility

Professionals should be able to choose which columns appear.

This is critical because different professionals care about different metrics.

Example column groups:

```text
Nutrition columns
Training columns
Device columns
Bloodwork columns
Supplement columns
Confounder columns
Experiment columns
Source/confidence columns
```

## Export Requirements

Export is non-negotiable.

Supported export types should eventually include:

```text
CSV
JSON
PDF summary
copyable citation summary
chart image export
```

Useful exports:

```text
export current table view
export daily facts for selected period
export experiment package
export bloodwork context package
export supplement/product usage package
```

## API Pattern

Explorer filters should be backed by server-side queries.

Do not load years of data into the browser and filter it all client-side.

Example API shape:

```text
GET /api/pro/daily-facts?start=2026-05-01&end=2026-07-31&experiment=creatine&protein_min=180&sleep_max=6&exclude_flags=illness,travel&sort=bodyweight_desc
```

The backend should enforce visibility rules, source filters, and data access limits.

## Public vs Professional Detail

Normal public pages should simplify.

Example:

```text
Average protein was 186g/day during the baseline phase.
```

Professional explorer should show:

```text
date range
source
calculation method
confidence
excluded days
confounder flags
exportable rows
```

## Privacy and Visibility

Not every field should be public.

Fields should support visibility levels:

```text
private
internal
professional
public
```

Examples:

- sponsor negotiations remain private;
- private notes stay private unless explicitly promoted;
- lab PDFs may be redacted or summarized;
- exact timestamps may be generalized;
- public dashboards may show weekly averages rather than raw daily sensitive values.

## LLM Role

A future LLM assistant can help professionals and the creator by:

- explaining active filters;
- summarizing selected views;
- flagging visible patterns;
- generating export summaries;
- suggesting confounders to inspect;
- preparing professional report drafts.

The LLM should not:

- infer medical diagnoses;
- invent missing data;
- override source confidence;
- silently change filters;
- expose private fields;
- claim causation from N=1 patterns.

## Upgrade Path

### Phase 1

```text
Daily summary table
basic filters
column visibility
CSV export
TanStack Table + shadcn/ui
```

### Phase 2

```text
advanced filters
compare date ranges
confidence/source filters
confounder filters
saved views
```

### Phase 3

```text
professional explorer workspace
chart builder
export packages
LLM summaries
possible AG Grid for heavy spreadsheet-style exploration
```

## Core Rule

```text
The pro explorer should let serious users compare things GoingBulk may not know to ask about yet.
```

That is the value.

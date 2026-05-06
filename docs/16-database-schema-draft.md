# GoingBulk Database Schema Draft

## Purpose

This document defines the first-pass database schema direction for GoingBulk.

This draft has been revised after the Claude audit. It now separates MVP schema from Phase 2+ schema and reflects the corrected privacy, RLS, API, migration, and schema-governance posture.

## Core Schema Principle

```text
Model the boring facts cleanly before adding clever automation.
```

GoingBulk schema must support trustworthy long-term data, but the MVP should only implement the tables required to prove the first data-to-report loop.

## Platform Assumption

MVP stack:

```text
Vercel
Supabase Postgres
Supabase Auth
Supabase Storage
Drizzle migrations
Next.js API/route handlers
```

## Schema Governance Rules

All schema changes must follow:

- migration-controlled changes;
- no untracked production dashboard edits;
- RLS for sensitive tables;
- private default visibility;
- source/confidence fields where relevant;
- raw plus normalized import data;
- LLM/agent access through APIs only;
- no direct DB access for agents/tools.

## MVP Schema Scope

The MVP schema should support:

- owner/admin auth;
- Cronometer CSV import;
- normalized nutrition logs;
- bodyweight/body measurements;
- simplified workout logging;
- supplement checklist/logging;
- one baseline experiment;
- one baseline dataset/export;
- visibility control;
- basic audit logging.

MVP should not implement the full entity graph, professional explorer, product review graph, bloodwork/DEXA/device pipelines, or LLM API keys unless needed earlier.

## Shared Enums

Recommended MVP enums:

```sql
CREATE TYPE visibility_enum AS ENUM ('private', 'internal', 'professional', 'public');
CREATE TYPE confidence_enum AS ENUM ('low', 'medium', 'high', 'experimental');
CREATE TYPE user_role_enum AS ENUM ('owner', 'admin', 'editor', 'professional_viewer', 'public');
CREATE TYPE import_status_enum AS ENUM ('uploaded', 'previewed', 'approved', 'rejected', 'failed');
CREATE TYPE log_source_enum AS ENUM ('manual', 'cronometer_export', 'device_import', 'lab_report', 'estimated');
```

MVP may start with fewer enum values if needed, but avoid free-text chaos for repeated statuses.

## Core Identity Tables

### user_profiles

Supabase Auth owns authentication. GoingBulk owns app-level profile/role.

```text
id
email
name
role
created_at
updated_at
```

MVP roles:

```text
owner
public
```

Future roles:

```text
admin
editor
professional_viewer
```

## MVP Nutrition Tables

### nutrition_import_batches

Tracks uploaded Cronometer exports.

```text
id
source
file_name
file_hash
imported_at
date_range_start
date_range_end
status
review_status
notes
created_at
updated_at
```

Required constraints:

```text
unique(file_hash)
```

### nutrition_import_rows

Stores raw imported rows before/alongside normalization.

```text
id
batch_id
raw_date
raw_meal
raw_food_name
raw_amount
raw_calories
raw_protein
raw_carbs
raw_fat
raw_fiber
raw_sodium
raw_sugar
raw_payload
mapped_food_id
status
created_at
```

Keep `raw_payload` for auditability.

### foods

Optional for MVP. Can start minimal or defer if Cronometer row snapshots are enough.

```text
id
name
brand
source
source_food_id
serving_description
grams_per_serving
verified_status
created_at
updated_at
```

Full per-100g nutrient modeling can come later.

### nutrition_logs

Normalized nutrition records used for dashboards and dataset summaries.

```text
id
date
logged_at
meal_name
food_id
food_name_snapshot
grams
calories
protein_g
carbs_g
fat_g
fiber_g
sugar_g
sodium_mg
source
source_batch_id
confidence_level
visibility
notes
created_at
updated_at
```

Default:

```text
visibility = private
source = cronometer_export
confidence_level = medium/high depending on import quality
```

## MVP Measurement Tables

### measurements

General-purpose measurement table.

MVP uses this for bodyweight and simple body measurements.

```text
id
measured_at
metric_key
value
unit
source
device
method
confidence_level
conditions
visibility
notes
created_at
updated_at
```

Example MVP rows:

```text
metric_key = bodyweight
unit = lb
source = manual
confidence_level = high
visibility = private
```

Specialized bloodwork/DEXA tables should be Phase 2+ unless required earlier.

## MVP Workout Tables

### exercises

Minimal exercise library.

```text
id
name
slug
primary_muscle_group
secondary_muscle_groups
equipment
movement_pattern
notes
created_at
updated_at
```

### workout_sessions

Simplified actual workout sessions.

```text
id
date
started_at
ended_at
session_type
duration_minutes
status
notes
visibility
created_at
updated_at
```

### exercise_sets

Actual performed sets.

```text
id
workout_session_id
exercise_id
set_number
set_type
actual_reps
actual_load
load_unit
rpe
rest_seconds
notes
created_at
updated_at
```

MVP can skip planned program tables.

Phase 2 can add:

```text
workout_programs
program_weeks
workout_templates
scheduled_workouts
```

## MVP Supplement Tables

### supplements

```text
id
name
slug
category
active_ingredient
notes
created_at
updated_at
```

### supplement_logs

```text
id
date
logged_at
supplement_id
dose
unit
time_taken
adherence_status
source
confidence_level
visibility
notes
created_at
updated_at
```

MVP can skip product-linked supplement modeling unless a product test is active.

Phase 2 can add:

```text
supplement_products
supplement_schedule
product_usage_windows
```

## MVP Experiment and Dataset Tables

### experiments

```text
id
title
slug
experiment_type
status
question
hypothesis
protocol_summary
baseline_start
baseline_end
intervention_start
intervention_end
followup_start
followup_end
primary_metrics
secondary_metrics
confidence_level
verdict
visibility
notes
created_at
updated_at
```

MVP only needs one baseline experiment.

### confounder_logs

Optional but useful in MVP.

```text
id
date
confounder_type
severity
impact_areas
notes
visibility
created_at
updated_at
```

Suggested MVP confounders:

```text
poor_sleep
high_stress
illness
injury
travel
missed_workout
missed_supplement
alcohol
new_program
```

### datasets

Public dataset metadata for the baseline dataset.

```text
id
name
slug
description
date_range_start
date_range_end
source_summary
methodology_summary
limitations
visibility
created_at
updated_at
```

### dataset_exports

```text
id
dataset_id
format
file_url
generated_at
visibility
notes
```

MVP format:

```text
CSV
```

## MVP Audit Table

### audit_log

Required for sensitive changes.

```text
id
table_name
record_id
action
old_values
new_values
changed_by
changed_at
ip_address
user_agent
```

Minimum MVP actions:

```text
import_approved
visibility_changed
record_deleted
public_export_generated
```

## Phase 2+ Body, Device, and Lab Tables

Defer until needed:

### bloodwork_results

```text
id
test_date
marker_key
marker_name
value
unit
reference_low
reference_high
lab_name
fasting_status
source_document_id
confidence_level
visibility
notes
created_at
updated_at
```

### dexa_results

```text
id
scan_date
body_fat_percent
fat_mass_lb
lean_mass_lb
bone_density
provider
source_document_id
confidence_level
visibility
notes
created_at
updated_at
```

### progress_photo_sessions / progress_photos

Add only after redaction/watermark/storage policy is ready.

## Phase 2+ Product, Service, Affiliate, and Sponsor Tables

Defer until product review/affiliate workflow is active:

```text
brands
products
services
product_usage_windows
affiliate_links
affiliate_link_clicks
sponsor_relationships
product_reviews
```

These should include disclosure, sponsor status, usage windows, and auditability when built.

## Phase 2+ Entity and Content Tables

MVP content should use MDX + frontmatter.

Defer full entity graph tables until the site has enough pages to justify them:

```text
entities
entity_relationships
pages
page_entities
internal_links
schema_records
```

MVP can manually define relationships in MDX frontmatter.

Example:

```yaml
entities:
  - baseline-period
  - cronometer
  - bodyweight
related_methodology:
  - nutrition-logging
  - workout-logging
```

## Phase 2+ Approval and API Key Tables

Add when needed:

```text
approval_queue
api_keys
api_key_usage
```

MVP can use direct owner approval in the admin interface.

API keys are required before external agents/LLMs are connected.

## Daily Facts View

`daily_facts` is important but not required for the first MVP launch unless the dataset page needs it.

Recommended Phase 2 implementation:

```text
materialized view
one row per day
source tables documented
refresh strategy documented
visibility behavior tested
```

Potential fields:

```text
date
calories
protein_g
carbs_g
fat_g
fiber_g
sodium_mg
bodyweight_lb
training_completed
training_volume
sets_completed
supplement_adherence_pct
confounder_flags
notes
```

Do not expose `daily_facts` publicly until visibility/RLS behavior is tested.

## Indexing Priorities

MVP indexes:

```text
nutrition_logs(date)
nutrition_import_batches(file_hash)
measurements(metric_key, measured_at)
workout_sessions(date)
exercise_sets(workout_session_id)
supplement_logs(date, supplement_id)
experiments(slug, status)
datasets(slug, visibility)
```

Add more indexes based on actual query patterns.

## RLS Requirements

Sensitive MVP tables must include visibility and RLS policies:

```text
nutrition_logs
measurements
workout_sessions
supplement_logs
experiments
datasets
dataset_exports
confounder_logs if used
```

Default sensitive visibility:

```text
private
```

Public data must be explicitly promoted.

## Open Schema Questions

Resolved after audit:

```text
Long-form MVP content should live in MDX.
Use Drizzle for migrations unless future implementation proves otherwise.
Professional viewer accounts are Phase 2+.
Full entity/content graph is Phase 2+.
```

Still open:

- Should `measurements` fully replace specialized body/device tables long-term?
- Should bloodwork marker definitions be a separate table?
- Should experiment phases be separate from experiments?
- How much public raw nutrition data should be exposed vs summarized?
- Should public exports be generated files or API-generated on demand?

## Core Rule

```text
The MVP schema should be small enough to build correctly and strict enough to protect future trust.
```

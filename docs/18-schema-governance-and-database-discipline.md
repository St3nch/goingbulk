# GoingBulk Schema Governance and Database Discipline

## Purpose

This document defines the database discipline rules for GoingBulk.

GoingBulk may use Supabase for speed, convenience, auth, storage, and managed Postgres, but Supabase convenience must not become an excuse for sloppy schema design.

## Core Rule

```text
Supabase is the platform.
Postgres schema discipline is the architecture.
```

GoingBulk must not become database spaghetti because the dashboard makes it easy to add tables, columns, JSON blobs, or one-off fields.

## Hard Rule

```text
Do not add schema just because it is easy.
Add schema because the data has a clear domain, owner, purpose, relationship, and query need.
```

## Why This Matters

GoingBulk will contain years of data:

- nutrition logs;
- workout logs;
- supplement logs;
- body metrics;
- bloodwork;
- DEXA results;
- device readings;
- experiments;
- claims;
- products;
- services;
- affiliate links;
- content entities;
- reports;
- professional data explorer views.

Bad schema decisions early will make later analysis, exports, dashboards, and LLM tools unreliable.

## Database Design Goals

GoingBulk schema should be:

- explicit;
- relational where appropriate;
- queryable;
- auditable;
- migration-controlled;
- source-labeled;
- confidence-labeled;
- visibility-aware;
- export-friendly;
- LLM/tool-friendly through APIs;
- boring enough to trust.

## Agent and LLM Database Access Rule

Connected LLMs, agents, MCP tools, or automation systems must not access the GoingBulk database directly.

Correct access pattern:

```text
LLM or agent intent
-> governed tool/API client
-> GoingBulk API
-> Supabase/Postgres
```

Forbidden access pattern:

```text
LLM or agent
-> direct Supabase SQL/Postgres access
```

The API is the enforcement layer for:

- authorization;
- visibility rules;
- row-level access decisions;
- validation;
- write permissions;
- audit/event logging;
- source/confidence handling;
- public/professional/private boundaries.

Supabase/Postgres stores the truth, but external intelligence must interact through governed application APIs.

This mirrors the VedaOps posture: tools and agents are not database clients. They are bounded callers of governed interfaces.

## Supabase Usage Rules

### Allowed

Supabase may be used for:

- Postgres database hosting;
- Auth;
- Storage;
- Row Level Security;
- admin inspection;
- generated APIs where appropriate;
- local development support;
- quick MVP delivery.

### Not Allowed

Supabase convenience must not be used to justify:

- random table creation;
- unclear ownership;
- ambiguous JSON blobs;
- ungoverned column additions;
- bypassing migrations;
- mixing unrelated concepts in one table;
- direct public exposure of sensitive tables;
- unclear RLS policies;
- treating dashboard edits as schema governance.

## Schema Change Rule

Before adding a table, column, enum, relationship, or JSON field, answer:

```text
What domain does this belong to?
What question does this data answer?
Is this canonical data, imported data, derived data, or display data?
Who/what creates it?
Who/what reads it?
How will it be filtered, sorted, exported, or reported?
Does it need source, confidence, visibility, or audit fields?
Could it belong in an existing table?
Would adding it create duplicate truth?
Does this need a migration?
```

If those questions cannot be answered, do not add it yet.

## Canonical vs Imported vs Derived

Every data family should be classified.

### Canonical Data

GoingBulk-owned truth.

Examples:

```text
workout_sessions
exercise_sets
supplement_logs
experiments
product_reviews
entities
pages
```

### Imported Data

Data imported from another source and preserved with provenance.

Examples:

```text
Cronometer CSV rows
Hume exports
wearable imports
lab report values
```

### Derived Data

Calculated summaries or rollups.

Examples:

```text
daily_facts
weekly nutrition averages
training volume summaries
experiment comparison summaries
```

### Display Data

Presentation-specific data.

Examples:

```text
homepage cards
cached chart summaries
report snippets
```

Derived and display data must not masquerade as canonical truth.

## Raw Plus Normalized Rule

For imports, keep both raw and normalized forms.

```text
raw_import_rows
+
normalized_domain_records
```

Example:

```text
nutrition_import_rows
+
nutrition_logs
```

Raw import rows are the receipt.
Normalized records are the usable dataset.

## JSON Discipline Rule

JSON is allowed only when the structure is genuinely variable or externally sourced.

Allowed examples:

```text
raw Cronometer row payload
raw device export payload
schema json_ld
micronutrients_json if many variable nutrients exist
controlled metadata where structure is documented
```

Forbidden examples:

```text
putting entire workout sessions in JSON because it is faster
storing all experiment results as one blob
using JSON to avoid relationship design
hiding product review fields in untyped metadata
storing public/private visibility logic in vague JSON
```

Rule:

```text
If the field will be queried, filtered, sorted, validated, joined, exported, or used in reports repeatedly, it probably deserves explicit schema.
```

## Naming Rules

Use clear, boring names.

Good:

```text
nutrition_logs
workout_sessions
exercise_sets
supplement_logs
bloodwork_results
product_usage_windows
entity_relationships
```

Bad:

```text
data
items
stuff
logs2
misc
meta
records
health_json
```

## Relationship Rules

Use foreign keys where relationships matter.

Examples:

```text
nutrition_logs.source_batch_id -> nutrition_import_batches.id
exercise_sets.workout_session_id -> workout_sessions.id
supplement_logs.product_id -> products.id
product_reviews.product_id -> products.id
page_entities.page_id -> pages.id
page_entities.entity_id -> entities.id
```

Avoid string-only references when a stable relationship exists.

## Source, Confidence, Visibility Fields

Health, fitness, product, and measurement data should usually include:

```text
source
confidence_level
visibility
notes
created_at
updated_at
```

Measurement-style data may also include:

```text
method
device
conditions
unit
```

## Visibility Rule

Public exposure must be intentional.

Suggested visibility values:

```text
private
internal
professional
public
```

Default sensitive health data should not be public unless explicitly promoted.

## RLS Rule

If using Supabase Row Level Security, policies must be written intentionally.

Do not rely on vague assumptions such as:

```text
this table probably will not be queried publicly
```

RLS policy design should follow the visibility model.

## Migration Rule

Schema changes should be migration-controlled.

Avoid production schema changes made manually in the dashboard without a corresponding migration record.

Rule:

```text
If the app depends on it, it belongs in a migration.
```

## Enum and Controlled Vocabulary Rule

Use controlled values for repeated statuses and categories.

Examples:

```text
visibility
confidence_level
experiment_status
review_status
adherence_status
page_status
source_type
relationship_type
```

Do not let free-text status fields become chaos.

## Derived View Rule

Derived views like `daily_facts` should be generated from source tables.

They should be documented with:

- source tables;
- calculation rules;
- refresh timing;
- null handling;
- visibility handling;
- confidence handling.

## Indexing and Query Rule

Tables expected to power dashboards or filters should be designed for query patterns.

Likely indexes:

```text
nutrition_logs(date)
workout_sessions(date)
exercise_sets(workout_session_id)
supplement_logs(date, supplement_id)
measurements(metric_key, measured_at)
bloodwork_results(marker_key, test_date)
experiments(status)
products(slug)
entities(slug, entity_type)
pages(slug, status)
```

Indexing should follow actual query needs, not random guessing.

## Anti-Spaghetti Rules

Do not:

- duplicate the same truth in multiple canonical tables;
- create tables without clear ownership;
- use JSON as a junk drawer;
- add columns for one-off display needs;
- mix raw imports with normalized data;
- mix planned and actual records;
- mix private and public logic without visibility fields;
- rely on table names that require explanation every time;
- build LLM tools that query tables directly;
- skip migrations because Supabase makes manual edits easy.

## Schema Review Checklist

Before a schema change is accepted:

```text
Domain identified?
Canonical/imported/derived/display classification clear?
Relationships defined?
Visibility considered?
Source/confidence considered?
Migration needed?
Query pattern known?
Export/reporting impact considered?
RLS impact considered?
LLM/API access impact considered?
Does this reduce or increase duplicate truth?
```

## Good Default

When uncertain, slow down and document the decision.

A slightly slower schema decision is better than years of confusing data.

## Core Principle

```text
Good schema is how GoingBulk keeps its receipts trustworthy.
```

The database is not just storage. It is the credibility layer.

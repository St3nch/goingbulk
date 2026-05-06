# GoingBulk Nutrition Import Pipeline

## Purpose

GoingBulk should use Cronometer as the nutrition capture engine and GoingBulk as the organization, analysis, display, experiment, and publishing layer.

This avoids rebuilding a food database before the brand has launched.

## Core Model

```text
Cronometer
  = food logging and macro/micronutrient capture

GoingBulk
  = import, normalize, organize, analyze, display, publish, and connect nutrition to experiments
```

## Why This Is The Right Phase 1

Cronometer already handles:

- food search;
- verified foods;
- macros;
- micronutrients;
- serving sizes;
- custom foods;
- diary exports.

GoingBulk should not try to recreate Cronometer early.

GoingBulk should ingest the exported data and connect it to:

- bodyweight;
- workouts;
- supplements;
- bloodwork;
- DEXA;
- Hume/wearable readings;
- experiments;
- product reviews;
- public dashboards.

## Basic Pipeline

```text
Cronometer CSV export
-> GoingBulk import tool
-> raw import batch stored
-> import preview and validation
-> normalized nutrition logs
-> dashboard/report update
```

## MVP Workflow

1. Log food in Cronometer.
2. Export CSV daily or weekly.
3. Upload CSV in GoingBulk admin.
4. Preview import summary.
5. Flag duplicates or anomalies.
6. Approve import.
7. Update dashboard and experiment summaries.

## Future Automation Options

Later automation may include:

- folder watcher;
- email import;
- browser automation;
- third-party API bridge;
- Cronometer partner/API integration if available and affordable.

Automation should not bypass validation.

## Import Tables

### nutrition_import_batches

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
```

### nutrition_import_rows

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
```

### nutrition_logs

```text
id
date
meal_name
food_id
food_name_snapshot
grams
calories
protein
carbs
fat
fiber
sodium
sugar
source
source_batch_id
confidence
```

## Raw Plus Normalized Rule

Keep both:

```text
raw imported rows
+
normalized GoingBulk records
```

Raw rows preserve auditability.
Normalized records power dashboards and reporting.

## Validation Checks

The import tool should check for:

- duplicate date ranges;
- duplicate files using file hash;
- missing days;
- extreme calorie values;
- unusually low or high protein;
- macro totals that do not match calories approximately;
- missing core macro fields;
- weird sodium/fiber/sugar values;
- date/timezone mismatches.

## LLM Role

A future LLM assistant may help review imports, but should not blindly write data.

Good LLM tasks:

- summarize import;
- flag anomalies;
- map repeated food names;
- identify missing days;
- generate weekly nutrition summaries;
- explain changes in plain language;
- connect nutrition to active experiments.

Bad LLM tasks:

- silently correcting data;
- inventing missing values;
- overwriting imports without approval;
- treating estimates as verified values.

## Data Source Labels

Every nutrition record should carry a source.

Examples:

```text
Cronometer export
manual custom food
USDA FoodData Central
Open Food Facts
nutrition label
restaurant estimate
eyeballed estimate
```

## Confidence Labels

Suggested confidence levels:

| Source / Method | Confidence |
|---|---|
| Weighed food plus Cronometer verified entry | High |
| Packaged label plus weighed serving | High |
| Cronometer generic entry | Medium-high |
| USDA generic whole food | Medium-high |
| Open Food Facts packaged entry | Medium |
| Restaurant estimate | Low-medium |
| Eyeballed portion | Low |

## Public Methodology Statement

A public methodology page should say something like:

```text
Nutrition data is logged in Cronometer and imported into GoingBulk from diary exports. Foods are weighed when practical. Imported nutrition records are labeled by source and confidence. Estimates are marked as estimates.
```

## GoingBulk Value Add

Cronometer answers:

```text
What did I eat?
```

GoingBulk answers:

```text
What did that nutrition mean during my training, supplement use, experiments, body changes, bloodwork, DEXA scans, and product reviews?
```

## Long-Term Rule

Phase 1 can remain long-term.

GoingBulk does not need to own the full food database unless owning food search becomes strategically necessary.

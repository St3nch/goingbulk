# GoingBulk Detailed Nutrient Modeling

## Purpose

This document defines how GoingBulk stores detailed nutrition data beyond basic macros.

GoingBulk should not only track calories, protein, carbs, fat, fiber, sugar, and sodium. Cronometer exports can include many additional nutrients such as vitamins, minerals, amino acids, fatty acids, cholesterol, caffeine, water, potassium, magnesium, calcium, iron, zinc, vitamin D, B vitamins, omega-3, omega-6, and more.

The schema must preserve that detail without turning `nutrition_logs` into a 90-column monster or hiding normalized data in an unqueryable JSON blob.

## Core Decision

Use a hybrid model:

```text
nutrition_logs
= one row per normalized food/log item with common summary fields

nutrient_definitions
= controlled nutrient vocabulary and source-column mapping

nutrition_log_nutrients
= detailed nutrient values attached to each nutrition log
```

## Core Rule

```text
Keep common dashboard fields on nutrition_logs.
Store detailed nutrient facts in a normalized child table.
Keep raw import payloads as receipts, not as the normalized data model.
```

## Why This Matters

GoingBulk needs detailed nutrition data for:

- professional review;
- long-term nutrient trend analysis;
- experiment interpretation;
- possible bloodwork correlations later;
- supplement/product experiments;
- detailed dataset exports;
- future professional data explorer filters;
- credibility with doctors, nutritionists, and data-minded readers.

A basic macro-only schema would throw away too much useful data.

## Rejected Option 1: Put Every Nutrient On nutrition_logs

Do not create a massive table like:

```text
nutrition_logs
- calories
- protein_g
- carbs_g
- fat_g
- fiber_g
- sugar_g
- sodium_mg
- potassium_mg
- magnesium_mg
- calcium_mg
- iron_mg
- zinc_mg
- vitamin_d_iu
- vitamin_b12_mcg
- omega_3_g
- omega_6_g
- ... many more
```

Why rejected:

- too many columns;
- mostly sparse/null values;
- every new nutrient requires migration;
- difficult to maintain;
- ugly schema;
- not flexible across data sources;
- violates schema discipline.

## Rejected Option 2: Put Normalized Nutrients In JSONB

Do not use normalized JSON like:

```json
{
  "potassium_mg": 2629,
  "iron_mg": 14.2,
  "vitamin_d_iu": 140,
  "omega_3_g": 1.2
}
```

on `nutrition_logs` as the main nutrient model.

Why rejected:

- harder to query;
- harder to filter/sort;
- weaker type discipline;
- harder to index;
- harder to validate units;
- awkward for professional explorer tables;
- becomes a JSON junk drawer.

JSONB is allowed for raw import receipts, such as `nutrition_import_rows.raw_payload`, but not as the normalized nutrient model.

## Recommended Model

### nutrition_logs

`nutrition_logs` remains the parent table.

It stores one normalized food/log item and keeps the high-use macro summary fields.

Recommended summary fields:

```text
id
date
meal_name
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
source_row_id
confidence_level
visibility
notes
created_at
updated_at
```

These fields stay on the parent because they are used constantly for:

- daily dashboards;
- basic summaries;
- experiment pages;
- baseline reports;
- quick public tables;
- common charting.

### nutrient_definitions

Reference table defining every nutrient GoingBulk understands.

Recommended fields:

```text
id
nutrient_key
display_name
unit
category
sort_order
cronometer_column
daily_target
daily_target_unit
notes
created_at
updated_at
```

Recommended constraints:

```text
nutrient_key UNIQUE NOT NULL
```

Example rows:

```text
potassium_mg | Potassium | mg | mineral | Potassium (mg)
magnesium_mg | Magnesium | mg | mineral | Magnesium (mg)
vitamin_d_iu | Vitamin D | IU | vitamin | Vitamin D (IU)
omega_3_g | Omega-3 | g | lipid_detail | Omega-3 (g)
leucine_g | Leucine | g | amino_acid | Leucine (g)
```

RLS:

```text
public read
owner/admin write
```

This is reference data, not private health data.

### nutrition_log_nutrients

Child table storing detailed nutrient values for each nutrition log.

Recommended fields:

```text
id
nutrition_log_id
nutrient_key
value
created_at
```

Recommended constraints:

```text
nutrition_log_id REFERENCES nutrition_logs(id) ON DELETE CASCADE
nutrient_key REFERENCES nutrient_definitions(nutrient_key)
UNIQUE(nutrition_log_id, nutrient_key)
value NUMERIC(12,4) NOT NULL
```

Do not store `unit` here.

The unit lives in `nutrient_definitions` so potassium is always mg, vitamin D is always IU or whichever unit we intentionally define, and the table does not drift into mixed-unit chaos.

RLS:

```text
inherits visibility from nutrition_logs
owner/admin write
```

## Visibility Model

`nutrition_log_nutrients` should not have its own `visibility` column in MVP.

It inherits from `nutrition_logs.visibility`.

Correct access logic:

```text
Can the user see the parent nutrition_log?
If yes, they can see its detailed nutrients.
If no, they cannot.
```

RLS should enforce this through a policy that checks the parent `nutrition_logs` row.

## Import Pipeline Impact

Cronometer import should do this:

```text
1. Upload CSV.
2. Store raw rows in nutrition_import_rows.
3. Preserve full raw row in raw_payload JSONB.
4. On approval, create nutrition_logs parent rows.
5. For each mapped nutrient column, insert nutrition_log_nutrients rows.
```

The raw payload is still preserved.

The normalized nutrient facts become queryable rows.

## Source Mapping

`nutrient_definitions.cronometer_column` maps the exact Cronometer export column to GoingBulk's canonical nutrient key.

Example:

```text
Cronometer column: Potassium (mg)
GoingBulk nutrient_key: potassium_mg

Cronometer column: B12 (Cobalamin) (µg)
GoingBulk nutrient_key: vitamin_b12_mcg
```

If Cronometer changes column names later, update the mapping row instead of changing the schema.

## Nutrient Categories

Recommended initial categories:

```text
general
macro
carb_detail
lipid_detail
amino_acid
vitamin
mineral
other
```

Examples:

```text
general: energy_kcal, alcohol_g, caffeine_mg, water_g
macro: protein_g, carbs_g, fat_g, fiber_g
carb_detail: starch_g, sugars_g, added_sugars_g, net_carbs_g
lipid_detail: saturated_g, trans_fat_g, cholesterol_mg, omega_3_g, omega_6_g
amino_acid: leucine_g, lysine_g, valine_g
vitamin: vitamin_a_mcg, vitamin_c_mg, vitamin_d_iu, vitamin_b12_mcg
mineral: calcium_mg, iron_mg, magnesium_mg, potassium_mg, zinc_mg
```

## MVP Inclusion Decision

Include these tables in the MVP database foundation:

```text
nutrient_definitions
nutrition_log_nutrients
```

Reason:

- Cronometer already provides detailed nutrient data;
- the import pipeline is being built now;
- capturing the nutrient detail during import is easier than reprocessing months of old CSVs later;
- the tables are simple;
- they avoid major future rework;
- the MVP UI does not need to display every nutrient immediately.

This is not feature bloat. This is data preservation.

## Updated MVP Nutrition Table Set

The MVP nutrition schema should include:

```text
nutrition_import_batches
nutrition_import_rows
nutrition_logs
nutrient_definitions
nutrition_log_nutrients
```

`foods` remains deferred.

## Query Examples

### Daily macro dashboard

Use `nutrition_logs` directly:

```sql
SELECT date, SUM(calories), SUM(protein_g), SUM(carbs_g), SUM(fat_g)
FROM nutrition_logs
WHERE date BETWEEN $1 AND $2
GROUP BY date;
```

### Daily potassium trend

Use child nutrient rows:

```sql
SELECT nl.date, SUM(nln.value) AS potassium_mg
FROM nutrition_log_nutrients nln
JOIN nutrition_logs nl ON nl.id = nln.nutrition_log_id
WHERE nln.nutrient_key = 'potassium_mg'
GROUP BY nl.date
ORDER BY nl.date;
```

### All nutrients for a food log

```sql
SELECT nd.display_name, nd.unit, nln.value
FROM nutrition_log_nutrients nln
JOIN nutrient_definitions nd ON nd.nutrient_key = nln.nutrient_key
WHERE nln.nutrition_log_id = $1
ORDER BY nd.sort_order;
```

## Indexes

Recommended MVP indexes:

```text
nutrient_definitions(nutrient_key) UNIQUE
nutrient_definitions(cronometer_column)
nutrition_log_nutrients(nutrition_log_id)
nutrition_log_nutrients(nutrient_key)
nutrition_log_nutrients(nutrient_key, value)
```

## Data Quality Rules

- Only insert nutrient values that are present and parseable.
- Do not insert empty strings.
- Decide whether to skip zero values or store them intentionally.
- Preserve raw CSV values in `nutrition_import_rows.raw_payload` either way.
- Use `nutrient_definitions` as the source of truth for display names and units.
- Never infer units from free-text nutrient names at query time.

## Parent vs Child Authority

The macro columns on `nutrition_logs` are summary fields.

The child rows in `nutrition_log_nutrients` are the detailed nutrient receipt.

If parent macro values and child nutrient values disagree, treat it as a data quality bug and fix the import normalization.

## Deferred Work

Do not build these in MVP:

```text
full food database
USDA/Open Food Facts mappings
nutrient target personalization
professional nutrient explorer UI
bloodwork nutrient correlation views
complex daily_facts nutrient aggregates
```

These become useful later after the import pipeline is stable.

## Core Principle

```text
Do not throw away detailed nutrient data just because the first dashboard only shows macros.
```

GoingBulk should preserve the full nutrition receipt from day one while keeping the MVP user interface simple.

# GoingBulk MVP Schema Implementation Contract

---

# 1. Executive Verdict

**Is the MVP schema implementation-ready?** Almost. The table list is right, the phasing is correct, and the governance posture is sound. But there are ~15 concrete gaps that would cause real problems during Drizzle schema file creation.

**What must be fixed first:**

1. **Finalize every column's type, nullability, and default** — the docs list field names but not whether they're `NOT NULL`, what type they are, or what defaults apply. You cannot write a Drizzle schema file from a list of field names.
2. **Resolve the `nutrition_import_rows` ↔ `nutrition_logs` traceability link** — the docs mention `source_batch_id` on `nutrition_logs` but never define `source_row_id`. Without row-level traceability, you cannot debug bad imports.
3. **Define the owner bootstrap sequence** — the docs assume an owner account exists but never say how it gets created.

**Biggest strength:** The raw + normalized separation for imports, combined with the `file_hash` deduplication. This is the right architecture and will prevent data corruption during the most common operation (weekly Cronometer import).

**Biggest risk:** `exercise_sets` has no `visibility` column and no clear inheritance rule from `workout_sessions`. If someone queries exercise_sets directly (likely for volume calculations, dataset exports, or future daily_facts), RLS has nothing to filter on.

**Biggest schema decision to make before coding:** Whether `measurements.metric_key` should be a Postgres enum or free text with an app-level allowlist. Enum is safer but requires a migration every time you add a new metric. Free text with a check constraint is more flexible but less discoverable. I recommend a **text column with a CHECK constraint against a short allowlist** for MVP, migrating to enum or lookup table only if the list grows past ~15 entries.

---

# 2. Recommended Final MVP Table List

| Table | Status | Notes |
|---|---|---|
| `user_profiles` | **Required MVP** | Ties Supabase Auth to app roles |
| `nutrition_import_batches` | **Required MVP** | Import tracking and dedup |
| `nutrition_import_rows` | **Required MVP** | Raw receipt layer |
| `nutrition_logs` | **Required MVP** | Normalized nutrition records with common summary fields |
| `nutrient_definitions` | **Required MVP** | Controlled nutrient vocabulary and Cronometer column mapping |
| `nutrition_log_nutrients` | **Required MVP** | Detailed nutrient values per nutrition log |
| `measurements` | **Required MVP** | Bodyweight + future body metrics |
| `exercises` | **Required MVP** | Minimal exercise library |
| `workout_sessions` | **Required MVP** | Logged workouts |
| `exercise_sets` | **Required MVP** | Individual sets |
| `supplements` | **Required MVP** | Supplement definitions |
| `supplement_logs` | **Required MVP** | Daily taken/missed |
| `experiments` | **Required MVP** | Baseline experiment record |
| `confounder_logs` | **Optional MVP** | Useful but not blocking; include if time allows |
| `datasets` | **Required MVP** | Public dataset metadata |
| `dataset_exports` | **Required MVP** | Export file tracking |
| `audit_log` | **Required MVP** | Sensitive change tracking |
| `foods` | **Defer** | Cronometer row snapshots are sufficient for MVP |
| `daily_facts` | **Defer** | Materialized view, Phase 2 |
| All Phase 2+ tables | **Defer** | Per doc 16 deferred list |

**Total MVP tables: 17** (16 required + 1 optional `confounder_logs`)

This is still the right size because `nutrient_definitions` and `nutrition_log_nutrients` are data-preservation tables required by the Cronometer import pipeline, not extra UI/product scope.

---

# 3. Table-by-Table Review

## user_profiles

**Purpose:** App-level identity extending Supabase Auth.

**Primary key:** `id UUID` — REFERENCES `auth.users(id) ON DELETE CASCADE`. Do NOT use `gen_random_uuid()` here; the ID must match Supabase Auth.

**Required fields:**
```
id          UUID PK REFERENCES auth.users(id) ON DELETE CASCADE
email       TEXT UNIQUE NOT NULL
role        user_role_enum NOT NULL DEFAULT 'public'
created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Optional fields:** `display_name TEXT` — useful for admin UI but not critical.

**Foreign keys:** `id → auth.users(id) ON DELETE CASCADE`

**Constraints:** `UNIQUE(email)`

**Indexes:** PK is sufficient; email unique index is automatic.

**RLS:** Owner can read/update own. No public read needed.

**Audit:** Not needed — role changes should be audit-logged via `audit_log`.

**Concerns:**
- **Owner bootstrap problem.** When the Supabase project starts, there are zero `user_profiles` rows. The RLS helper `is_owner_or_admin()` queries this table. If no row exists, the owner is locked out. **Fix:** Use a Supabase Auth trigger or a seed migration:

```sql
-- Option A: DB trigger on auth.users insert
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, role)
  VALUES (NEW.id, NEW.email, 'public');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

Then manually promote the first user to `owner`:
```sql
UPDATE user_profiles SET role = 'owner' WHERE email = 'creator@goingbulk.com';
```

This should be a documented seed step, not left to chance.

- **MVP should only use `owner` and `public` roles.** The enum should include future values (`admin`, `editor`, `professional_viewer`) but the app code should only check for `owner` in Phase 1. This prevents future enum migrations.

---

## nutrition_import_batches

**Purpose:** Track uploaded Cronometer CSV files with deduplication.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                UUID PK DEFAULT gen_random_uuid()
source            log_source_enum NOT NULL DEFAULT 'cronometer_export'
file_name         TEXT NOT NULL
file_hash         TEXT UNIQUE NOT NULL
row_count         INTEGER           -- set after parsing
date_range_start  DATE              -- set after parsing
date_range_end    DATE              -- set after parsing
status            import_status_enum NOT NULL DEFAULT 'uploaded'
notes             TEXT
uploaded_by       UUID NOT NULL REFERENCES user_profiles(id)
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Removed:** `review_status` — redundant with `status`. The `import_status_enum` already covers `uploaded → previewed → approved → rejected → failed`. Don't duplicate status tracking.

**Removed:** `imported_at` — redundant with `created_at` for uploaded and `updated_at` for approval timestamp. If you need an explicit approval timestamp, add `approved_at TIMESTAMPTZ` instead.

**Added:** `uploaded_by` — critical for audit trail. Even with one owner, track who did it.

**Added:** `row_count` — useful for preview display ("This file contains 847 rows").

**Constraints:** `UNIQUE(file_hash)` prevents re-importing the same file.

**Indexes:**
```
UNIQUE(file_hash) -- automatic from constraint
idx_import_batches_status ON (status)
idx_import_batches_dates ON (date_range_start, date_range_end)
```

**RLS:** Admin-only. No public read. No anonymous access.

**Audit:** Log `status` changes (especially `approved` and `rejected`).

**Concerns:**
- `file_hash` should be SHA-256 of file contents, computed app-side before upload. Document this.
- `date_range_start` and `date_range_end` should be nullable on initial upload and populated during preview parsing. Make them `DATE NULL`.

---

## nutrition_import_rows

**Purpose:** Raw receipt of every row from a Cronometer CSV.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id              UUID PK DEFAULT gen_random_uuid()
batch_id        UUID NOT NULL REFERENCES nutrition_import_batches(id) ON DELETE CASCADE
row_number      INTEGER NOT NULL
row_hash        TEXT NOT NULL
raw_date        TEXT            -- raw string from CSV
raw_meal        TEXT
raw_food_name   TEXT
raw_amount      TEXT
raw_calories    TEXT
raw_protein     TEXT
raw_carbs       TEXT
raw_fat         TEXT
raw_fiber       TEXT
raw_sodium      TEXT
raw_sugar       TEXT
raw_payload     JSONB           -- full raw row for auditability
status          import_row_status_enum NOT NULL DEFAULT 'pending'
error_message   TEXT
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Key additions vs current doc:**

1. **`row_number INTEGER NOT NULL`** — Yes, include this. It lets you say "row 47 failed" in the preview UI and trace issues back to the CSV line.

2. **`row_hash TEXT NOT NULL`** — Yes, include this. Hash of `(raw_date, raw_meal, raw_food_name, raw_amount, raw_calories)` for row-level deduplication within and across batches. This catches re-imports that pass file_hash (e.g., slightly modified file with overlapping data).

3. **All raw columns are `TEXT`, not numeric.** This is correct. Raw import rows store whatever Cronometer exported. Type coercion happens during normalization. Do NOT use `DECIMAL` or `NUMERIC` on import rows.

4. **`raw_payload JSONB`** — Keep this. It's the ultimate audit fallback. Store the entire parsed CSV row as key-value pairs.

5. **`status` needs its own enum** separate from batch status:

```sql
CREATE TYPE import_row_status_enum AS ENUM (
  'pending',
  'validated',
  'normalized',
  'skipped',
  'error'
);
```

6. **`error_message TEXT`** — Added. When a row fails validation, store why.

7. **`mapped_food_id` — Remove for MVP.** Foods table is deferred. Don't add a foreign key to a table that doesn't exist.

**Constraints:**
```
UNIQUE(batch_id, row_number) -- no duplicate row numbers within a batch
```

**Deduplication strategy:**
```
UNIQUE(batch_id, row_hash) -- prevents duplicate rows within a batch
```

Cross-batch dedup should be app-level: during preview, check if any `row_hash` values already exist in `nutrition_import_rows` from approved batches. Flag them but don't block — the user decides.

**Indexes:**
```
idx_import_rows_batch ON (batch_id)
idx_import_rows_hash ON (row_hash) -- for cross-batch dedup lookup
```

**RLS:** Admin-only. Never public.

**Audit:** Not individually audited — batch-level audit covers these.

**Cascade:** `ON DELETE CASCADE` from batch. If a batch is deleted (rejected), its rows go with it.

---

## nutrition_logs

**Purpose:** Normalized, dashboard-ready nutrition records.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                  UUID PK DEFAULT gen_random_uuid()
date                DATE NOT NULL
meal_name           TEXT             -- 'Breakfast', 'Lunch', etc.
food_name_snapshot  TEXT NOT NULL     -- denormalized from import
grams               NUMERIC(8,2)
calories            NUMERIC(8,2) NOT NULL
protein_g           NUMERIC(8,2)
carbs_g             NUMERIC(8,2)
fat_g               NUMERIC(8,2)
fiber_g             NUMERIC(8,2)
sugar_g             NUMERIC(8,2)
sodium_mg           NUMERIC(8,2)
source              log_source_enum NOT NULL DEFAULT 'cronometer_export'
source_batch_id     UUID REFERENCES nutrition_import_batches(id) ON DELETE SET NULL
source_row_id       UUID REFERENCES nutrition_import_rows(id) ON DELETE SET NULL
confidence_level    confidence_enum NOT NULL DEFAULT 'medium'
visibility          visibility_enum NOT NULL DEFAULT 'private'
notes               TEXT
created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Key decisions:**

1. **`source_row_id` — YES, ADD THIS.** This is the critical traceability link the docs are missing. Without it, you can trace a nutrition log to its batch but not to the specific raw row. When someone asks "why does March 3rd show 450g of chicken?", you need to look at the raw import row. `ON DELETE SET NULL` — if the import row is purged, the normalized record survives but loses its receipt.

2. **`food_id` — Removed for MVP.** Foods table is deferred. Use `food_name_snapshot` only.

3. **`logged_at` — Removed.** For imports, `created_at` covers when it was created. For manual entries, `date` is the log date and `created_at` is when it was entered. Adding a third timestamp creates confusion.

4. **Numeric types:** Use `NUMERIC(8,2)` for nutrition values. Not `FLOAT` (rounding errors), not `INTEGER` (loses precision for partial servings). `NUMERIC(8,2)` handles up to 999,999.99 which is more than enough.

**Indexes:**
```
idx_nutrition_logs_date ON (date)
idx_nutrition_logs_visibility ON (visibility) WHERE visibility = 'public'
idx_nutrition_logs_source_batch ON (source_batch_id)
```

**RLS:** Visibility-based via `can_view_visibility(visibility)`.

**Audit:** Log visibility changes.

---

## nutrient_definitions

**Purpose:** Controlled vocabulary and Cronometer column mapping for detailed nutrients.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```text
id                UUID PK DEFAULT gen_random_uuid()
nutrient_key      TEXT UNIQUE NOT NULL
display_name      TEXT NOT NULL
unit              TEXT NOT NULL
category          TEXT NOT NULL
sort_order        INTEGER
cronometer_column TEXT
daily_target      NUMERIC(10,3)
daily_target_unit TEXT
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Constraints:**
```text
UNIQUE(nutrient_key)
```

**Indexes:**
```text
idx_nutrient_definitions_key ON (nutrient_key)
idx_nutrient_definitions_cronometer_column ON (cronometer_column)
```

**RLS:** Public read, owner/admin write.

**Audit:** Not required for MVP unless nutrient definitions are edited after launch.

**Concern:** Seed the initial Cronometer nutrient mappings early. This table is how GoingBulk preserves detailed nutrient facts without adding dozens of nullable columns to `nutrition_logs`.

---

## nutrition_log_nutrients

**Purpose:** Detailed nutrient values attached to a specific `nutrition_logs` parent row.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```text
id                UUID PK DEFAULT gen_random_uuid()
nutrition_log_id  UUID NOT NULL REFERENCES nutrition_logs(id) ON DELETE CASCADE
nutrient_key      TEXT NOT NULL REFERENCES nutrient_definitions(nutrient_key)
value             NUMERIC(12,4) NOT NULL
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Constraints:**
```text
UNIQUE(nutrition_log_id, nutrient_key)
```

**Indexes:**
```text
idx_nutrition_log_nutrients_log_id ON (nutrition_log_id)
idx_nutrition_log_nutrients_key ON (nutrient_key)
idx_nutrition_log_nutrients_key_value ON (nutrient_key, value)
```

**RLS:** Inherits visibility from `nutrition_logs` through an RLS policy that checks the parent record.

**Audit:** Parent import/batch audit is enough for MVP. Do not audit each nutrient child row individually.

**Concern:** Do not store `unit` on this table. Unit belongs in `nutrient_definitions` so potassium is always interpreted as mg, vitamin D as the chosen unit, and the schema avoids mixed-unit drift.

---

## measurements

**Purpose:** General body metrics. MVP: bodyweight. Future: waist, blood pressure, etc.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                UUID PK DEFAULT gen_random_uuid()
measured_at       TIMESTAMPTZ NOT NULL
metric_key        TEXT NOT NULL
value             NUMERIC(10,3) NOT NULL
unit              TEXT NOT NULL
source            log_source_enum NOT NULL DEFAULT 'manual'
device            TEXT                -- 'Renpho scale', 'tape measure'
method            TEXT                -- 'morning fasted', 'post-workout'
confidence_level  confidence_enum NOT NULL DEFAULT 'high'
conditions        TEXT                -- 'fasted', 'post-meal', etc.
visibility        visibility_enum NOT NULL DEFAULT 'private'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**`metric_key` decision:** Use `TEXT` with a `CHECK` constraint:

```sql
CHECK (metric_key IN (
  'bodyweight',
  'waist',
  'chest',
  'hips',
  'neck',
  'bicep_left',
  'bicep_right',
  'thigh_left',
  'thigh_right',
  'body_fat_estimate',
  'blood_pressure_systolic',
  'blood_pressure_diastolic',
  'resting_heart_rate'
))
```

**Why not enum:** Enums require migration to add values. Body measurement types will expand. A check constraint is easier to modify and more explicit than free text.

**Why not lookup table:** Overkill for MVP with <15 metric types. Add a `measurement_definitions` table in Phase 2 if the list grows.

**Indexes:**
```
idx_measurements_metric_date ON (metric_key, measured_at)
idx_measurements_visibility ON (visibility) WHERE visibility = 'public'
```

**RLS:** Visibility-based.

**Audit:** Log visibility changes.

**Concern:** `conditions` as free text is fine for MVP. Don't over-structure this yet.

---

## exercises

**Purpose:** Minimal exercise library for workout logging.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                      UUID PK DEFAULT gen_random_uuid()
name                    TEXT UNIQUE NOT NULL
slug                    TEXT UNIQUE NOT NULL
primary_muscle_group    TEXT           -- 'chest', 'back', etc.
secondary_muscle_groups TEXT[]         -- Postgres array
equipment               TEXT           -- 'barbell', 'dumbbell', etc.
movement_pattern        TEXT           -- 'push', 'pull', 'hinge', 'squat'
notes                   TEXT
created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**No visibility column needed.** Exercises are reference data, not personal health data. They don't need RLS beyond admin-only write.

**No RLS needed for reads.** Exercise names aren't sensitive. Public read is fine. Admin-only write.

**Indexes:** `UNIQUE(slug)` automatic from constraint. PK sufficient otherwise.

**Concern:** `primary_muscle_group` and `equipment` and `movement_pattern` — use `TEXT` with app-level validation for MVP. Don't create enums for these; the lists are long and you'll iterate on taxonomy. Consider enums in Phase 2 once the exercise library stabilizes.

**Seed data:** Include 30-50 common exercises in the seed migration. Don't make the creator type "Bench Press" on day one.

---

## workout_sessions

**Purpose:** Logged actual workout sessions.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                UUID PK DEFAULT gen_random_uuid()
date              DATE NOT NULL
started_at        TIMESTAMPTZ
ended_at          TIMESTAMPTZ
session_type      TEXT                -- 'push', 'pull', 'legs', 'upper', 'lower', 'full_body'
duration_minutes  INTEGER
status            workout_status_enum NOT NULL DEFAULT 'in_progress'
notes             TEXT
visibility        visibility_enum NOT NULL DEFAULT 'private'
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**New enum needed:**
```sql
CREATE TYPE workout_status_enum AS ENUM ('planned', 'in_progress', 'completed', 'cancelled');
```

MVP will mostly use `in_progress` → `completed`. Include `planned` and `cancelled` for completeness — they're free to add now and expensive to add later.

**Indexes:**
```
idx_workout_sessions_date ON (date)
idx_workout_sessions_visibility ON (visibility) WHERE visibility = 'public'
```

**RLS:** Visibility-based.

**Concern:** `session_type` as free text is intentional — session types vary by program and shouldn't be constrained by an enum. App can suggest values.

---

## exercise_sets

**Purpose:** Individual performed sets within a workout session.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                  UUID PK DEFAULT gen_random_uuid()
workout_session_id  UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE
exercise_id         UUID NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT
set_number          INTEGER NOT NULL
set_type            set_type_enum NOT NULL DEFAULT 'working'
actual_reps         INTEGER
actual_load         NUMERIC(8,2)
load_unit           TEXT NOT NULL DEFAULT 'lb'
rpe                 NUMERIC(3,1)       -- 6.0 to 10.0
rest_seconds        INTEGER
notes               TEXT
created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**New enum:**
```sql
CREATE TYPE set_type_enum AS ENUM ('warmup', 'working', 'backoff', 'drop', 'failure', 'amrap');
```

**Critical question: Does exercise_sets need its own visibility column?**

**Answer: No for MVP.** Exercise sets should inherit visibility from `workout_sessions`. The cost of maintaining per-set visibility is high and the use case is near zero (who would make set 3 public but set 4 private?).

**Implementation:** When querying exercise_sets for public display, always JOIN through workout_sessions and filter on `workout_sessions.visibility`. RLS on exercise_sets should check the parent session's visibility:

```sql
CREATE POLICY "sets_inherit_session_visibility"
ON exercise_sets FOR SELECT
USING (
  can_view_visibility(
    (SELECT visibility FROM workout_sessions WHERE id = exercise_sets.workout_session_id)
  )
);
```

This is a subquery in RLS, which works but has performance implications on large tables. For MVP volumes (~50-200 sets/month), this is fine. Revisit if performance degrades.

**FK cascade decisions:**
- `workout_session_id → ON DELETE CASCADE` — Delete session = delete its sets. Correct.
- `exercise_id → ON DELETE RESTRICT` — Don't let someone delete an exercise that has logged sets. Correct.

**Indexes:**
```
idx_exercise_sets_session ON (workout_session_id)
idx_exercise_sets_exercise ON (exercise_id)
```

**Concern:** `rpe` as `NUMERIC(3,1)` allows 0.0–99.9 but RPE is typically 1–10 in half increments. Add:
```sql
CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10))
```

---

## supplements

**Purpose:** Supplement definitions (not logs).

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                UUID PK DEFAULT gen_random_uuid()
name              TEXT UNIQUE NOT NULL
slug              TEXT UNIQUE NOT NULL
category          TEXT              -- 'performance', 'health', 'vitamin', etc.
active_ingredient TEXT
default_dose      TEXT              -- '5g', '1 capsule'
default_unit      TEXT              -- 'g', 'mg', 'capsule', 'scoop'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**Added:** `default_dose` and `default_unit` — speeds up daily supplement logging by pre-filling values.

**No visibility column.** Supplement definitions aren't sensitive. The logs are.

**Indexes:** `UNIQUE(slug)` automatic. PK sufficient.

**RLS:** Public read, admin write. Non-sensitive reference data.

---

## supplement_logs

**Purpose:** Daily taken/missed supplement tracking.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                UUID PK DEFAULT gen_random_uuid()
date              DATE NOT NULL
supplement_id     UUID NOT NULL REFERENCES supplements(id) ON DELETE RESTRICT
dose              TEXT              -- '5g', '1 capsule'
unit              TEXT              -- 'g', 'mg', 'capsule'
time_taken        TEXT              -- 'morning', 'pre-workout', 'with-dinner'
adherence_status  adherence_status_enum NOT NULL DEFAULT 'pending'
source            log_source_enum NOT NULL DEFAULT 'manual'
confidence_level  confidence_enum NOT NULL DEFAULT 'high'
visibility        visibility_enum NOT NULL DEFAULT 'private'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**New enum:**
```sql
CREATE TYPE adherence_status_enum AS ENUM ('pending', 'taken', 'missed', 'skipped');
```

**Concern:** `dose` and `unit` as TEXT is fine for MVP. Don't over-type this — "1 capsule", "5g", "2 scoops" are all valid and hard to normalize cleanly. If analytics need numeric dose later, add `dose_numeric NUMERIC` and `dose_unit_normalized TEXT` in Phase 2.

**Constraint:** Consider a unique constraint to prevent double-logging:
```sql
UNIQUE(date, supplement_id, time_taken)
```
This prevents logging "Creatine morning" twice on the same day. But `time_taken` may be null for supplements without time specificity. Conditional unique index:
```sql
CREATE UNIQUE INDEX idx_supplement_logs_dedup
ON supplement_logs(date, supplement_id, COALESCE(time_taken, ''))
```

**Indexes:**
```
idx_supplement_logs_date ON (date)
idx_supplement_logs_supplement_date ON (supplement_id, date)
```

**RLS:** Visibility-based.

---

## experiments

**Purpose:** Structured experiment metadata. MVP: one baseline experiment.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                UUID PK DEFAULT gen_random_uuid()
title             TEXT NOT NULL
slug              TEXT UNIQUE NOT NULL
experiment_type   TEXT NOT NULL DEFAULT 'baseline'
status            experiment_status_enum NOT NULL DEFAULT 'planned'
question          TEXT
hypothesis        TEXT
protocol_summary  TEXT
baseline_start    DATE
baseline_end      DATE
intervention_start DATE
intervention_end   DATE
followup_start    DATE
followup_end      DATE
primary_metrics   TEXT[]            -- Postgres array of metric keys
secondary_metrics TEXT[]
confidence_level  confidence_enum DEFAULT 'medium'
verdict           TEXT              -- free text for MVP
visibility        visibility_enum NOT NULL DEFAULT 'private'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**New enum:**
```sql
CREATE TYPE experiment_status_enum AS ENUM (
  'planned', 'baseline', 'active', 'followup', 'completed', 'abandoned'
);
```

**Concern about `primary_metrics TEXT[]` and `secondary_metrics TEXT[]`:** These are arrays of metric key names like `['bodyweight', 'training_volume', 'protein_daily_avg']`. For MVP, this is fine as a display/reference field. Don't create an `experiment_metrics` junction table yet. If you need formal metric tracking per experiment, add it in Phase 2.

**Concern about `verdict TEXT`:** Free text is correct for MVP. Don't enum this. Verdicts like "worth continuing", "inconclusive — too many confounders", "not worth the cost" don't fit clean enums.

**Indexes:**
```
UNIQUE(slug)
idx_experiments_status ON (status)
idx_experiments_visibility ON (visibility) WHERE visibility = 'public'
```

**RLS:** Visibility-based.

**Audit:** Log status changes and visibility promotions.

---

## confounder_logs

**Purpose:** Daily confounder flags for experiment quality.

**Status: Optional MVP.** Include if time allows. Worth it because it enriches the baseline experiment quality.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id              UUID PK DEFAULT gen_random_uuid()
date            DATE NOT NULL
confounder_type TEXT NOT NULL
severity        TEXT              -- 'minor', 'moderate', 'major'
impact_areas    TEXT[]            -- ['nutrition', 'training', 'sleep']
notes           TEXT
visibility      visibility_enum NOT NULL DEFAULT 'private'
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**`confounder_type` as TEXT with CHECK constraint** (same rationale as `metric_key`):
```sql
CHECK (confounder_type IN (
  'poor_sleep', 'high_stress', 'illness', 'injury', 'travel',
  'missed_workout', 'missed_supplement', 'alcohol',
  'new_program', 'calorie_change', 'medication_change'
))
```

**`severity` as TEXT with CHECK:**
```sql
CHECK (severity IS NULL OR severity IN ('minor', 'moderate', 'major'))
```

**No `updated_at`** — confounders are write-once entries, not edited. If wrong, delete and re-enter.

**Indexes:**
```
idx_confounder_logs_date ON (date)
```

**RLS:** Visibility-based.

---

## datasets

**Purpose:** Public dataset metadata for the baseline dataset.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id                    UUID PK DEFAULT gen_random_uuid()
name                  TEXT NOT NULL
slug                  TEXT UNIQUE NOT NULL
description           TEXT
date_range_start      DATE NOT NULL
date_range_end        DATE NOT NULL
source_summary        TEXT
methodology_summary   TEXT
limitations           TEXT
visibility            visibility_enum NOT NULL DEFAULT 'private'
created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**No experiment_id FK for MVP.** A dataset may span multiple experiments or none. Use MDX frontmatter to link them for now.

**Indexes:**
```
UNIQUE(slug)
idx_datasets_visibility ON (visibility) WHERE visibility = 'public'
```

**RLS:** Visibility-based.

---

## dataset_exports

**Purpose:** Track generated export files.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id           UUID PK DEFAULT gen_random_uuid()
dataset_id   UUID NOT NULL REFERENCES datasets(id) ON DELETE CASCADE
format       TEXT NOT NULL DEFAULT 'csv'
file_url     TEXT NOT NULL          -- Supabase Storage path
file_size    INTEGER                -- bytes
row_count    INTEGER
generated_by UUID REFERENCES user_profiles(id)
generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
visibility   visibility_enum NOT NULL DEFAULT 'private'
notes        TEXT
```

**Added:** `file_size`, `row_count`, `generated_by` — useful for admin UI and audit trail.

**Format as TEXT with CHECK:**
```sql
CHECK (format IN ('csv', 'json'))
```

MVP only needs CSV. Include JSON in the check constraint for free.

**Indexes:**
```
idx_dataset_exports_dataset ON (dataset_id)
```

**RLS:** Visibility-based. Public exports visible to anonymous users.

---

## audit_log

**Purpose:** Track sensitive changes.

**Primary key:** `id UUID DEFAULT gen_random_uuid()`

**Required fields:**
```
id          UUID PK DEFAULT gen_random_uuid()
table_name  TEXT NOT NULL
record_id   UUID NOT NULL
action      TEXT NOT NULL
old_values  JSONB
new_values  JSONB
changed_by  UUID REFERENCES user_profiles(id)
changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
ip_address  INET
user_agent  TEXT
```

**`action` as TEXT, not enum.** Audit actions will expand unpredictably. Use text with app-level constants:
```typescript
const AUDIT_ACTIONS = {
  IMPORT_APPROVED: 'import_approved',
  IMPORT_REJECTED: 'import_rejected',
  VISIBILITY_CHANGED: 'visibility_changed',
  RECORD_DELETED: 'record_deleted',
  EXPORT_GENERATED: 'export_generated',
  EXPERIMENT_STATUS_CHANGED: 'experiment_status_changed',
} as const;
```

**`old_values` / `new_values` as JSONB — yes for MVP.** This is the right tradeoff. Structured audit columns would require a different table per audited entity. JSONB is flexible and the query patterns are simple (mostly "show me the audit trail for record X").

**Indexes:**
```
idx_audit_log_table_record ON (table_name, record_id)
idx_audit_log_changed_at ON (changed_at)
```

**RLS:** Admin-only. Never public. Never delete audit rows.

**Implementation: App-level, not DB triggers for MVP.** DB triggers add complexity and are harder to test. In the Next.js API route or server action, write the audit row after the main operation. Phase 2 can add DB triggers for critical tables if app-level audit is unreliable.

**`changed_by` nullable concern:** Service-role operations or migrations won't have a user. Allow NULL but log `'system'` or `'migration'` in the `action` field.

---

# 4. Enum and Controlled Vocabulary Recommendations

**MVP Enums (define in first migration):**

```sql
CREATE TYPE visibility_enum AS ENUM ('private', 'internal', 'professional', 'public');
CREATE TYPE confidence_enum AS ENUM ('low', 'medium', 'high', 'experimental');
CREATE TYPE user_role_enum AS ENUM ('owner', 'admin', 'editor', 'professional_viewer', 'public');
CREATE TYPE import_status_enum AS ENUM ('uploaded', 'previewed', 'approved', 'rejected', 'failed');
CREATE TYPE import_row_status_enum AS ENUM ('pending', 'validated', 'normalized', 'skipped', 'error');
CREATE TYPE log_source_enum AS ENUM ('manual', 'cronometer_export', 'device_import', 'lab_report', 'estimated');
CREATE TYPE workout_status_enum AS ENUM ('planned', 'in_progress', 'completed', 'cancelled');
CREATE TYPE set_type_enum AS ENUM ('warmup', 'working', 'backoff', 'drop', 'failure', 'amrap');
CREATE TYPE adherence_status_enum AS ENUM ('pending', 'taken', 'missed', 'skipped');
CREATE TYPE experiment_status_enum AS ENUM ('planned', 'baseline', 'active', 'followup', 'completed', 'abandoned');
```

**Use TEXT + CHECK for (avoid enum):**
- `measurements.metric_key` — will grow; CHECK is easier to modify
- `confounder_logs.confounder_type` — same rationale
- `confounder_logs.severity` — only 3 values but may evolve
- `exercises.primary_muscle_group` / `equipment` / `movement_pattern` — long taxonomy lists
- `supplement_logs.time_taken` — too varied for enum
- `dataset_exports.format` — only 2 values; CHECK is sufficient
- `audit_log.action` — unpredictable growth

**Rule of thumb:** Use Postgres enum when: values are small, stable, and appear across multiple tables. Use TEXT + CHECK when: values may grow, are table-specific, or would need frequent migration.

---

# 5. RLS Implementation Review

## Recommended MVP RLS Structure

The doc 25 design is solid. Here's the implementation-ready version:

### Step 1: Create helper functions (in migration)

```sql
-- Returns current user's role or NULL for anonymous
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS user_role_enum AS $$
  SELECT role FROM public.user_profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Returns true if current user is owner or admin
CREATE OR REPLACE FUNCTION public.is_owner_or_admin()
RETURNS boolean AS $$
  SELECT COALESCE(
    (SELECT role IN ('owner', 'admin') FROM public.user_profiles WHERE id = auth.uid()),
    false
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Returns true if current user can view the given visibility level
CREATE OR REPLACE FUNCTION public.can_view_visibility(record_visibility visibility_enum)
RETURNS boolean AS $$
  SELECT CASE
    WHEN record_visibility = 'public' THEN true
    WHEN record_visibility = 'professional' THEN
      COALESCE(public.current_user_role() IN ('owner', 'admin', 'professional_viewer'), false)
    WHEN record_visibility = 'internal' THEN
      COALESCE(public.current_user_role() IN ('owner', 'admin', 'editor'), false)
    WHEN record_visibility = 'private' THEN
      COALESCE(public.current_user_role() IN ('owner', 'admin'), false)
    ELSE false
  END;
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

**SECURITY DEFINER safety notes:**
- These functions run as the function creator (usually `postgres`), bypassing RLS to read `user_profiles`. This is intentional — otherwise RLS on `user_profiles` would block the helper from reading roles.
- **Never expose these functions to the public schema if they return mutable data.** The functions above are read-only and return booleans/enums, so they're safe.
- **Never use SECURITY DEFINER on functions that write data** unless absolutely necessary.
- Set `search_path` explicitly to prevent path injection:
```sql
CREATE OR REPLACE FUNCTION public.is_owner_or_admin()
RETURNS boolean AS $$
  SELECT COALESCE(
    (SELECT role IN ('owner', 'admin') FROM public.user_profiles WHERE id = auth.uid()),
    false
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public;
```

### Step 2: Enable RLS and create policies per table

**Pattern for visibility-based tables** (nutrition_logs, measurements, workout_sessions, supplement_logs, experiments, confounder_logs, datasets, dataset_exports):

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Public/anonymous can read only public records
CREATE POLICY "select_by_visibility" ON table_name
  FOR SELECT USING (public.can_view_visibility(visibility));

-- Owner/admin can insert
CREATE POLICY "owner_admin_insert" ON table_name
  FOR INSERT WITH CHECK (public.is_owner_or_admin());

-- Owner/admin can update
CREATE POLICY "owner_admin_update" ON table_name
  FOR UPDATE USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

-- Owner/admin can delete
CREATE POLICY "owner_admin_delete" ON table_name
  FOR DELETE USING (public.is_owner_or_admin());
```

**Pattern for admin-only tables** (nutrition_import_batches, nutrition_import_rows, audit_log):

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_only_all" ON table_name
  FOR ALL USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());
```

**Pattern for reference tables** (exercises, supplements, nutrient_definitions):

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Anyone can read
CREATE POLICY "public_read" ON table_name
  FOR SELECT USING (true);

-- Only owner/admin can write
CREATE POLICY "owner_admin_write" ON table_name
  FOR INSERT WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "owner_admin_update" ON table_name
  FOR UPDATE USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "owner_admin_delete" ON table_name
  FOR DELETE USING (public.is_owner_or_admin());
```

**Pattern for exercise_sets** (inherits from parent):
```sql
ALTER TABLE exercise_sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sets_select_via_session" ON exercise_sets
  FOR SELECT USING (
    public.can_view_visibility(
      (SELECT visibility FROM workout_sessions WHERE id = exercise_sets.workout_session_id)
    )
  );

CREATE POLICY "sets_write_admin" ON exercise_sets
  FOR INSERT WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "sets_update_admin" ON exercise_sets
  FOR UPDATE USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "sets_delete_admin" ON exercise_sets
  FOR DELETE USING (public.is_owner_or_admin());
```

### What NOT to expose publicly:
- `nutrition_import_batches` — admin only
- `nutrition_import_rows` — admin only
- `audit_log` — admin only
- `user_profiles` — owner can read/update own; no public read

### MVP RLS Testing Checklist
```
For each sensitive table:
[ ] Anonymous user: can only SELECT rows where visibility = 'public'
[ ] Anonymous user: cannot INSERT/UPDATE/DELETE
[ ] Owner: can SELECT all rows regardless of visibility
[ ] Owner: can INSERT/UPDATE/DELETE
[ ] No service role key in browser code
[ ] Test with actual Supabase anon key, not service role
```

---

# 6. Import Pipeline Schema Review

## Current State Assessment

The pipeline design is the strongest part of the schema. The raw + normalized separation is correct. Specific implementation notes:

### file_hash
**Recommendation:** SHA-256 of raw file bytes, computed in the Next.js API route before upload. Store as hex string. Checked against `nutrition_import_batches.file_hash` UNIQUE constraint before insert.

```typescript
import { createHash } from 'crypto';

function computeFileHash(buffer: Buffer): string {
  return createHash('sha256').update(buffer).digest('hex');
}
```

### row_hash
**Recommendation:** SHA-256 of concatenated key fields: `raw_date|raw_meal|raw_food_name|raw_amount|raw_calories`. This catches duplicate food entries even across different CSV exports.

```typescript
function computeRowHash(row: CsvRow): string {
  const key = [row.date, row.meal, row.food_name, row.amount, row.calories].join('|');
  return createHash('sha256').update(key).digest('hex');
}
```

### row_number
**Recommendation:** Include. 1-indexed position in CSV after header row. Stored as `INTEGER NOT NULL`. Essential for "row 47 has a problem" feedback in preview UI.

### raw_payload JSONB
**Recommendation:** Store the entire CSV row as `{"Date": "2027-01-15", "Meal": "Breakfast", ...}` preserving original column names. This is the ultimate audit fallback. Even if your column mapping changes, the raw payload preserves the original.

### Import Preview Workflow

```
1. Upload CSV → compute file_hash → check for duplicate batch
2. Parse CSV → create nutrition_import_batches (status: 'uploaded')
3. Insert all rows into nutrition_import_rows (status: 'pending')
4. Run validation:
   a. Check each row_hash against existing approved batches
   b. Flag extreme values (calories > 5000, protein > 500g)
   c. Check date continuity (missing days?)
   d. Mark rows as 'validated' or 'error'
5. Update batch status to 'previewed'
6. Show preview UI: valid rows, flagged rows, duplicate warnings
7. Creator reviews → approves or rejects
8. On approve:
   a. Update batch status to 'approved'
   b. For each validated row, create nutrition_log record
   c. Update row status to 'normalized'
   d. Write audit_log entry
9. On reject:
   a. Update batch status to 'rejected'
   b. Write audit_log entry
```

### Normalized nutrition_logs Creation

When batch is approved, each validated import row generates one `nutrition_log`:

```typescript
function normalizeImportRow(row: NutritionImportRow, batchId: string): InsertNutritionLog {
  return {
    date: parseDate(row.raw_date),
    meal_name: row.raw_meal || null,
    food_name_snapshot: row.raw_food_name,
    calories: parseNumeric(row.raw_calories),
    protein_g: parseNumeric(row.raw_protein),
    carbs_g: parseNumeric(row.raw_carbs),
    fat_g: parseNumeric(row.raw_fat),
    fiber_g: parseNumeric(row.raw_fiber),
    sugar_g: parseNumeric(row.raw_sugar),
    sodium_mg: parseNumeric(row.raw_sodium),
    source: 'cronometer_export',
    source_batch_id: batchId,
    source_row_id: row.id,
    confidence_level: 'medium',
    visibility: 'private',
  };
}
```

### Deduplication Strategy

**Level 1 — File level:** `file_hash` UNIQUE prevents re-uploading the exact same file. This catches accidental double-uploads.

**Level 2 — Row level within batch:** `UNIQUE(batch_id, row_number)` prevents duplicate row insertion during parsing.

**Level 3 — Row level across batches:** During preview, query:
```sql
SELECT row_hash FROM nutrition_import_rows
WHERE status = 'normalized'
AND row_hash = ANY($1::text[])
```
Flag matches as "already imported" in preview UI. Let creator decide to skip or reimport.

**Level 4 — Date range overlap:** During preview, check if `nutrition_logs` already exist for dates in the new batch:
```sql
SELECT DISTINCT date FROM nutrition_logs
WHERE date BETWEEN $1 AND $2
AND source_batch_id IS NOT NULL
```
Warn: "You already have nutrition data for Jan 15, 16, 17. Importing will create duplicates."

---

# 7. Audit Logging Review

## Minimum MVP Audit Actions

```
import_approved        — Cronometer batch approved
import_rejected        — Cronometer batch rejected
visibility_changed     — any record promoted from private to public (or demoted)
record_deleted         — any deletion of nutrition_logs, measurements, workouts, supplements
export_generated       — public dataset export created
experiment_status_changed — experiment moved between phases
role_changed           — user role updated (owner bootstrap, etc.)
```

## old_values/new_values JSONB

**Verdict: Yes, use JSONB for MVP.** Store the relevant changed fields, not the entire row:

```typescript
// Good — focused
await insertAudit({
  table_name: 'experiments',
  record_id: experiment.id,
  action: 'visibility_changed',
  old_values: { visibility: 'private' },
  new_values: { visibility: 'public' },
  changed_by: user.id,
});

// Bad — storing entire row
await insertAudit({
  old_values: entireOldRow, // too much noise
  new_values: entireNewRow,
});
```

## changed_by Behavior

- For user actions: `auth.uid()` from Supabase session
- For system actions (migrations, cron): `NULL` with action like `'system_migration'`
- For import approval: the user who clicked approve

## App-Level vs DB Triggers

**MVP: App-level only.** Write audit entries in the Next.js API route/server action after the main operation succeeds. Wrap in a transaction if you need atomicity.

**Phase 2 consideration:** Add Postgres triggers for `DELETE` operations on sensitive tables as a safety net (app code might forget to audit a deletion, but a trigger won't).

---

# 8. Reports/Datasets Decision

**Verdict: No reports table in MVP. MDX + datasets table is sufficient.**

**Rationale:**
- The baseline experiment "report" is an MDX page at `/experiments/baseline-30-days`
- The baseline dataset is a row in `datasets` table linking to a CSV export in `dataset_exports`
- A `reports` table would duplicate what MDX provides (title, content, metadata) with added schema complexity
- Phase 2 can add a `reports` table when repeatable monthly reports need structured metadata

**MVP content architecture:**
```
MDX pages        → experiment writeups, methodology, about, disclaimers
datasets table   → structured dataset metadata (date range, sources, limitations)
dataset_exports  → actual CSV files in Supabase Storage
```

**When to add a reports table:** When you need to generate the same report structure programmatically (monthly summaries with consistent sections), or when you need to query reports by metadata (date range, experiment, metrics covered). That's Phase 2.

---

# 9. Drizzle Implementation Notes

## Schema File Organization

```
src/
  db/
    schema/
      enums.ts           -- all enum definitions
      user-profiles.ts
      nutrition-imports.ts   -- batches + rows
      nutrition-logs.ts
      measurements.ts
      exercises.ts
      workout-sessions.ts
      exercise-sets.ts
      supplements.ts
      supplement-logs.ts
      experiments.ts
      confounder-logs.ts
      datasets.ts
      dataset-exports.ts
      audit-log.ts
      index.ts            -- re-exports all tables
    migrations/
      0000_initial_enums.sql
      0001_user_profiles.sql
      0002_nutrition_pipeline.sql
      0003_measurements.sql
      0004_workout_tables.sql
      0005_supplement_tables.sql
      0006_experiments.sql
      0007_datasets.sql
      0008_audit_log.sql
      0009_rls_policies.sql
      0010_rls_helper_functions.sql
      0011_seed_exercises.sql
    seed.ts               -- dev seed with fake data
    client.ts             -- Supabase/Drizzle client setup
```

## Enum Creation in Drizzle

```typescript
// src/db/schema/enums.ts
import { pgEnum } from 'drizzle-orm/pg-core';

export const visibilityEnum = pgEnum('visibility_enum', [
  'private', 'internal', 'professional', 'public'
]);

export const confidenceEnum = pgEnum('confidence_enum', [
  'low', 'medium', 'high', 'experimental'
]);

export const userRoleEnum = pgEnum('user_role_enum', [
  'owner', 'admin', 'editor', 'professional_viewer', 'public'
]);

// ... etc
```

## RLS in Drizzle Migrations

Drizzle doesn't natively manage RLS policies. Use custom SQL migrations:

```typescript
// In drizzle.config.ts, ensure custom SQL migrations are supported
// Then create raw SQL migration files for RLS

// migrations/0009_rls_policies.sql
ALTER TABLE nutrition_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_by_visibility" ON nutrition_logs
  FOR SELECT USING (public.can_view_visibility(visibility));

-- ... etc
```

**Critical:** RLS helper functions and policies MUST be in migration files. Don't create them through the Supabase dashboard.

## Supabase Auth References

Drizzle can reference `auth.users` but cannot manage it:

```typescript
// user-profiles.ts
import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core';
import { userRoleEnum } from './enums';
import { sql } from 'drizzle-orm';

export const userProfiles = pgTable('user_profiles', {
  id: uuid('id').primaryKey(), // NOT defaultRandom — matches auth.users
  email: text('email').unique().notNull(),
  role: userRoleEnum('role').notNull().default('public'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});
```

The FK to `auth.users` must be created via raw SQL migration since Drizzle can't reference the `auth` schema:

```sql
-- In 0001_user_profiles.sql
ALTER TABLE user_profiles
  ADD CONSTRAINT fk_user_profiles_auth
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
```

## Seed/Bootstrap Approach

```typescript
// src/db/seed.ts
// Run ONLY in local/development. Never in production.

async function seed() {
  // 1. Insert exercise library
  await db.insert(exercises).values(SEED_EXERCISES);
  
  // 2. Insert supplement definitions
  await db.insert(supplements).values(SEED_SUPPLEMENTS);
  
  // 3. Insert test experiment
  await db.insert(experiments).values({
    title: 'Baseline 30 Days',
    slug: 'baseline-30-days',
    experiment_type: 'baseline',
    status: 'planned',
    visibility: 'private',
  });
  
  // 4. DO NOT seed user_profiles — that's handled by auth trigger
}
```

**Production bootstrap:**
1. Create Supabase project
2. Run all migrations
3. Sign up first user through Supabase Auth
4. Auth trigger creates `user_profiles` row with role `public`
5. Manually promote to owner: `UPDATE user_profiles SET role = 'owner' WHERE email = '...'`
6. Seed exercises and supplements via admin UI or one-time script

## Local/Staging/Prod Considerations

- **Local:** Use `supabase start` for local Supabase instance. Run migrations via Drizzle CLI. Seed with fake data.
- **Staging:** Supabase linked project. Run migrations before preview deploys. Use non-sensitive fake data.
- **Production:** Supabase production project. Migrations applied after backup. No manual dashboard edits.

**Environment variable pattern:**
```
DATABASE_URL=postgresql://... (direct connection for migrations)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ... (server-side only, never in browser)
```

---

# 10. Things To Explicitly Defer

| Table/Feature | Reason to Defer |
|---|---|
| `foods` | Cronometer row snapshots (`food_name_snapshot`) are sufficient. Building a food database is months of work with no MVP value. |
| `daily_facts` materialized view | Requires stable data across multiple domains. Build after 30 days of real data when you know what queries you actually run. |
| `bloodwork_results` | No bloodwork import pipeline exists. Manual entry can wait. |
| `dexa_results` | Same — no DEXA pipeline yet. |
| `progress_photos` / `progress_photo_sessions` | Requires storage privacy, watermarking, EXIF stripping, redaction workflow. High complexity, low MVP value. |
| `brands`, `products`, `services` | No product reviews in MVP. |
| `product_usage_windows` | Depends on products table. |
| `affiliate_links`, `affiliate_link_clicks` | No active affiliate partnerships in MVP. Disclosure page is MDX. |
| `sponsor_relationships` | Phase 4+. |
| `product_reviews` | Depends on products + sponsor tables. |
| `entities`, `entity_relationships` | Full entity graph is Phase 2+. Use MDX frontmatter for now. |
| `pages`, `page_entities` | MVP pages are MDX files, not DB rows. |
| `internal_links` | Manual linking in MDX. Automated suggestions Phase 2+. |
| `schema_records` | JSON-LD is generated from MDX frontmatter + code, not a DB table. |
| `approval_queue` | Direct owner approval in admin UI. Formal queue when multiple approvers exist. |
| `api_keys`, `api_key_usage` | No external API consumers in MVP. |
| `professional_saved_views` | No professional accounts in MVP. |
| `experiment_metrics` junction table | `TEXT[]` arrays on experiments table are sufficient for MVP. |
| `experiment_verdict_history` | Track in audit_log for MVP. Dedicated table when verdicts change often. |

---

# 11. Top 20 Actionable Fixes Before Coding

## Critical

**1. Add `source_row_id` to `nutrition_logs`**
```
nutrition_logs.source_row_id UUID REFERENCES nutrition_import_rows(id) ON DELETE SET NULL
```
Without this, you cannot trace a normalized record back to its specific raw import row. This is a day-one auditability requirement.

**2. Define owner bootstrap sequence**
Document and implement: auth trigger creates `user_profiles` row → manual SQL promotion to `owner` → verify RLS helpers work for the promoted user. Test this before writing any admin UI.

**3. Add `row_number` and `row_hash` to `nutrition_import_rows`**
```
row_number INTEGER NOT NULL
row_hash TEXT NOT NULL
UNIQUE(batch_id, row_number)
```
Without these, you cannot provide line-level feedback in the import preview or detect duplicate rows across batches.

**4. Write RLS helper functions and policies in migration files**
Do not create these through the Supabase dashboard. They must be version-controlled and testable.

**5. Resolve `exercise_sets` visibility inheritance**
Decision: exercise_sets inherits visibility from workout_sessions via RLS policy subquery. No visibility column on exercise_sets. Document this decision.

## High

**6. Add `visibility` column to `confounder_logs`**
Already in the doc but confirm it's in the Drizzle schema file.

**7. Add `uploaded_by` to `nutrition_import_batches`**
```
uploaded_by UUID NOT NULL REFERENCES user_profiles(id)
```
Even with one user, track who did the upload for audit completeness.

**8. Remove `review_status` from `nutrition_import_batches`**
Redundant with `status` enum. One status field, one source of truth.

**9. Add `error_message` to `nutrition_import_rows`**
```
error_message TEXT
```
When a row fails validation, store why. Essential for preview UI.

**10. Define CHECK constraints for `measurements.metric_key`**
```sql
CHECK (metric_key IN ('bodyweight', 'waist', 'chest', ...))
```
Prevents free-text chaos without enum migration burden.

**11. Add `import_row_status_enum` as separate enum from batch status**
```sql
CREATE TYPE import_row_status_enum AS ENUM ('pending', 'validated', 'normalized', 'skipped', 'error');
```
Row status lifecycle is different from batch status lifecycle.

**12. Add `approved_at TIMESTAMPTZ` to `nutrition_import_batches`**
Separate from `updated_at`. You need to know WHEN the batch was approved, not just when it was last modified.

**13. Define all FK cascade behaviors explicitly**
- `nutrition_import_rows.batch_id → CASCADE` (delete batch = delete rows)
- `exercise_sets.workout_session_id → CASCADE` (delete session = delete sets)
- `exercise_sets.exercise_id → RESTRICT` (can't delete exercise with logged sets)
- `supplement_logs.supplement_id → RESTRICT` (can't delete supplement with logs)
- `dataset_exports.dataset_id → CASCADE` (delete dataset = delete exports)
- `nutrition_logs.source_batch_id → SET NULL` (delete batch doesn't delete logs)
- `nutrition_logs.source_row_id → SET NULL` (same)

## Medium

**14. Add `workout_status_enum` and `set_type_enum`**
These are referenced in docs but not formally defined as enums. Create them.

**15. Add RPE check constraint**
```sql
CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10))
```

**16. Add `generated_by` to `dataset_exports`**
```
generated_by UUID REFERENCES user_profiles(id)
```
Track who generated the export.

**17. Set `search_path` on all SECURITY DEFINER functions**
```sql
SET search_path = public;
```
Prevents path injection attacks.

**18. Create seed migration for exercises**
Don't make the creator type "Barbell Bench Press" on day one. Seed 30-50 common exercises.

## Low

**19. Add `file_size` and `row_count` to `dataset_exports`**
Useful for admin UI. Not critical for function.

**20. Add `default_dose` and `default_unit` to `supplements`**
Speeds up daily supplement logging. Not required but improves UX.

---

# 12. Final Recommended MVP Schema Contract

This is the definitive table contract a developer should use to create Drizzle schema files.

---

### Enums (define first, in `enums.ts`)

```
visibility_enum:    private | internal | professional | public
confidence_enum:    low | medium | high | experimental
user_role_enum:     owner | admin | editor | professional_viewer | public
import_status_enum: uploaded | previewed | approved | rejected | failed
import_row_status_enum: pending | validated | normalized | skipped | error
log_source_enum:    manual | cronometer_export | device_import | lab_report | estimated
workout_status_enum: planned | in_progress | completed | cancelled
set_type_enum:      warmup | working | backoff | drop | failure | amrap
adherence_status_enum: pending | taken | missed | skipped
experiment_status_enum: planned | baseline | active | followup | completed | abandoned
```

---

### user_profiles
```
id              UUID PK → auth.users(id) ON DELETE CASCADE
email           TEXT UNIQUE NOT NULL
role            user_role_enum NOT NULL DEFAULT 'public'
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: owner reads/updates own. No public read.
Bootstrap: auth trigger creates row; manual SQL promotes to owner.
```

### nutrition_import_batches
```
id              UUID PK DEFAULT gen_random_uuid()
source          log_source_enum NOT NULL DEFAULT 'cronometer_export'
file_name       TEXT NOT NULL
file_hash       TEXT UNIQUE NOT NULL
row_count       INTEGER
date_range_start DATE
date_range_end  DATE
status          import_status_enum NOT NULL DEFAULT 'uploaded'
approved_at     TIMESTAMPTZ
uploaded_by     UUID NOT NULL → user_profiles(id)
notes           TEXT
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: admin-only
Indexes: UNIQUE(file_hash), idx(status)
```

### nutrition_import_rows
```
id              UUID PK DEFAULT gen_random_uuid()
batch_id        UUID NOT NULL → nutrition_import_batches(id) ON DELETE CASCADE
row_number      INTEGER NOT NULL
row_hash        TEXT NOT NULL
raw_date        TEXT
raw_meal        TEXT
raw_food_name   TEXT
raw_amount      TEXT
raw_calories    TEXT
raw_protein     TEXT
raw_carbs       TEXT
raw_fat         TEXT
raw_fiber       TEXT
raw_sodium      TEXT
raw_sugar       TEXT
raw_payload     JSONB
status          import_row_status_enum NOT NULL DEFAULT 'pending'
error_message   TEXT
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: admin-only
Constraints: UNIQUE(batch_id, row_number)
Indexes: idx(batch_id), idx(row_hash)
```

### nutrition_logs
```
id                  UUID PK DEFAULT gen_random_uuid()
date                DATE NOT NULL
meal_name           TEXT
food_name_snapshot  TEXT NOT NULL
grams               NUMERIC(8,2)
calories            NUMERIC(8,2) NOT NULL
protein_g           NUMERIC(8,2)
carbs_g             NUMERIC(8,2)
fat_g               NUMERIC(8,2)
fiber_g             NUMERIC(8,2)
sugar_g             NUMERIC(8,2)
sodium_mg           NUMERIC(8,2)
source              log_source_enum NOT NULL DEFAULT 'cronometer_export'
source_batch_id     UUID → nutrition_import_batches(id) ON DELETE SET NULL
source_row_id       UUID → nutrition_import_rows(id) ON DELETE SET NULL
confidence_level    confidence_enum NOT NULL DEFAULT 'medium'
visibility          visibility_enum NOT NULL DEFAULT 'private'
notes               TEXT
created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: idx(date), idx(visibility) WHERE public, idx(source_batch_id)
Audit: visibility changes
```

### measurements
```
id                UUID PK DEFAULT gen_random_uuid()
measured_at       TIMESTAMPTZ NOT NULL
metric_key        TEXT NOT NULL CHECK (metric_key IN ('bodyweight', 'waist', 'chest', 'hips', 'neck', 'bicep_left', 'bicep_right', 'thigh_left', 'thigh_right', 'body_fat_estimate', 'blood_pressure_systolic', 'blood_pressure_diastolic', 'resting_heart_rate'))
value             NUMERIC(10,3) NOT NULL
unit              TEXT NOT NULL
source            log_source_enum NOT NULL DEFAULT 'manual'
device            TEXT
method            TEXT
confidence_level  confidence_enum NOT NULL DEFAULT 'high'
conditions        TEXT
visibility        visibility_enum NOT NULL DEFAULT 'private'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: idx(metric_key, measured_at), idx(visibility) WHERE public
Audit: visibility changes
```

### exercises
```
id                      UUID PK DEFAULT gen_random_uuid()
name                    TEXT UNIQUE NOT NULL
slug                    TEXT UNIQUE NOT NULL
primary_muscle_group    TEXT
secondary_muscle_groups TEXT[]
equipment               TEXT
movement_pattern        TEXT
notes                   TEXT
created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: public read, admin write
No visibility column — reference data
Seed: 30-50 common exercises in migration
```

### workout_sessions
```
id                UUID PK DEFAULT gen_random_uuid()
date              DATE NOT NULL
started_at        TIMESTAMPTZ
ended_at          TIMESTAMPTZ
session_type      TEXT
duration_minutes  INTEGER
status            workout_status_enum NOT NULL DEFAULT 'in_progress'
notes             TEXT
visibility        visibility_enum NOT NULL DEFAULT 'private'
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: idx(date), idx(visibility) WHERE public
Audit: visibility changes
```

### exercise_sets
```
id                  UUID PK DEFAULT gen_random_uuid()
workout_session_id  UUID NOT NULL → workout_sessions(id) ON DELETE CASCADE
exercise_id         UUID NOT NULL → exercises(id) ON DELETE RESTRICT
set_number          INTEGER NOT NULL
set_type            set_type_enum NOT NULL DEFAULT 'working'
actual_reps         INTEGER
actual_load         NUMERIC(8,2)
load_unit           TEXT NOT NULL DEFAULT 'lb'
rpe                 NUMERIC(3,1) CHECK (rpe IS NULL OR (rpe >= 1 AND rpe <= 10))
rest_seconds        INTEGER
notes               TEXT
created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: inherits from workout_sessions.visibility via subquery
No visibility column — inherits from parent
Indexes: idx(workout_session_id), idx(exercise_id)
```

### supplements
```
id                UUID PK DEFAULT gen_random_uuid()
name              TEXT UNIQUE NOT NULL
slug              TEXT UNIQUE NOT NULL
category          TEXT
active_ingredient TEXT
default_dose      TEXT
default_unit      TEXT
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: public read, admin write
No visibility column — reference data
```

### supplement_logs
```
id                UUID PK DEFAULT gen_random_uuid()
date              DATE NOT NULL
supplement_id     UUID NOT NULL → supplements(id) ON DELETE RESTRICT
dose              TEXT
unit              TEXT
time_taken        TEXT
adherence_status  adherence_status_enum NOT NULL DEFAULT 'pending'
source            log_source_enum NOT NULL DEFAULT 'manual'
confidence_level  confidence_enum NOT NULL DEFAULT 'high'
visibility        visibility_enum NOT NULL DEFAULT 'private'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: idx(date), idx(supplement_id, date)
Dedup: UNIQUE(date, supplement_id, COALESCE(time_taken, ''))
```

### experiments
```
id                UUID PK DEFAULT gen_random_uuid()
title             TEXT NOT NULL
slug              TEXT UNIQUE NOT NULL
experiment_type   TEXT NOT NULL DEFAULT 'baseline'
status            experiment_status_enum NOT NULL DEFAULT 'planned'
question          TEXT
hypothesis        TEXT
protocol_summary  TEXT
baseline_start    DATE
baseline_end      DATE
intervention_start DATE
intervention_end  DATE
followup_start    DATE
followup_end      DATE
primary_metrics   TEXT[]
secondary_metrics TEXT[]
confidence_level  confidence_enum DEFAULT 'medium'
verdict           TEXT
visibility        visibility_enum NOT NULL DEFAULT 'private'
notes             TEXT
created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: UNIQUE(slug), idx(status), idx(visibility) WHERE public
Audit: status changes, visibility changes, verdict changes
```

### confounder_logs (optional MVP)
```
id              UUID PK DEFAULT gen_random_uuid()
date            DATE NOT NULL
confounder_type TEXT NOT NULL CHECK (confounder_type IN ('poor_sleep', 'high_stress', 'illness', 'injury', 'travel', 'missed_workout', 'missed_supplement', 'alcohol', 'new_program', 'calorie_change', 'medication_change'))
severity        TEXT CHECK (severity IS NULL OR severity IN ('minor', 'moderate', 'major'))
impact_areas    TEXT[]
notes           TEXT
visibility      visibility_enum NOT NULL DEFAULT 'private'
created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: idx(date)
```

### datasets
```
id                    UUID PK DEFAULT gen_random_uuid()
name                  TEXT NOT NULL
slug                  TEXT UNIQUE NOT NULL
description           TEXT
date_range_start      DATE NOT NULL
date_range_end        DATE NOT NULL
source_summary        TEXT
methodology_summary   TEXT
limitations           TEXT
visibility            visibility_enum NOT NULL DEFAULT 'private'
created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()

RLS: visibility-based
Indexes: UNIQUE(slug), idx(visibility) WHERE public
```

### dataset_exports
```
id           UUID PK DEFAULT gen_random_uuid()
dataset_id   UUID NOT NULL → datasets(id) ON DELETE CASCADE
format       TEXT NOT NULL DEFAULT 'csv' CHECK (format IN ('csv', 'json'))
file_url     TEXT NOT NULL
file_size    INTEGER
row_count    INTEGER
generated_by UUID → user_profiles(id)
generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
visibility   visibility_enum NOT NULL DEFAULT 'private'
notes        TEXT

RLS: visibility-based
Indexes: idx(dataset_id)
Audit: generation logged
```

### audit_log
```
id          UUID PK DEFAULT gen_random_uuid()
table_name  TEXT NOT NULL
record_id   UUID NOT NULL
action      TEXT NOT NULL
old_values  JSONB
new_values  JSONB
changed_by  UUID → user_profiles(id)
changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
ip_address  INET
user_agent  TEXT

RLS: admin-only. Never delete.
Indexes: idx(table_name, record_id), idx(changed_at)
Implementation: app-level for MVP
```

---

**Total: 17 tables, 10 enums, ~35 indexes, 17 RLS policy groups, 3 helper functions.**

This is buildable in a focused database-foundation sprint. Write the Drizzle schema files from this contract, generate the migration, test RLS with anonymous and owner sessions, seed exercises and nutrient definitions, and begin building the admin UI.

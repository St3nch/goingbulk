# GoingBulk Training Program Schema Contract

## Purpose

This document translates the training program planning model into an implementation-ready schema contract for planned training, scheduling, substitutions, rest timing, and public-safe planned-vs-actual analysis.

It builds on:

```text
docs/19-mobile-logging-ux.md
docs/36-mvp-schema-implementation-contract.md
docs/38-training-program-template-and-scheduling-model.md
docs/39-transparency-data-display-and-tracking-model.md
```

This is a schema planning contract. Do not generate migrations from this document until the local Supabase and `DATABASE_URL` setup is intentionally handled.

## Core Decision

GoingBulk must keep planned training separate from actual training.

```text
planned training = what the program/source/adapted plan says to do
actual training = what the user actually did
```

The schema must preserve enough private planned detail to execute the workout correctly, while public outputs must summarize adherence and execution without reproducing paid/proprietary prescriptions.

## Non-Goals

Do not use this schema pass to build:

```text
native mobile apps
full exercise wiki scale-out
bulk imported exercise encyclopedias
nutrition planning/cost tables
public program-calendar recreation
paid workout PDF storage in Git
LLM direct database access
```

Training program data is MVP-adjacent, but it should be implemented as a focused schema expansion after the current MVP table foundation.

## Privacy and Copyright Rule

Private execution can be detailed.

Public display must be respectful and non-substitutive.

Public pages may show:

```text
program source/name
official source link
phase/week/day labels
scheduled/completed/missed counts
completion percentages
actual workout summaries
modifications/substitutions
results/context/costs
limitations/confidence
```

Public pages must not show:

```text
full paid workout tables
exact copied exercise-by-exercise prescription
exact source sets/reps/rest copied as a public replacement
paid screenshots/PDFs
full diet-plan text
complete downloadable recreated calendars
private source file paths
```

## Relationship to Current MVP Tables

Current actual-training MVP tables already exist conceptually:

```text
workout_sessions
exercise_sets
exercises
```

This contract adds planned-program and scheduling tables that link to those actual logs later.

Current tables should eventually receive these additions:

```text
workout_sessions.scheduled_workout_id nullable
workout_sessions.user_training_program_id nullable
exercise_sets.planned_exercise_id nullable
exercise_sets.planned_set_id nullable
exercise_sets.substitution_reason nullable
exercise_sets.rest_started_at nullable
exercise_sets.rest_ended_at nullable
exercise_sets.actual_rest_seconds nullable
exercise_sets.manual_rest_adjustment_reason nullable
```

Do not add those columns until the planned tables exist and the migration plan is ready.

## Recommended Table Set

Required first training-program schema pass:

```text
training_programs
training_program_phases
training_program_weeks
training_program_workouts
planned_training_blocks
planned_exercises
planned_sets
user_training_programs
scheduled_workouts
exercise_aliases
workout_modifications
program_attachments
program_source_files
```

Optional later:

```text
training_program_tags
training_program_progression_rules
exercise_substitution_preferences
user_equipment_availability
training_readiness_checks
weekly_training_scorecards
public_training_summary_records
```

## Enums and Controlled Vocabularies

Use Postgres enums only for small stable concepts used across multiple tables.

Recommended new enums:

```text
training_program_status_enum: draft | active | archived
user_training_program_status_enum: planned | active | paused | completed | abandoned
schedule_policy_enum: fixed_weekdays | rolling_next_available | manual
scheduled_workout_status_enum: scheduled | completed | missed | skipped | rescheduled | cancelled
training_block_type_enum: straight_sets | superset | triset | circuit | giant_set | warmup | finisher | cardio | mobility | conditioning | timed_hold | special_method
rep_target_type_enum: exact | range | to_failure | amrap | timed | as_prescribed | text
load_target_type_enum: none | fixed | percent_1rm | rpe | rir | bodyweight | as_prescribed | text
program_attachment_type_enum: overview | workout_pdf | training_system | calendar | nutrition | diet | supplement | other
program_display_mode_enum: private_execution_view | public_summary_view | public_analysis_view
workout_modification_type_enum: skipped_exercise | substituted_exercise | changed_exercise_order | changed_load | changed_rep_target | added_extra_set | removed_set | added_extra_exercise | ended_workout_early | changed_rest_time | changed_tempo | changed_training_day | rescheduled_workout
substitution_reason_enum: past_injury | joint_pain | equipment_unavailable | gym_crowding | movement_discomfort | skill_limit | fatigue | program_adjustment | preference | other
```

Use TEXT plus app-level validation or CHECK constraints for broader taxonomies:

```text
program_type
primary_goal
experience_level
primary_focus
source_name
injury/body-region labels
public-safe summary labels
```

## Table Contracts

### training_programs

Canonical program metadata. This is the source-aware template, not a user's scheduled run.

```text
id UUID PK DEFAULT gen_random_uuid()
source_name TEXT NOT NULL
source_url TEXT
program_name TEXT NOT NULL
slug TEXT UNIQUE NOT NULL
description TEXT
program_type TEXT
primary_goal TEXT
experience_level TEXT
duration_weeks INTEGER
default_days_per_week INTEGER
status training_program_status_enum NOT NULL DEFAULT 'draft'
copyright_publication_policy TEXT
visibility visibility_enum NOT NULL DEFAULT 'private'
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(slug)
CHECK(duration_weeks IS NULL OR duration_weeks > 0)
CHECK(default_days_per_week IS NULL OR default_days_per_week BETWEEN 1 AND 14)
idx_training_programs_slug
idx_training_programs_visibility
idx_training_programs_status
```

RLS:

```text
visibility-based select
owner/admin write
```

Default visibility should be private while templates are source-informed.

### training_program_phases

Program phase/block metadata.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_id UUID NOT NULL REFERENCES training_programs(id) ON DELETE CASCADE
phase_number INTEGER NOT NULL
phase_name TEXT
week_start INTEGER
week_end INTEGER
description TEXT
focus TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(training_program_id, phase_number)
CHECK(phase_number > 0)
CHECK(week_start IS NULL OR week_start > 0)
CHECK(week_end IS NULL OR week_end >= week_start)
idx_training_program_phases_program
```

RLS inherits through parent program visibility for select; owner/admin write.

### training_program_weeks

Explicit week records for scheduling and adherence.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_id UUID NOT NULL REFERENCES training_programs(id) ON DELETE CASCADE
training_program_phase_id UUID REFERENCES training_program_phases(id) ON DELETE SET NULL
week_number INTEGER NOT NULL
week_label TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(training_program_id, week_number)
CHECK(week_number > 0)
idx_training_program_weeks_program
idx_training_program_weeks_phase
```

### training_program_workouts

A planned workout template inside a program.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_id UUID NOT NULL REFERENCES training_programs(id) ON DELETE CASCADE
training_program_phase_id UUID REFERENCES training_program_phases(id) ON DELETE SET NULL
training_program_week_id UUID REFERENCES training_program_weeks(id) ON DELETE SET NULL
workout_number INTEGER
workout_day_label TEXT
workout_name TEXT
split_label TEXT
primary_focus TEXT
estimated_duration_minutes INTEGER
default_sequence_order INTEGER
source_page_reference TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
CHECK(workout_number IS NULL OR workout_number > 0)
CHECK(default_sequence_order IS NULL OR default_sequence_order > 0)
CHECK(estimated_duration_minutes IS NULL OR estimated_duration_minutes > 0)
idx_training_program_workouts_program
idx_training_program_workouts_week
idx_training_program_workouts_phase
```

Do not require every workout to belong to a week. Some programs may define repeating workouts or phase-level workouts.

### planned_training_blocks

Container for groups of work inside a planned workout.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_workout_id UUID NOT NULL REFERENCES training_program_workouts(id) ON DELETE CASCADE
block_order INTEGER NOT NULL
block_type training_block_type_enum NOT NULL DEFAULT 'straight_sets'
block_label TEXT
rounds INTEGER
rest_between_rounds_seconds INTEGER
instructions TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(training_program_workout_id, block_order)
CHECK(block_order > 0)
CHECK(rounds IS NULL OR rounds > 0)
CHECK(rest_between_rounds_seconds IS NULL OR rest_between_rounds_seconds >= 0)
idx_planned_training_blocks_workout
```

This table prevents the schema from breaking when programs include supersets, circuits, finishers, timed holds, cardio, or special methods.

### planned_exercises

Prescribed exercises inside a planned block.

```text
id UUID PK DEFAULT gen_random_uuid()
planned_training_block_id UUID NOT NULL REFERENCES planned_training_blocks(id) ON DELETE CASCADE
exercise_id UUID REFERENCES exercises(id) ON DELETE SET NULL
exercise_name_snapshot TEXT NOT NULL
exercise_order INTEGER NOT NULL
superset_group_label TEXT
movement_notes TEXT
substitution_allowed BOOLEAN NOT NULL DEFAULT true
instructions TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(planned_training_block_id, exercise_order)
CHECK(exercise_order > 0)
idx_planned_exercises_block
idx_planned_exercises_exercise
```

`exercise_id` is nullable because a private source program may use an exercise name that has not been mapped into the GoingBulk exercise library yet.

Always preserve `exercise_name_snapshot` privately. Public pages should not expose the full source prescription.

### planned_sets

Exact set-level prescription where available. This table is not deferred.

```text
id UUID PK DEFAULT gen_random_uuid()
planned_exercise_id UUID NOT NULL REFERENCES planned_exercises(id) ON DELETE CASCADE
set_number INTEGER NOT NULL
set_type set_type_enum NOT NULL DEFAULT 'working'
sets_count_snapshot INTEGER
rep_target_type rep_target_type_enum NOT NULL DEFAULT 'as_prescribed'
rep_min INTEGER
rep_max INTEGER
rep_exact INTEGER
rep_text_snapshot TEXT
load_target_type load_target_type_enum NOT NULL DEFAULT 'none'
load_value NUMERIC(8,2)
load_unit TEXT
load_percent_1rm NUMERIC(5,2)
rpe_target NUMERIC(3,1)
rir_target NUMERIC(3,1)
rest_seconds INTEGER
rest_text_snapshot TEXT
tempo TEXT
is_to_failure BOOLEAN NOT NULL DEFAULT false
is_amrap BOOLEAN NOT NULL DEFAULT false
duration_seconds INTEGER
instructions TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(planned_exercise_id, set_number)
CHECK(set_number > 0)
CHECK(rep_min IS NULL OR rep_min >= 0)
CHECK(rep_max IS NULL OR rep_max >= rep_min)
CHECK(rep_exact IS NULL OR rep_exact >= 0)
CHECK(rest_seconds IS NULL OR rest_seconds >= 0)
CHECK(duration_seconds IS NULL OR duration_seconds >= 0)
CHECK(rpe_target IS NULL OR (rpe_target >= 1 AND rpe_target <= 10))
CHECK(rir_target IS NULL OR rir_target >= 0)
CHECK(load_percent_1rm IS NULL OR (load_percent_1rm > 0 AND load_percent_1rm <= 150))
idx_planned_sets_exercise
```

Private use:

```text
show exact planned sets/reps/rest/tempo/instructions to owner/admin
```

Public use:

```text
aggregate completion/adherence only; do not publicly recreate the paid set table
```

### user_training_programs

A user's personal scheduled run of a program.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_id UUID NOT NULL REFERENCES training_programs(id) ON DELETE RESTRICT
user_profile_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE
status user_training_program_status_enum NOT NULL DEFAULT 'planned'
start_date DATE
end_date DATE
preferred_weekdays INTEGER[]
default_start_time TIME
timezone TEXT
current_phase_number INTEGER
current_week_number INTEGER
current_workout_number INTEGER
schedule_policy schedule_policy_enum NOT NULL DEFAULT 'rolling_next_available'
phase_label TEXT
visibility visibility_enum NOT NULL DEFAULT 'private'
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
CHECK(end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
CHECK(current_phase_number IS NULL OR current_phase_number > 0)
CHECK(current_week_number IS NULL OR current_week_number > 0)
CHECK(current_workout_number IS NULL OR current_workout_number > 0)
idx_user_training_programs_user
idx_user_training_programs_program
idx_user_training_programs_status
idx_user_training_programs_visibility
```

`preferred_weekdays` should use values 0-6 where 0 = Sunday, or be app-validated consistently. If using a DB CHECK on arrays is annoying in Drizzle, enforce in app validation first and add DB check later.

Re-entry mode should use:

```text
status = active
schedule_policy = rolling_next_available
phase_label = pre_gym_baseline or re_entry_training as appropriate
```

### scheduled_workouts

Concrete calendar workout instances generated from a user program run.

```text
id UUID PK DEFAULT gen_random_uuid()
user_training_program_id UUID NOT NULL REFERENCES user_training_programs(id) ON DELETE CASCADE
training_program_workout_id UUID REFERENCES training_program_workouts(id) ON DELETE SET NULL
scheduled_date DATE NOT NULL
scheduled_start_time TIME
scheduled_end_time TIME
status scheduled_workout_status_enum NOT NULL DEFAULT 'scheduled'
rescheduled_from_id UUID REFERENCES scheduled_workouts(id) ON DELETE SET NULL
completed_workout_session_id UUID REFERENCES workout_sessions(id) ON DELETE SET NULL
skip_reason TEXT
reschedule_reason TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
CHECK(scheduled_end_time IS NULL OR scheduled_start_time IS NULL OR scheduled_end_time >= scheduled_start_time)
idx_scheduled_workouts_user_program
idx_scheduled_workouts_date
idx_scheduled_workouts_status
idx_scheduled_workouts_completed_session
```

This table answers what should be done today and what was missed/rescheduled.

### exercise_aliases

Maps variant source names to canonical GoingBulk exercises.

```text
id UUID PK DEFAULT gen_random_uuid()
exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE
alias_name TEXT NOT NULL
source TEXT
confidence_level confidence_enum NOT NULL DEFAULT 'medium'
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
UNIQUE(exercise_id, alias_name)
idx_exercise_aliases_alias_name
idx_exercise_aliases_exercise
```

Alias matching should preserve the original source wording in `planned_exercises.exercise_name_snapshot` even after a canonical `exercise_id` is selected.

### workout_modifications

Tracks planned-vs-actual changes without pretending they did not happen.

```text
id UUID PK DEFAULT gen_random_uuid()
scheduled_workout_id UUID REFERENCES scheduled_workouts(id) ON DELETE SET NULL
workout_session_id UUID REFERENCES workout_sessions(id) ON DELETE CASCADE
planned_exercise_id UUID REFERENCES planned_exercises(id) ON DELETE SET NULL
planned_set_id UUID REFERENCES planned_sets(id) ON DELETE SET NULL
exercise_set_id UUID REFERENCES exercise_sets(id) ON DELETE SET NULL
modification_type workout_modification_type_enum NOT NULL
substitution_reason substitution_reason_enum
public_summary TEXT
private_notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
idx_workout_modifications_session
idx_workout_modifications_scheduled
idx_workout_modifications_type
idx_workout_modifications_planned_set
```

Use this for skipped exercises, substitutions, changed rest, added sets, changed training day, and ended-early sessions.

Public summaries should describe the change without exposing paid source detail.

### program_attachments

Tracks source-guidance attachments without committing private files to Git.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_id UUID NOT NULL REFERENCES training_programs(id) ON DELETE CASCADE
attachment_type program_attachment_type_enum NOT NULL
title TEXT NOT NULL
source_file_path_private TEXT
summary_private TEXT
public_summary TEXT
visibility visibility_enum NOT NULL DEFAULT 'private'
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
idx_program_attachments_program
idx_program_attachments_type
idx_program_attachments_visibility
```

Do not expose `source_file_path_private` through public APIs.

### program_source_files

Private source traceability for program templates.

```text
id UUID PK DEFAULT gen_random_uuid()
training_program_id UUID NOT NULL REFERENCES training_programs(id) ON DELETE CASCADE
local_file_path TEXT
file_name TEXT NOT NULL
file_hash TEXT
page_count INTEGER
source_type TEXT
notes TEXT
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Constraints and indexes:

```text
CHECK(page_count IS NULL OR page_count > 0)
idx_program_source_files_program
idx_program_source_files_hash
```

This is private operational metadata. It should be owner/admin only, not visibility-based public data.

## Planned-to-Actual Link Additions

After planned tables exist, add nullable links to actual logging tables.

### workout_sessions additions

```text
scheduled_workout_id UUID REFERENCES scheduled_workouts(id) ON DELETE SET NULL
user_training_program_id UUID REFERENCES user_training_programs(id) ON DELETE SET NULL
session_difficulty_1_10 INTEGER
pump_1_10 INTEGER
fatigue_1_10 INTEGER
joint_stress_1_10 INTEGER
enjoyment_1_10 INTEGER
would_repeat BOOLEAN
```

Checks:

```text
all *_1_10 fields CHECK value BETWEEN 1 AND 10 when not null
```

### exercise_sets additions

```text
planned_exercise_id UUID REFERENCES planned_exercises(id) ON DELETE SET NULL
planned_set_id UUID REFERENCES planned_sets(id) ON DELETE SET NULL
substitution_reason substitution_reason_enum
planned_rest_seconds INTEGER
rest_started_at TIMESTAMPTZ
rest_ended_at TIMESTAMPTZ
actual_rest_seconds INTEGER
rest_was_shorter_than_planned BOOLEAN
rest_was_longer_than_planned BOOLEAN
manual_rest_adjustment_reason TEXT
```

Checks:

```text
CHECK(planned_rest_seconds IS NULL OR planned_rest_seconds >= 0)
CHECK(actual_rest_seconds IS NULL OR actual_rest_seconds >= 0)
CHECK(rest_ended_at IS NULL OR rest_started_at IS NULL OR rest_ended_at >= rest_started_at)
```

The workout logger must support the big obvious rest button after every completed set.

## RLS Model

Use three policy patterns.

### Visibility-based planned/user records

Use visibility-based RLS for:

```text
training_programs
user_training_programs
program_attachments
```

### Parent-inherited planned child records

These records should inherit visibility through the parent training program:

```text
training_program_phases
training_program_weeks
training_program_workouts
planned_training_blocks
planned_exercises
planned_sets
```

Public select should only expose rows if the parent program is public, and even then API/display code must avoid returning source-substitutive detail.

Owner/admin write only.

### Owner/admin-only operational records

Use admin-only RLS for:

```text
program_source_files
```

### Actual-linked modification records

`workout_modifications` should inherit visibility through the related `workout_sessions` or `scheduled_workouts` owner context. For MVP implementation, make it owner/admin read/write only first, then add public-safe summary generation later.

## API and Agent Access Rules

LLMs and agents must not access these tables directly.

Correct pattern:

```text
LLM/agent -> governed GoingBulk API/tool -> app logic -> Supabase/Postgres
```

Public APIs should return computed summaries, not raw planned proprietary prescriptions.

Recommended public summary endpoints later:

```text
/api/v1/public/training-programs/:slug/summary
/api/v1/public/training-runs/:id/weekly-scorecards
/api/v1/public/training-runs/:id/adherence
```

Admin APIs may return full private execution detail to the authenticated owner.

## Display Modes

The schema must support these display modes:

```text
private_execution_view
public_summary_view
public_analysis_view
```

Private execution view can show full planned source-informed detail.

Public summary view should show adherence and actual behavior at aggregate level.

Public analysis view may show deeper trends but must avoid recreating paid source prescriptions.

## Scheduling Rules

The scheduler should support:

```text
start date
preferred weekdays
default workout time
phase/week/day start point
fixed weekday scheduling
rolling next available scheduling
manual scheduling
rescheduling with reason
missed/skipped/cancelled status
completed workout link
```

Re-entry training should default to:

```text
3 lifting days per week
full-body A/B rotation
at least 1 rest day between lifting sessions
rolling_next_available
RPE 5-7
stop 3-4 reps before failure
no maxes
no forced reps
no drop sets
no rest-pause
```

## Public-Safe Summary Calculations

The schema should support calculating:

```text
scheduled workouts
completed workouts
missed workouts
rescheduled workouts
program adherence percentage
exercise completion percentage
set completion percentage
rep target hit rate
planned rest vs actual rest adherence
substitution count
substitution reasons
extra work count
skipped exercise count
phase/week completion
```

These should initially be calculated from source tables or views. Do not create permanent summary tables until repeated report patterns prove they are needed.

## Drizzle Implementation Notes

Recommended file organization:

```text
src/db/schema/training-programs.ts
src/db/schema/training-plans.ts
src/db/schema/training-schedule.ts
src/db/schema/exercise-aliases.ts
src/db/schema/workout-modifications.ts
```

Update:

```text
src/db/schema/enums.ts
src/db/schema/index.ts
```

Do not generate SQL migrations until local Supabase and `DATABASE_URL` are intentionally ready.

When implemented, validate with:

```text
pnpm format:check
pnpm lint
pnpm typecheck
pnpm build
```

If migrations are generated later, review the SQL before applying it.

## Implementation Sequence

Recommended future PR sequence:

```text
1. Add training-program enums and planned-program tables.
2. Add scheduling/user program tables.
3. Add exercise aliases and modification tracking.
4. Add nullable planned-to-actual links on workout_sessions and exercise_sets.
5. Add RLS SQL policies/helper behavior in migrations.
6. Add admin/private program-entry UI.
7. Add public-safe summary views/endpoints.
```

Keep these as small branches/PRs. No giant goblin merge.

## Open Questions Before Coding

Before implementation, inspect representative days from each private program family and answer:

```text
Do any programs require nested supersets/circuits beyond one block level?
Do any prescribe cardio intervals or timed holds?
Do any use percentage-based loading?
Do any use progression formulas that need separate progression-rule tables?
Do any require optional/alternate exercises?
Should re-entry workouts be first-class templates or generated from a simpler starter template?
Should public summaries be generated on request or stored as records?
How should exercise aliases be approved when confidence is low?
```

## Core Principle

```text
GoingBulk should know exactly what the user planned to do, exactly what the user actually did, and exactly what changed, while keeping paid source prescriptions private and public summaries fair.
```

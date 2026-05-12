# GoingBulk Training Program Template and Scheduling Model

## Purpose

This document defines what GoingBulk needs to track for structured workout programs before adding database tables for planned training.

The goal is not to transcribe every workout program immediately.

The goal is to make sure GoingBulk can accurately represent, schedule, follow, and compare structured training programs against actual completed workouts.

## Context

GoingBulk currently has MVP schema support for actual training logs:

```text
workout_sessions
exercise_sets
exercises
```

That is enough to track what actually happened in the gym.

It is not enough to track what the program prescribed.

The user is collecting Jim Stoppani workout program PDFs locally under:

```text
C:\dev\goingbulk\local-data\workout-programs
```

Current local program families include:

```text
12week-beginner-to-advance
shortcut-to-shred
shortcut-to-size
six-weeks-to-sick-arms
xtreme-shredded-8
```

Xtreme Shredded 8 now includes the overview, weeks 1-8, and diet phase PDFs, so it can be used as another structural reference for program templates, scheduling, and program attachments.

## Core Decision

GoingBulk must track planned training separately from actual training.

```text
Planned training = what the program says to do.
Actual training = what the user actually did.
```

The system must support comparing the two.

## Core Rule

```text
GoingBulk must know what workout was scheduled, what workout was prescribed, what was completed, what was missed, and what was modified.
```

Without that, training data is incomplete.

## Why This Matters

If GoingBulk only logs actual workouts, it cannot accurately answer:

- Was this workout completed as prescribed?
- Was a scheduled workout missed?
- Were exercises skipped?
- Were extra exercises added?
- Were prescribed rep ranges hit?
- Were rest times followed?
- Was the user compliant with the program?
- Did results come from following the program or modifying it?
- Which program phase/week/day was being performed?
- Which workout should be shown today?

For a public data-driven fitness brand, planned-vs-actual training is part of data credibility.

## Evidence From Current Program Collection

The collected program files show several important structure types.

### 12-Week Beginner to Advanced

The uploaded/rendered files show a multi-phase program with overview pages and phase workout PDFs.

The Phase 1 workout PDF contains structured workout tables with phase, week/day context, exercise names, sets, reps, and muscle groups. It shows that GoingBulk needs to store planned exercises, prescribed set counts, rep targets, and workout-day structure. The rendered Phase 1 workout document is image-based but visibly contains program tables for the 12-week Beginner to Advanced program.

Observed structural needs:

```text
program overview
phases
weeks
days/workouts
exercise order
sets
rep targets
muscle groups
phase-specific rules
```

### Shortcut to Size

Local files include:

```text
shortcut-to-size-overview.pdf
shortcut-to-size-weeks-1-4.pdf
shortcut-to-size-nutrition.pdf
sfs-stoppani-full-split-training-system.pdf
```

This suggests GoingBulk needs to support:

```text
program overview
week blocks
training split/system notes
nutrition attachment
possibly separate downloadable workout schedule files
```

### Shortcut to Shred

Local files include:

```text
shortcut-to-shread-program-overview.pdf
shortcut-to-shread-weeks-1-6.pdf
shortcut-to-shread-diet.pdf
```

This suggests GoingBulk needs to support:

```text
program overview
multi-week schedule
fat-loss/shredding focus
workout plan plus diet/nutrition attachment
```

The spelling in filenames currently says `shread`; that may just reflect saved file names and should not define canonical program naming.

### Six Weeks to Sick Arms

Local files include:

```text
six-weeks-to-sick-arms-overview.pdf
six-weeks-to-sick-arms-overview-workouts.pdf
six-weeks-to-sick-arms-nutrition.pdf
```

This suggests GoingBulk needs to support specialization programs, not only full-body/bodybuilding progression programs.

Structural needs:

```text
shorter program duration
specialization focus
possibly add-on or arm-priority workouts
program nutrition attachment
```

### Xtreme Shredded 8

Local files include:

```text
xtreme-shredded-8-program-overview.pdf
xtreme-shredded-8-program-weeks-1-8.pdf
xtreme-shredded-8-diet-phases-1-2.pdf
xtreme-shredded-8-diet-phases-3-4.pdf
xtreme-shredded-8-diet-phases-5-6-7.pdf
```

This program now provides both training and diet phase material. It should be used as another structural reference for program templates, phase/week scheduling, and program attachments.

Structural needs:

```text
8-week program structure
training overview
week-based workout plan
diet phases
multi-file program attachments
phase-specific nutrition/diet guidance
```

The diet phase files reinforce that program attachments should be tracked separately from planned workout prescriptions.

## Program Content Privacy Rule

Many workout programs may be copyrighted, paid, or proprietary.

GoingBulk may privately store enough detail to follow and log the program accurately.

GoingBulk should not publicly reproduce full program contents.

## Transparency Principle

GoingBulk should be as transparent as possible with the user's actual execution, adherence, modifications, results, costs, and context.

Transparency means showing what the user actually did, not pretending the user followed a plan perfectly.

GoingBulk should publicly support statements like:

```text
I followed this program source.
I scheduled these workouts.
I completed this percentage.
I skipped or modified these categories of work.
I tailored the nutrition guidance instead of following it exactly.
I ate these meals/macros.
I took or missed these supplements.
I drank this much water.
I spent this much on groceries/supplements.
These are my results and limitations.
```

Transparency does not mean republishing proprietary source material. The app should separate:

```text
private source prescription = full program/diet details needed for personal execution
public transparency layer = adherence, actual logs, summaries, modifications, costs, and results
```

This lets GoingBulk be honest with viewers without becoming a public mirror of paid/copyrighted plans.

Public pages should show:

```text
program source
program name
phase/week/day identifiers
adherence summaries
planned-vs-actual performance summaries
results
personal notes
```

Public pages should avoid exposing:

```text
complete workout tables
full exercise prescriptions
full copyrighted program text
paid plan details
```

## Required Conceptual Layers

GoingBulk needs three separate layers.

### 1. Program Template Layer

The canonical structured workout program.

Examples:

```text
12-Week Beginner to Advanced
Shortcut to Size
Shortcut to Shred
Six Weeks to Sick Arms
```

This layer answers:

```text
What is the program?
Who is the source?
How long is it?
How many phases/weeks/workouts does it contain?
What does each workout prescribe?
```

### 2. Scheduled Program Instance Layer

The user's personal run of that program.

Example:

```text
Program: 12-Week Beginner to Advanced
Start date: 2026-05-11
Preferred days: Monday, Tuesday, Thursday, Friday
Default start time: 07:00
Status: active
```

This layer answers:

```text
When am I doing this program?
Which workout is scheduled today?
Which workouts were missed or moved?
What phase/week/day am I currently on?
```

### 3. Actual Workout Layer

The workouts actually completed by the user.

This already exists conceptually in:

```text
workout_sessions
exercise_sets
```

This layer answers:

```text
What did I actually do?
What load/reps/rest did I complete?
What was skipped, modified, or substituted?
```

## Recommended Future Schema Tables

Do not add these to the current PR #5.

Add them in a future branch after the current MVP schema PR is resolved.

Recommended future branch:

```text
feature/training-program-schema
```

### training_programs

Canonical program metadata.

Fields to consider:

```text
id
source_name
source_url
program_name
slug
description
program_type
primary_goal
experience_level
duration_weeks
default_days_per_week
copyright_publication_policy
visibility
notes
created_at
updated_at
```

Example program types:

```text
hypertrophy
fat_loss
strength
specialization
beginner_progression
conditioning
```

### training_program_phases

Program phases/blocks.

Fields:

```text
id
training_program_id
phase_number
phase_name
week_start
week_end
description
focus
notes
created_at
updated_at
```

Why needed:

The 12-week Beginner to Advanced program is phase-based, and phase PDFs are separate.

### training_program_weeks

Explicit week records where needed.

Fields:

```text
id
training_program_id
training_program_phase_id
week_number
week_label
notes
created_at
updated_at
```

This may be optional if phases/workouts encode week ranges, but it is likely useful for scheduling and adherence.

### training_program_workouts

A planned workout template inside a program.

Fields:

```text
id
training_program_id
training_program_phase_id
training_program_week_id
workout_number
workout_day_label
workout_name
split_label
primary_focus
estimated_duration_minutes
default_sequence_order
notes
created_at
updated_at
```

Examples:

```text
Workout 1
Day 1
Chest and Triceps
Back and Biceps
Legs
Shoulders and Traps
Arm Specialization Day
```

### planned_training_blocks

A flexible container for exercise groups or special methods inside a workout.

Fields:

```text
id
training_program_workout_id
block_order
block_type
block_label
rounds
rest_between_rounds_seconds
instructions
notes
created_at
updated_at
```

Recommended block types:

```text
straight_sets
superset
triset
circuit
giant_set
warmup
finisher
cardio
mobility
conditioning
timed_hold
special_method
```

Why this table matters:

Different programs may include supersets, circuits, timed work, cardio, finishers, or special methods. A simple `planned_exercises` table alone will eventually break.

### Exercise Library Growth and Substitution Strategy

GoingBulk should grow the exercise database only from real usage, not by bulk-importing a massive generic exercise list.

When a workout program calls for an exercise that does not exist in the database yet, the user should be able to enter it once. After that, the exercise becomes available for future selection, planned workouts, actual logs, substitutions, and public/private exercise wiki pages.

This supports a practical workflow:

```text
program calls for new exercise
user adds exercise to database
exercise becomes selectable later
exercise can receive aliases
exercise can receive injury/modification notes
exercise can become a wiki/entity page
exercise can be used as a substitute for similar movements
```

Do not create thousands of unused exercise pages. GoingBulk should build the exercise wiki organically as exercises are actually used.

Future exercise-library fields should support:

```text
canonical exercise name
slug
primary muscle group
secondary muscle groups
movement pattern
equipment
body region
unilateral/bilateral flag
joint stress notes
injury caution notes
setup/cue notes
video/image reference later
public wiki status
visibility
created_from_source
created_at
updated_at
```

Exercise wiki pages should be generated only when the exercise has been added/used. Public pages can explain what the exercise is, what muscles it trains, what equipment it uses, common substitutions, personal notes, and GoingBulk history with that exercise.

### Exercise Aliases and Matching

Program PDFs and real gym logging will use inconsistent exercise names.

Examples:

```text
Flat Bench Barbell Press
Barbell Bench Press
Bench Press
BB Flat Bench
```

GoingBulk needs an alias/matching layer so these can point to the same canonical exercise when appropriate.

Recommended future table:

```text
exercise_aliases
```

Fields to consider:

```text
id
exercise_id
alias_name
source
confidence_level
notes
created_at
updated_at
```

When adding a planned exercise from a program, the app should:

```text
1. Search existing exercises by canonical name.
2. Search exercise aliases.
3. Suggest likely matches.
4. Allow the user to pick a match, create a new exercise, or leave unmatched temporarily.
5. Preserve the original program wording in exercise_name_snapshot.
```

This protects planned-vs-actual analysis while still preserving source wording.

### Injury-Aware Substitution Strategy

Because the user has past injuries and may not perform every program exactly as written, GoingBulk should support intentional exercise substitutions.

Substitutions should not be treated as random failures. They should be tracked as modifications with reasons.

Common substitution reasons:

```text
past_injury
joint_pain
equipment_unavailable
gym_crowding
movement_discomfort
skill_limit
fatigue
program_adjustment
preference
```

GoingBulk should eventually recommend or filter replacement exercises by:

```text
same primary muscle group
same movement pattern
similar equipment
lower joint stress
injury-friendly flag
user history
available equipment
previously successful substitutions
```

Example:

```text
Program planned: Barbell Back Squat
Actual substitution: Leg Press
Reason: lower back caution / injury history
Public summary: substituted lower-body compound movement due to injury history
```

The database should preserve both:

```text
planned_exercise = what the program prescribed
actual exercise = what the user performed
substitution reason = why it changed
```

This makes the data honest, useful, and safer for long-term training.

### planned_exercises

Exercises prescribed inside a planned workout/block.

Fields:

```text
id
planned_training_block_id
exercise_id nullable
exercise_name_snapshot
exercise_order
superset_group_label
movement_notes
substitution_allowed
instructions
notes
created_at
updated_at
```

Important:

`exercise_id` should be nullable because program PDFs may use exercise names that do not yet exist in the GoingBulk exercise library.

Keep `exercise_name_snapshot` so the original program wording is preserved privately.

### planned_sets

Set-level prescription.

Decision: do **not** defer this table. GoingBulk should preserve the exact planned set-level prescription from the source program where available, because the user wants to know exactly what the program said to do and then compare that to what actually happened in the gym.

The planned set record is not the same thing as the actual set log. Planned sets describe the program. Actual sets describe the user's performance. If the user changes weight, reps, exercise, rest time, skips a set, adds a set, or modifies the workout mid-session, that belongs in the actual workout tables and planned-vs-actual comparison logic.

This allows GoingBulk to show:

```text
planned: Set 1 - 8-10 reps
actual: 185 lb x 9 reps

planned: Set 2 - 8-10 reps
actual: skipped

planned: Set 3 - 8-10 reps
actual: substituted exercise / changed load / changed reps
```

Fields:

```text
id
planned_exercise_id
set_number
set_type
sets_count_snapshot optional
rep_target_type
rep_min
rep_max
rep_exact
rep_text_snapshot
load_target_type
load_value
load_unit
load_percent_1rm
rpe_target
rir_target
rest_seconds
rest_text_snapshot
tempo
is_to_failure
is_amrap
duration_seconds
instructions
notes
created_at
updated_at
```

Recommended `rep_target_type` values:

```text
exact
range
to_failure
amrap
timed
as_prescribed
text
```

Why this is needed:

Some plans use normal rep ranges. Others use to-failure work, timed holds, AMRAP, or written instructions that do not fit clean numeric values.

### user_training_programs

A user's scheduled run of a program.

Fields:

```text
id
training_program_id
user_profile_id
status
start_date
end_date
preferred_weekdays
default_start_time
timezone
current_phase_number
current_week_number
current_workout_number
schedule_policy
visibility
notes
created_at
updated_at
```

Recommended statuses:

```text
planned
active
paused
completed
abandoned
```

Recommended `schedule_policy` values:

```text
fixed_weekdays
rolling_next_available
manual
```

### scheduled_workouts

Concrete calendar workout instances generated from a user program run.

Fields:

```text
id
user_training_program_id
training_program_workout_id
scheduled_date
scheduled_start_time
scheduled_end_time
status
rescheduled_from_id
completed_workout_session_id
skip_reason
notes
created_at
updated_at
```

Recommended statuses:

```text
scheduled
completed
missed
skipped
rescheduled
cancelled
```

Why needed:

This supports the calendar/scheduler feature shown in the screenshot, where a user picks start date, start time, phase, and preferred workout days.

### Actual Workout Links

Existing tables should eventually link back to planned/scheduled training.

Add later:

```text
workout_sessions.scheduled_workout_id
workout_sessions.user_training_program_id
exercise_sets.planned_exercise_id
exercise_sets.planned_set_id
```

These links enable planned-vs-actual comparison.

## Scheduling Requirements

The screenshot shows program scheduling features that GoingBulk should support:

```text
program phase selection
days-per-week selection
weekday selection
start date
start time
calendar creation
```

GoingBulk scheduling should support:

```text
start date
preferred weekdays
default workout time
program phase or full program start
rest days
missed workout handling
rescheduling
manual overrides
calendar export later
```

## Re-Entry Scheduling Mode

GoingBulk should support a specific re-entry scheduling mode for users who have not trained consistently in years or are returning after a long break.

This is not a separate workout program type. It is a scheduling and adherence mode that can sit before a formal program run, such as the 12-Week Beginner to Advanced program.

### Purpose

The goal is to rebuild training rhythm, joint tolerance, tendon/ligament tolerance, movement skill, recovery capacity, and logging habits before starting a more structured program.

Recommended user path:

```text
Phase 0: 3-4 week re-entry block
Then: start 12-Week Beginner to Advanced
```

### Default Re-Entry Schedule

Recommended schedule:

```text
3 lifting days per week
full-body A/B rotation
at least 1 rest day between lifting sessions
optional walking/mobility on non-lifting days
```

Example week:

```text
Monday: Full Body A
Tuesday: Walk / mobility
Wednesday: Full Body B
Thursday: Rest / mobility
Friday: Full Body A
Saturday: Walk / mobility
Sunday: Rest
```

Next week:

```text
Monday: Full Body B
Wednesday: Full Body A
Friday: Full Body B
```

### Re-Entry Schedule Policy

Recommended schedule policy:

```text
rolling_next_available
```

This means workouts stay in sequence, but the next workout can move forward if recovery is poor.

Example:

```text
Workout A scheduled Monday
Workout B scheduled Wednesday
Workout A scheduled Friday

If soreness/joint pain is too high on Wednesday:
Workout B moves to Thursday or Friday
The change is logged as rescheduled due to recovery
```

Do not treat recovery-based rescheduling as failure. Treat it as accurate context.

### Re-Entry Intensity Rules

Recommended first-month rules:

```text
RPE 5-7 most sets
stop 3-4 reps before failure
no max attempts
no forced reps
no drop sets
no rest-pause
no extra volume unless intentionally logged
no ego lifting
```

### Re-Entry Readiness Checks

GoingBulk should track whether the user is ready to start the formal 12-week program.

Suggested readiness criteria:

```text
8-10 re-entry workouts completed
joint pain low or none
soreness manageable within 24-48 hours
basic lifts feel stable
recovery between sessions is acceptable
meal/water/supplement logging is mostly working
no repeated workout cancellations due to pain/fatigue
```

### Re-Entry Tracking Fields

Track during re-entry:

```text
scheduled re-entry workout
actual workout completed
sets/reps/load
RPE
session difficulty
joint pain before/during/after
soreness next day
sleep
bodyweight
meals
water
supplements
steps/walking
work/employment activity
notes
```

Important pain/context flags:

```text
knee pain
elbow pain
shoulder pain
lower back tightness
soreness lasting more than 48 hours
unusual fatigue
poor sleep
heavy work shift
missed meals
low hydration
```

### Public Transparency Angle

Public GoingBulk summaries should be able to say:

```text
I completed a 4-week re-entry phase before starting the 12-week program because I had not trained seriously in years.
The goal was consistency, recovery, and joint tolerance before pushing volume or intensity.
```

This gives viewers honest context and improves trust.

## Daily Workout Execution View Requirements

When the user opens today's workout, GoingBulk should show:

```text
program name
phase
week
workout/day label
scheduled date/time
workout focus
exercise order
training blocks
prescribed sets/reps/rest/tempo/special methods
previous performance
suggested starting load if available
notes/instructions
checkbox/logging flow for completed sets
substitutions
skip/modify buttons
```

The system should help answer:

```text
What am I supposed to do today?
What did I do last time?
What should I try to beat?
What did I skip or modify?
```

## Planned vs Actual Metrics

GoingBulk should eventually calculate:

```text
scheduled workouts
completed workouts
missed workouts
rescheduled workouts
program adherence percentage
exercise completion percentage
set completion percentage
rep target hit rate
extra work performed
skipped exercises
substitutions
average rest compliance if tracked
phase completion
week completion
```

## Special Program Structures To Support

The schema should support these without redesign:

```text
straight sets
rep ranges
exact reps
to-failure sets
AMRAP sets
timed holds
cardio intervals
warmup blocks
finishers
supersets
trisets
circuits
giant sets
special methods
weekly progression rules
nutrition/diet attachments
phase-specific notes
program-source notes
```

## Program Attachments

Some local program folders include nutrition/diet PDFs.

GoingBulk should not mix training prescriptions and nutrition prescriptions in the same tables.

Diet and nutrition files should be treated as source guidance/templates, not automatic proof that the user followed the plan exactly. The user may tailor the diet to stay as close as practical while accounting for real life, food preferences, budget, digestive tolerance, macro targets, and Cronometer logging.

GoingBulk should eventually distinguish:

```text
source diet guidance = what the program recommends
adapted nutrition plan = what the user intends to follow
actual nutrition logs = what the user actually ate
```

This supports diet-program alignment without falsely claiming exact compliance.

The user's actual nutrition workflow also needs to track meal timing and execution, not just daily macro totals. GoingBulk should support 5-6 planned meals per day with target times, meal names, intended foods/macros, actual completion, and links back to imported/normalized nutrition logs where possible.

GoingBulk should eventually distinguish:

```text
planned meals = what the user intended to eat and when
actual meals = what the user actually ate and logged
meal timing = when the meal was intended vs consumed
supplement schedule = what should be taken and when
supplement logs = what was actually taken, missed, skipped, or changed
water target = intended daily water intake
water logs = actual water consumed by time/day
weekly grocery list = planned foods/supplements to buy
actual grocery prices = what was paid and where
```

This matters because training-program diets are not only macro targets. They often imply meal frequency, timing, repeatable foods, supplement timing, hydration, and weekly prep/budget decisions.

Recommended future nutrition/planning support:

```text
nutrition_plan_templates
nutrition_plan_days
planned_meals
planned_meal_items
meal_logs
water_targets
water_logs
grocery_lists
grocery_list_items
grocery_price_logs
```

These should be designed in a dedicated nutrition planning/cost schema pass. Do not jam them directly into workout program tables.

Recommended future support:

```text
program_attachments
```

Fields:

```text
id
training_program_id
attachment_type
title
source_file_path_private
summary_private
public_summary
visibility
notes
created_at
updated_at
```

Attachment types:

```text
nutrition
diet
supplement
overview
training_system
workout_pdf
calendar
other
```

Do not expose private source PDFs publicly.

## Source File Tracking

For private traceability, GoingBulk should track where a program template came from.

Potential table:

```text
program_source_files
```

Fields:

```text
id
training_program_id
local_file_path
file_name
file_hash
page_count
source_type
notes
created_at
```

This lets GoingBulk know which PDF/source was used to create the private program template.

Do not store local private file paths in public APIs.

## Private Execution View vs Public Display View

GoingBulk should store and show detailed workout program data privately for the user's own execution, even when the public site only shows summaries.

The private execution view can include:

```text
full planned workout tables
full planned exercise order
planned sets
planned reps
planned rest periods
planned tempo
program notes/instructions
private diet guidance summaries
exact planned vs actual comparisons
substitution details
injury/pain notes
source file references
```

This private detail is necessary so the user can accurately follow the program, modify it safely, and compare what was prescribed against what actually happened.

The public display view should be a filtered transparency layer that shows the user's execution, adherence, modifications, summaries, and results without reproducing the proprietary source prescription.

The app should support explicit display modes:

```text
private_execution_view = full source-informed detail for the user/admin
public_summary_view = safe aggregate transparency for viewers
public_analysis_view = deeper aggregate analysis without reproducing paid prescriptions
```

Important rule:

```text
Private can be detailed.
Public must be respectful and non-substitutive.
```

A public page should not give viewers enough source prescription detail to replace access to the original paid program.

## Public Display Rules

Public GoingBulk can show:

```text
program source name
program name
training goal
program duration
phase/week/day identifiers
adherence percentage
completion summary
performance progression
personal notes
results
```

Public GoingBulk should not show:

```text
full proprietary workout tables
all exercises/sets/reps copied from paid program pages
private source PDFs
complete calendar generated from proprietary content
full nutrition/diet PDFs
```

## MVP Decision

Do not add planned-training tables to the current MVP schema PR.

The current PR should remain focused on actual training logs and core health/nutrition data.

However, GoingBulk must treat planned-program tracking as MVP-adjacent because the user intends to follow structured programs and accuracy matters.

Recommended sequence:

```text
1. Merge current MVP schema table PR if CI passes.
2. Create training-program schema doc/branch.
3. Add program template and scheduling tables.
4. Link workout_sessions to scheduled_workouts.
5. Link exercise_sets to planned exercises/sets where possible.
6. Build private admin/program-entry UI later.
```

## Open Questions Before Coding

Before implementing the schema, review 2-3 representative program days from each complete program family.

Questions:

```text
Do any programs require supersets/circuits?
Do any programs prescribe cardio intervals?
Do any programs prescribe timed holds?
Do any programs use exact progression formulas?
Do any programs include optional exercises or substitutions?
Do any programs prescribe percentages of 1RM?
Do any programs require nutrition/diet adherence tracking tied to training days?
Should program templates be entered manually, imported from structured files, or both?
How much proprietary detail should be stored privately?
```

## Recommended Next Documentation

After this doc, create:

```text
40-training-program-schema-contract.md
```

That document should translate this design into concrete table fields, constraints, indexes, visibility rules, and Drizzle implementation notes.

## Core Principle

```text
GoingBulk should track the program accurately enough to follow it privately and analyze adherence publicly without exposing copyrighted program content.
```

This preserves training accuracy without turning GoingBulk into a public mirror of paid/proprietary workout plans.

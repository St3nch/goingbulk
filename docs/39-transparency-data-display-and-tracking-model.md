# GoingBulk Transparency Data Display and Tracking Model

## Purpose

This document defines what GoingBulk should track and display to make the project transparent, useful, and viewer-readable.

GoingBulk should not only show raw logs. It should show the full story:

```text
What was planned?
What actually happened?
What changed?
What did it cost?
What was the context?
What result did it produce?
How confident should viewers be in the conclusion?
```

The goal is radical transparency without dumping private/proprietary source material or overwhelming viewers with unreadable tables.

## Core Principle

```text
Plan -> Execution -> Context -> Results -> Cost -> Transparency
```

Every major GoingBulk report should be able to explain these layers.

## Viewer Transparency Rule

GoingBulk should show honest public summaries of the user's actual behavior and results.

GoingBulk should not pretend perfect adherence when the user modified, skipped, substituted, rescheduled, or tailored the plan.

Public reporting should make it easy to say:

```text
This is what I intended to do.
This is what I actually did.
This is what changed.
This is what I spent.
This is what happened.
This is how confident I am in the result.
```

## Pre-Gym Baseline Phase

GoingBulk should treat the period before gym access as useful baseline data, not dead time.

If the user cannot start gym training yet because of transportation, finances, equipment access, or life constraints, the project can still collect a strong pre-training baseline.

This phase should capture what the user's body and lifestyle look like before structured gym training begins.

Recommended baseline activities:

```text
buy/setup wearable such as Hume Band
track sleep and recovery trends
track resting heart rate / HRV if available
track steps and daily activity
track work/employment activity
track bodyweight and measurements
track meals/macros through Cronometer or manual logs
track water and supplements
schedule bloodwork
schedule DEXA scan
record progress photos if comfortable
record baseline symptoms, soreness, pain, energy, mood
record grocery/supplement costs
```

Recommended baseline duration:

```text
2-6 weeks before formal gym training starts
```

This gives GoingBulk a clear before-state for later comparison.

Example public transparency statement:

```text
Before starting the gym program, I spent several weeks collecting baseline sleep, activity, body composition, bloodwork, nutrition, work activity, and recovery data. I delayed gym training until transportation was solved, but used that time to create a cleaner starting point.
```

This phase should be displayed separately from re-entry training and formal program training.

Suggested phase labels:

```text
pre_gym_baseline
re_entry_training
formal_program
experiment_phase
maintenance
```

Baseline data makes later claims stronger because viewers can compare:

```text
before gym training
re-entry block
formal 12-week program
post-program results
```
## Display Layer 1: Planned vs Actual

Planned-vs-actual tracking is the core GoingBulk transparency feature.

### Training Display

Track and display:

```text
scheduled workouts
completed workouts
missed workouts
rescheduled workouts
planned exercises
completed exercises
planned sets
completed sets
planned rep targets
actual reps
planned rest
actual rest if tracked
substitutions
extra exercises
extra sets
skipped exercises
ended-early sessions
```

Example public-safe display:

```text
Week 3 Training
Scheduled workouts: 4
Completed workouts: 3
Rescheduled workouts: 1
Exercises completed: 29 / 32
Sets completed: 86 / 96
Rep targets hit: 78%
Substitutions: 2
Extra work: 1 exercise
```

### Nutrition Display

Track and display:

```text
planned meals per day
actual meals logged
meal target times
actual meal times
meal timing adherence
calorie target vs actual
protein target vs actual
carb target vs actual
fat target vs actual
fiber target vs actual
water target vs actual
supplement schedule vs actual
```

Example:

```text
Week 3 Nutrition
Planned meals/day: 6
Average meals logged/day: 5.4
Meals within timing window: 72%
Calories adherence: 96%
Protein adherence: 98%
Water adherence: 81%
Supplements taken: 42 / 48
```

## Display Layer 2: Modifications and Changes

GoingBulk should explicitly track modifications instead of hiding them.

### Workout Modification Types

Recommended modification types:

```text
skipped_exercise
substituted_exercise
changed_exercise_order
changed_load
changed_rep_target
added_extra_set
removed_set
added_extra_exercise
ended_workout_early
changed_rest_time
changed_tempo
changed_training_day
rescheduled_workout
```

### Nutrition Modification Types

Recommended modification types:

```text
meal_skipped
meal_moved
food_swapped
portion_changed
macro_adjusted
ate_out
extra_snack
missed_supplement
extra_supplement
under_water_target
over_calorie_target
under_calorie_target
```

### Display Example

```text
What changed this week:
- Rescheduled one leg workout from Tuesday to Wednesday.
- Substituted hack squat for barbell squat.
- Missed Meal 5 twice.
- Added one extra snack on Friday.
- Grocery cost increased due to higher beef purchase.
```

## Display Layer 3: Daily Readiness, Recovery, and Work Context

Daily context makes the data more useful.

Work/employment time and work activity should be tracked because employment can significantly affect fatigue, recovery, calories burned, step count, hydration, meal timing, soreness, and workout performance. A physically active shift is not the same as a desk day, and GoingBulk should not treat them as equal background noise.

Track work context:

```text
work_shift_date
work_start_time
work_end_time
work_duration_hours
work_role_or_shift_type
work_activity_level
estimated_steps_at_work
manual_labor_minutes
standing_minutes
sitting_minutes
lifting/carrying_minutes
heat/cold exposure
work_stress_1_5
work_fatigue_1_5
meal_breaks_taken
water_access_quality
notes
```

Recommended work activity levels:

```text
sedentary
lightly_active
moderately_active
very_active
heavy_manual
```

Example display:

```text
Work Context
Worked: 8.5h
Activity level: very active
Estimated work steps: 12,400
Work fatigue: 4 / 5
Meal breaks: 2 / 3 planned
Note: High heat exposure and missed one planned meal.
```

This helps explain days where training, hydration, meal timing, recovery, or bodyweight changes look unusual.

Track a quick daily check-in:

```text
sleep_hours
sleep_quality_1_5
energy_1_5
stress_1_5
soreness_1_5
motivation_1_5
hunger_1_5
digestion_1_5
mood_1_5
resting_heart_rate
bodyweight
notes
```

Optional later:

```text
HRV
wearable sleep score
steps
body battery / recovery score
illness flag
injury flag
```

Example display:

```text
Context
Average sleep: 6.2h
Average stress: 4 / 5
Average soreness: 3 / 5
Bodyweight trend: +0.6 lb
Notes: low sleep before two weaker workouts
```

## Display Layer 4: Symptoms and Side Effects

Symptoms help explain supplement, diet, and training changes.

Track:

```text
headache
bloating
GI issues
cramps
joint pain
low energy
sleep disruption
heartburn
appetite change
skin/acne
libido change
other
```

Severity scale:

```text
none
mild
moderate
severe
```

Display example:

```text
Side effects this week:
GI discomfort: mild on 2 days
Sleep disruption: moderate on 1 day
Joint pain: none
```

## Display Layer 5: Cost Transparency

Cost is part of real-world fitness transparency.

Track:

```text
weekly_grocery_total
supplement_cost
program/app/subscription_cost if relevant
cost_per_day
cost_per_meal
cost_per_gram_protein
cost_per_100g_protein
store/vendor
item prices
sale/discount notes
```

Example display:

```text
Week 3 Cost
Groceries: $148.72
Supplements: $19.40
Total: $168.12
Cost/day: $24.02
Average protein/day: 218g
Cost per 100g protein: $11.02
```

## Display Layer 6: Program Difficulty and Perceived Effort

After each workout, track:

```text
session_difficulty_1_10
pump_1_10
fatigue_1_10
joint_stress_1_10
enjoyment_1_10
would_repeat
session_notes
```

Display example:

```text
Training Feel
Average difficulty: 8.1 / 10
Highest difficulty: Legs
Highest joint stress: Shoulders
Most enjoyable workout: Back/Biceps
```

## Display Layer 7: Exercise Performance Landmarks

For major lifts and repeated exercises, track:

```text
best_weight_for_reps
estimated_1rm
volume_pr
rep_pr
session_volume
weekly_volume
load_progression
rep_progression
```

Display example:

```text
Bench Press
Start: 185 x 8
Best this block: 205 x 7
Estimated 1RM change: +18 lb
Weekly chest volume: +22%
```

## Display Layer 8: Body Composition Context

Track and display:

```text
daily_bodyweight
weekly_average_bodyweight
waist
progress_photos
body_fat_estimate
DEXA date/result when available
```

Display example:

```text
Body Composition
Scale weight: +4.2 lb
Waist: +0.3 in
Training completion: 91%
Calories adherence: 94%
Strength trend: up
```

## Display Layer 9: Data Source and Confidence

Every public conclusion should include confidence and data source context.

Track source types:

```text
manual
Cronometer import
device import
lab report
DEXA
estimated
program source
adapted plan
```

Confidence levels:

```text
low
medium
high
experimental
```

Example display:

```text
Conclusion
Creatine may have improved training performance.

Confidence: Medium
Why: Training volume increased, but calories and sleep also improved.
Data sources: manual workout logs, Cronometer exports, bodyweight logs
```

## Weekly Scorecard

A weekly scorecard should become a primary GoingBulk display format.

Example:

```text
Week 4 Scorecard

Training
Scheduled workouts: 4
Completed: 4
Set completion: 92%
Rep target hit rate: 81%

Nutrition
Planned meals/day: 6
Average meals logged: 5.6
Calories adherence: 96%
Protein adherence: 98%
Water adherence: 74%

Recovery
Average sleep: 6.8h
Stress: moderate
Soreness: high

Cost
Groceries: $151.24
Supplements: $21.40
Cost/day: $24.66

Results
Weight: +0.7 lb
Waist: unchanged
Best lift: incline DB press +10 lb

Transparency Notes
Missed Meal 6 twice. Substituted hack squat for barbell squat. Sleep was lower than target.
```

## Public-Safe Summary Views

Because private source prescriptions and public transparency are different, GoingBulk should eventually expose computed public-safe summaries.

Public-safe summaries can show:

```text
program name/source
week/phase identifiers
completion percentages
actual performance logs
aggregate adherence
modification counts
cost summaries
nutrition adherence
water adherence
supplement adherence
results
limitations
confidence level
```

Public-safe summaries should not show:

```text
full proprietary workout tables
complete source program exercise prescriptions
paid diet PDFs
private source file paths
complete calendar generated from proprietary content
```

Potential future support:

```text
public_summary_records
weekly_scorecards
experiment_report_summaries
```

These may be generated from private data instead of manually stored.

## Recommended Future Tracking Areas

Required soon / MVP-adjacent:

```text
daily_checkins
workout_modifications
nutrition_modifications
planned_meals
meal_logs
water_logs
grocery_lists
grocery_list_items
grocery_price_logs
weekly_scorecards
```

Already partially covered:

```text
workout_sessions
exercise_sets
supplement_logs
nutrition_logs
nutrition_log_nutrients
measurements
confounder_logs
```

Later:

```text
symptom_logs
performance_landmarks
public_summary_records
cost_analytics_views
confidence_summary_views
```

## Schema Design Notes

Do not cram all of this into one table.

Recommended future schema passes:

```text
1. Training program schema contract
2. Nutrition planning and grocery cost schema
3. Daily check-in/recovery schema
4. Public summary/scorecard views
```

## Core Display Question

Every dashboard/report should answer:

```text
What did I plan?
What did I do?
What did I change?
What did it cost?
What was going on?
What happened?
How confident should we be?
```

That is the GoingBulk transparency loop.


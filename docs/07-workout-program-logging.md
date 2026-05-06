# GoingBulk Workout Program Logging

## Purpose

GoingBulk needs a mobile-first workout logging system and a desktop/admin program builder.

The goal is to track both:

```text
what was planned
+
what actually happened
```

This creates better training adherence data, better progress analysis, and better content.

## Core Principle

Workout logging must be fast enough to use in the gym.

A beautiful logging UI that slows down training will fail.

## Main Use Cases

### Mobile Logging

The phone app should support:

- starting today's scheduled workout;
- seeing planned exercises;
- seeing previous performance;
- entering weight, reps, RPE, and notes;
- automatic rest timer;
- quick set completion;
- editing mistakes easily;
- finishing the workout and seeing a summary.

### Desktop Program Builder

The admin dashboard should support:

- creating workout programs;
- scheduling 8-week, 12-week, or custom-length plans;
- creating workout templates;
- assigning templates to days/weeks;
- defining progression rules;
- reviewing planned vs actual performance.

## Planned vs Actual Model

Do not mix templates with completed sessions.

```text
Workout template = plan
Workout session = actual logged workout
Exercise set = actual performed set
```

## Core Tables

### programs

```text
id
name
goal
duration_weeks
start_date
end_date
status
notes
```

### program_weeks

```text
id
program_id
week_number
phase_name
notes
```

### workout_templates

```text
id
name
type
goal
notes
```

### workout_template_exercises

```text
id
workout_template_id
exercise_id
order_index
target_sets
target_reps_min
target_reps_max
target_rpe
rest_seconds
progression_rule
notes
```

### scheduled_workouts

```text
id
program_id
program_week_id
scheduled_date
workout_template_id
status
notes
```

### workout_sessions

```text
id
scheduled_workout_id
date
started_at
ended_at
session_type
duration_minutes
status
notes
```

### exercise_sets

```text
id
workout_session_id
exercise_id
set_number
set_type
planned_reps_min
planned_reps_max
actual_reps
planned_load
actual_load
rpe
rest_seconds
notes
```

### exercises

```text
id
name
slug
primary_muscle_group
secondary_muscle_groups
equipment
movement_pattern
notes
```

## Today Screen Workout Flow

```text
Today
-> Push Day - Week 3 Day 2
-> Start Workout
-> Exercise 1
-> Set logging
-> Rest timer
-> Next set/exercise
-> Finish Workout
-> Summary
```

## Set Logging Fields

Minimum:

```text
exercise
set_number
weight/load
reps
RPE
rest time
notes optional
```

Later:

```text
tempo
pain flag
warm-up vs working set
drop set
superset group
machine setting
```

## Useful Mobile Features

- previous workout values visible;
- auto-fill last used weight;
- one-tap complete set;
- rest timer starts automatically;
- quick RPE input;
- exercise notes;
- PR detection;
- offline-safe draft saving;
- edit history where needed.

## 12-Week Program Model

Example:

```text
Program: 12-Week Bulk Hypertrophy Block
Weeks 1-4: accumulation
Weeks 5-8: progression
Weeks 9-11: intensification
Week 12: deload/test
```

Schedule example:

```text
Monday: Push
Tuesday: Pull
Wednesday: Legs
Thursday: Rest
Friday: Upper
Saturday: Lower
Sunday: Rest
```

## Program Metrics

The dashboard should calculate:

- workouts planned;
- workouts completed;
- completion rate;
- sets planned vs completed;
- volume by exercise;
- volume by muscle group;
- average RPE;
- PRs;
- missed sessions;
- deload weeks;
- adherence percentage.

## Planned vs Actual Reporting

Example:

```text
Planned sets: 18
Completed sets: 17
Planned volume: 21,400 lb
Actual volume: 20,850 lb
Completion: 94%
```

This becomes excellent weekly content.

## Experiment Integration

Training data should connect to experiments.

Examples:

- Creatine protocol should show training volume and strength changes;
- Hume vs DEXA experiment should show training stimulus;
- high-protein experiment should show workout adherence and performance;
- deload experiment should show recovery/performance response.

## Public Display

Public dashboards should simplify training data.

Normal view:

```text
5 workouts completed this week
94% of planned sets completed
Bench press volume up 6% from last week
```

Expert view:

```text
exercise-level volume, RPE, set count, date ranges, progression rules, and adherence calculations
```

## Build Priority

MVP:

1. exercise library;
2. workout templates;
3. scheduled workouts;
4. mobile session logger;
5. set logging;
6. workout summary;
7. basic planned vs actual dashboard.

Later:

- progression recommendations;
- automatic deload flags;
- LLM program analysis;
- coach/professional review exports;
- wearable recovery overlay.

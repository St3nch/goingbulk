# GoingBulk Mobile Logging UX

## Purpose

This document defines the mobile-first logging experience for GoingBulk.

The mobile logging system is one of the most important parts of the project. If logging is slow, annoying, or confusing, the entire data engine weakens.

## Core Principle

```text
Log in seconds, not minutes.
```

The logging app should make the correct action obvious, fast, and hard to forget.

## Product Shape

The first mobile logging experience should be a responsive Next.js PWA, not a native iOS/Android app.

Reasons:

- one codebase;
- shared auth/backend/database;
- installable on phone;
- fast iteration;
- no app store friction;
- easier alignment with the website/admin system.

## Primary Navigation

Suggested bottom navigation:

```text
Today
Food
Workout
Body
More
```

### Today

Daily cockpit.

### Food

Nutrition status, imported logs, planned meals, meal templates later.

### Workout

Today's workout, active session, workout history.

### Body

Bodyweight, measurements, device readings, progress photos.

### More

Supplements, experiments, notes, settings, reports.

## Today Screen

The Today screen should answer:

```text
What do I need to log today?
What is already done?
What is still missing?
```

Example sections:

```text
Nutrition
- Cronometer import status
- calories/protein progress
- planned meals if available

Training
- scheduled workout
- start workout button
- completion status

Supplements
- checklist of scheduled supplements
- one-tap taken/missed

Body
- morning weight
- measurement reminder
- progress photo reminder if scheduled

Experiments
- active experiment reminders
- protocol notes

Notes
- confounder prompt
- energy/soreness/stress quick log
```

## Food Logging UX

Phase 1 nutrition should rely on Cronometer export/import.

Mobile food UX in the MVP should focus on:

- showing imported nutrition status;
- showing daily macro totals;
- showing targets vs actual;
- allowing notes or corrections if needed;
- later supporting meal templates.

Do not build a full food database replacement first.

### Later Food Features

- planned meals;
- meal templates;
- log planned meal;
- adjust grams;
- duplicate yesterday;
- repeat meal;
- custom foods;
- barcode search if justified later.

## Workout Logging UX

Workout logging must be optimized for gym use.

Flow:

```text
Today
-> Start Workout
-> Exercise screen
-> Log set
-> Rest timer
-> Next set
-> Next exercise
-> Finish workout
-> Summary
```

## Exercise Screen Requirements

Each exercise screen should show:

- exercise name;
- planned sets/reps/load/RPE if available;
- previous workout performance;
- current set inputs;
- rest timer;
- notes button;
- skip/exercise substitute option later.

## Set Logging Requirements

Minimum fields:

```text
weight/load
reps
RPE
rest time
notes optional
```

Useful shortcuts:

- auto-fill previous load;
- one-tap complete set;
- duplicate last set;
- quick increment/decrement buttons;
- rest timer auto-start;
- previous set visible.

## Supplement Logging UX

Supplements should be a daily checklist.

Each item should show:

```text
supplement name
product if relevant
planned dose
time/frequency
status: pending/taken/missed/skipped
```

Actions:

```text
taken
missed
skip with reason
adjust dose
add note
```

## Body Logging UX

Body logging should be fast.

MVP:

- bodyweight;
- waist measurement if used;
- notes;
- source/method if needed.

Later:

- Hume readings;
- wearable imports;
- progress photo sessions;
- DEXA/bloodwork reminders.

## Confounder Logging UX

Confounders must be easy to capture.

Quick flags:

```text
poor_sleep
high_stress
illness
injury
travel
missed_workout
missed_supplement
high_sodium
alcohol
deload
new_program
calorie_change
```

A daily prompt can ask:

```text
Anything today that could affect the data?
```

This can be optional but easy.

## Active Experiment UX

If an experiment is active, the Today screen should show:

```text
Experiment: 90-Day Creatine Test
Day: 23 of 90
Today's protocol: creatine 5g
Primary metrics: bodyweight, workout volume, supplement adherence
```

This keeps experiments from becoming forgotten calendar ghosts.

## Mobile Design Principles

### 1. One Primary Action

Each screen should have one obvious next action.

Examples:

```text
Start Workout
Log Weight
Mark Creatine Taken
Review Today's Nutrition
```

### 2. Minimize Typing

Use:

- buttons;
- steppers;
- previous values;
- templates;
- one-tap actions;
- defaults.

### 3. Autosave

Workout sessions and logs should autosave aggressively.

Losing workout data mid-session is unacceptable.

### 4. Offline-Tolerant Later

The app should eventually tolerate weak gym Wi-Fi.

MVP can be online-first, but the design should not prevent offline support later.

### 5. Never Hide Source

When showing imported/device data, include source where relevant.

Examples:

```text
Nutrition source: Cronometer export
Body composition source: Hume Pod
```

## MVP Mobile Screens

Required MVP screens:

```text
/app/today
/app/workout/current
/app/workout/history
/app/body/weight
/app/supplements
/app/experiments/current
```

Useful but later:

```text
/app/food/templates
/app/progress-photos
/app/device-readings
/app/notes
```

## Success Criteria

Mobile logging succeeds if:

- daily checklist takes under one minute outside workouts;
- workout logging does not disrupt training;
- supplement logging is one tap;
- bodyweight logging is under 10 seconds;
- confounder logging is easy enough to actually use;
- data is structured enough for reports and experiments.

## Core Rule

```text
The mobile app exists to protect consistency. Consistency creates the dataset. The dataset creates the brand.
```

# GoingBulk Product Vision

## Product Definition

GoingBulk is both a public website and a private logging system.

The public website tells the story and displays the receipts.
The private app/admin system makes the data easy to capture, organize, and publish.

## Product Layers

### Public Website

The public site is the audience-facing brand surface.

It should include:

- homepage/dashboard;
- experiment archive;
- supplement hub;
- product review pages;
- methodology pages;
- data dictionary;
- sponsor and affiliate disclosures;
- for-professionals page;
- newsletter signup;
- social links;
- roadmap.

### Mobile-First Logging App

The mobile app experience should support daily capture.

It should make it easy to:

- log bodyweight;
- confirm meals/imported nutrition;
- log supplements;
- start today's workout;
- record sets, reps, load, RPE, and rest time;
- capture notes, soreness, energy, or confounders;
- see today's checklist.

This can start as a Next.js progressive web app rather than a native mobile app.

### Desktop/Admin Dashboard

The admin dashboard is for planning and review.

It should support:

- creating workout programs;
- scheduling 12-week training blocks;
- managing meal templates;
- importing Cronometer data;
- creating experiments;
- managing products and affiliate links;
- reviewing data quality;
- preparing reports;
- managing pages, entities, internal links, and schema records.

## Core Screens

### Today Screen

The Today screen is the daily cockpit.

It should show:

- today's planned workout;
- meal/nutrition status;
- supplement checklist;
- bodyweight logging status;
- active experiment reminders;
- notes/confounder prompts.

### Nutrition Dashboard

Should show:

- calories;
- protein;
- carbs;
- fat;
- fiber;
- sodium;
- sugar;
- weekly averages;
- target adherence;
- experiment overlays.

### Training Dashboard

Should show:

- workouts completed;
- planned vs actual volume;
- sets by muscle group;
- exercise history;
- PRs;
- program week;
- adherence.

### Experiment Dashboard

Should show:

- active experiments;
- baseline/intervention/follow-up windows;
- tracked metrics;
- confounders;
- confidence rating;
- summary result.

### Product Review Dashboard

Should show:

- products used;
- product status;
- sponsor/affiliate disclosure;
- usage windows;
- related experiments;
- data confidence;
- verdict.

## Audience Modes

Major reports and dashboards should support two views.

### Normal View

Plain-language, visual, and fast to understand.

### Expert View

More detailed, including:

- methodology;
- data source;
- date ranges;
- units;
- confidence labels;
- confounders;
- limitations;
- export links where appropriate.

## Experience Principle

The product must make logging easier than avoidance.

If data entry is painful, the brand loses its foundation.

## MVP Product Scope

The first useful version should include:

1. public homepage/dashboard;
2. Cronometer import pipeline;
3. nutrition dashboard;
4. workout logging;
5. bodyweight logging;
6. supplement checklist;
7. experiment records;
8. methodology page;
9. sponsor/affiliate disclosure pages;
10. basic content/entity page structure.

## Product Expansion Later

Later phases can add:

- Hume/Samsung/wearable integrations;
- DEXA and bloodwork modules;
- professional exports;
- LLM assistant;
- VedaOps/V Forge integration;
- public chat trained only on published GoingBulk content;
- sponsor reporting packages;
- newsletter automation.

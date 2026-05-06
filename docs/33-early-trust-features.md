# GoingBulk Early Trust Features

## Purpose

This document defines the small, high-trust features that should be added early because they make GoingBulk more credible without bloating the MVP.

These features are not shiny platform expansions. They are trust infrastructure.

## Core Principle

```text
Add early features only when they make the data more credible, the process more transparent, or the interpretation safer.
```

GoingBulk should not implement every interesting idea at once.

The early focus should be:

```text
1. Experiment Pre-Registration
2. Methodology Changelog
```

These are high-value, low-complexity trust features.

## Why These Two

### Experiment Pre-Registration

Pre-registration improves credibility by publishing the experiment plan before results exist.

It helps prevent:

- moving goalposts;
- post-hoc storytelling;
- cherry-picking success criteria;
- pretending an accidental result was the original target;
- vague experiments that become whatever the data later supports.

### Methodology Changelog

A methodology changelog improves credibility by showing when and why measurement methods changed.

It helps prevent:

- silent protocol drift;
- false trend comparisons;
- confusion when data collection improves;
- professionals misinterpreting old vs new measurements;
- readers assuming all historical data is directly comparable.

## Feature 1: Experiment Pre-Registration

### Purpose

Document the experiment before it starts.

The pre-registration page should say:

```text
Here is what I plan to test.
Here is how I plan to test it.
Here is what would count as success, failure, or inconclusive.
Here are the confounders I will track.
Here is what I will not claim.
```

### Suggested Routes

```text
/experiments/[slug]/pre-registration
```

Examples:

```text
/experiments/baseline-30-days/pre-registration
/experiments/creatine-90-day-test/pre-registration
/experiments/hume-vs-dexa-12-week-comparison/pre-registration
```

### MVP Implementation

Use MDX first.

No complex database workflow is required for MVP.

Recommended frontmatter:

```yaml
title: Baseline 30 Days Pre-Registration
experiment_slug: baseline-30-days
status: registered
registered_at: 2027-01-01
planned_start: 2027-01-01
planned_end: 2027-01-30
locked: true
visibility: public
```

### Required Sections

Every pre-registration page should include:

```text
Question
Hypothesis
Experiment type
Planned start date
Planned end date
Protocol
Primary metric
Secondary metrics
Success criteria
Inconclusive criteria
Negative / failed criteria
Confounders to track
Data sources
Source confidence expectations
Safety notes
N=1 limitation
Medical disclaimer where relevant
Change policy
```

### Example Template

```markdown
# Experiment Pre-Registration: [Experiment Name]

## Status

Registered before start.

## Registration Date

[date]

## Planned Dates

Start: [date]
End: [date]

## Question

What am I trying to learn?

## Hypothesis

What do I expect to happen?

## Protocol

What will I do?

## Primary Metric

What metric matters most?

## Secondary Metrics

What else will I track?

## Success Criteria

What would count as a meaningful positive result?

## Inconclusive Criteria

What would count as too small or too noisy to interpret?

## Negative / Failed Criteria

What would count as a negative result or reason to stop?

## Confounders To Track

What could distort the result?

## Data Sources

Where will the data come from?

## Limitations

Why this does not prove causation.

## Safety Notes

Any health/supplement/training cautions.

## Change Policy

What can be changed after registration, and how will changes be disclosed?
```

### Change Policy

After an experiment starts, the pre-registration should not be silently edited.

Allowed changes:

- typo fixes;
- clarifying notes;
- safety updates;
- appended amendments.

Not allowed:

- changing success criteria without disclosure;
- changing primary metrics after seeing results;
- deleting failed criteria;
- hiding protocol changes.

Use an amendment section:

```markdown
## Amendments

### 2027-02-10
Changed [specific item] because [reason]. This occurred after the experiment started and should be considered when interpreting results.
```

## Feature 2: Methodology Changelog

### Purpose

Track changes to how GoingBulk measures, logs, imports, summarizes, or publishes data.

The methodology changelog should answer:

```text
What changed?
When did it change?
Why did it change?
What data is affected?
Can old and new data still be compared?
```

### Suggested Route

```text
/methodology/changelog
```

### MVP Implementation

Use MDX first.

Each changelog entry can be a heading or structured frontmatter block later.

### Required Fields

Each entry should include:

```text
Date
Method area
Old method
New method
Reason for change
Affected data range
Comparability impact
Confidence impact
Related pages/reports
```

### Method Areas

Examples:

```text
bodyweight
nutrition logging
Cronometer import
workout logging
training volume calculation
supplement adherence
blood pressure measurement
DEXA provider
Hume/body composition device
bloodwork provider
progress photos
public export format
```

### Example Entry

```markdown
## 2027-03-15: Bodyweight Protocol Changed

Method area: bodyweight

Old method:
Weekly weigh-in on Sunday morning.

New method:
Daily weigh-in with weekly average.

Reason:
Weekly weigh-ins were too volatile and made trend interpretation harder.

Affected data:
Bodyweight data before 2027-03-15 is based on weekly values. Data after 2027-03-15 uses daily values and weekly averages.

Comparability impact:
Pre-change and post-change trends are not perfectly comparable. Weekly averages after the change should be treated as more stable.

Confidence impact:
Bodyweight trend confidence improved after the change.
```

## MVP Integration

These two features can be added without major schema changes.

### Add To MVP Public Pages

```text
/experiments/baseline-30-days/pre-registration
/methodology/changelog
```

### Link From

Pre-registration should be linked from:

```text
/experiments/baseline-30-days
/methodology
```

Methodology changelog should be linked from:

```text
/methodology
/data/baseline-30-days
/experiments/baseline-30-days
```

## Optional Database Support Later

### experiment_registrations

Possible later table:

```text
id
experiment_id
registered_at
locked_at
status
question
hypothesis
protocol
primary_metrics
secondary_metrics
success_criteria
inconclusive_criteria
negative_criteria
confounders_to_track
data_sources
limitations
safety_notes
visibility
created_at
updated_at
```

### methodology_changelog_entries

Possible later table:

```text
id
entry_date
method_area
old_method
new_method
reason
affected_start_date
affected_end_date
comparability_impact
confidence_impact
related_page_ids
visibility
created_at
updated_at
```

Do not build these tables until MDX becomes limiting.

## Features To Keep Later

The uploaded idea list includes several strong ideas that should stay in the backlog, but not all should be built early.

### Later, High-Value Candidates

```text
Negative Results Archive
Prediction vs Reality
Data Quality Score per Metric
Sponsor Transparency Dashboard
```

### Much Later Candidates

```text
Ask My Data public LLM interface
Community Experiment Suggestions / Voting
Interactive Recreate My Experiment calculators
Living Systematic Review pages
Dataset Diff tool
Confounder-corrected interactive views
```

## Why Not Build Everything Now

GoingBulk should avoid feature overload.

The first goal is not to become a giant platform.

The first goal is to prove:

```text
I can collect real data consistently.
I can publish it honestly.
I can explain what changed and what did not.
I can avoid overstating what the data means.
```

## Build Priority

### Build Soon

```text
Experiment Pre-Registration
Methodology Changelog
```

### Build After First Completed Experiment

```text
Negative Results Archive
Data Quality Score per Metric
```

### Build After Multiple Experiments

```text
Prediction vs Reality
Dataset Diff Tool
Confounder-corrected views
```

### Build After Audience Exists

```text
Community Experiment Suggestions
Sponsor Transparency Dashboard
Ask My Data public interface
```

## Core Rule

```text
Early trust features should make GoingBulk more credible without making the MVP heavier than it needs to be.
```

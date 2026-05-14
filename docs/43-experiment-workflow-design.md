# Experiment Workflow Design

## Purpose

This document defines the future experiment workflow model for GoingBulk.

GoingBulk experiments should connect:

- hypotheses
- interventions
- measurements
- supplements
- nutrition changes
- training changes
- confounders
- evidence links
- outcomes
- audit trails
- publication decisions

The goal is not to pretend personal tracking is a clinical trial.

The goal is to make personal N=1 experimentation structured, transparent, reproducible, and honest about uncertainty.

## Design Principle

An experiment is not just a note.

An experiment is a governed workflow:

1. State the question.
2. Define the hypothesis.
3. Define the intervention.
4. Define the expected outcome.
5. Define the measurement window.
6. Track confounders.
7. Record what happened.
8. Compare result against hypothesis.
9. Decide whether it is publishable.
10. Preserve provenance.

## Core User Story

Example:

> I want to test whether increasing creatine by 2 grams per day improves workout performance, body weight, recovery, or subjective fatigue over four weeks.

GoingBulk should let the user record:

- the claim or idea being tested
- why it is worth testing
- the intervention protocol
- baseline period
- active period
- washout period if relevant
- primary metric
- secondary metrics
- confounders
- subjective notes
- final interpretation
- evidence links
- publication status

## Scope

### In Scope

Initial experiment workflow should support:

- basic experiment lifecycle
- supplement interventions
- nutrition interventions
- training interventions
- sleep/recovery interventions
- primary and secondary outcome metrics
- evidence/citation links
- hypothesis/result comparison
- auditability
- public/private visibility

### Out of Scope for Now

Do not build yet:

- automated statistical inference
- complex Bayesian modeling
- multi-participant studies
- automated supplement recommendations
- clinical decision support
- medical advice generation
- AI-only experiment approval
- full literature ingestion tables
- public dataset release workflow

## Experiment Lifecycle

Suggested statuses:

- `idea`
- `planned`
- `active`
- `paused`
- `completed`
- `abandoned`
- `published`

Lifecycle meaning:

### idea

A rough thought worth considering.

### planned

Protocol is defined but not started.

### active

Experiment is currently running.

### paused

Experiment is temporarily stopped due to illness, travel, injury, schedule disruption, or another confounder.

### completed

Experiment finished and has results.

### abandoned

Experiment stopped before meaningful completion.

### published

Experiment has been reviewed and made public or included in a public report.

## Candidate Schema Concepts

This is a design document, not an immediate migration contract.

### Existing `experiments` Table

The current `experiments` table should remain the root entity.

Potential future additions:

- `hypothesis`
- `status`
- `started_at`
- `ended_at`
- `baseline_start_at`
- `baseline_end_at`
- `active_start_at`
- `active_end_at`
- `primary_outcome_metric`
- `result_summary`
- `interpretation`
- `confidence`
- `publication_status`

Do not add every field immediately. Start with the minimum needed to support one real experiment.

### `experiment_interventions`

Tracks what changed.

Potential fields:

- `id`
- `experiment_id`
- `intervention_type`
- `supplement_id`
- `nutrition_target`
- `training_target`
- `description`
- `dose`
- `unit`
- `timing`
- `frequency`
- `start_date`
- `end_date`
- `protocol_notes`
- `created_at`
- `updated_at`

Intervention types might include:

- `supplement`
- `nutrition`
- `training`
- `sleep`
- `recovery`
- `behavior`
- `device`
- `other`

### `experiment_outcomes`

Tracks expected and observed outcomes.

Potential fields:

- `id`
- `experiment_id`
- `metric_key`
- `outcome_type`
- `expected_direction`
- `baseline_value`
- `target_value`
- `observed_value`
- `unit`
- `result_direction`
- `confidence`
- `notes`
- `created_at`
- `updated_at`

Outcome types might include:

- `primary`
- `secondary`
- `safety`
- `exploratory`

Expected/result directions might include:

- `increase`
- `decrease`
- `no_change`
- `stabilize`
- `unknown`

Confidence labels might include:

- `low`
- `moderate`
- `high`
- `inconclusive`

### `experiment_evidence_links`

Links an experiment to citations, papers, websites, videos, or manually entered rationale.

Potential fields:

- `id`
- `experiment_id`
- `source_type`
- `title`
- `url`
- `doi`
- `pmid`
- `citation_text`
- `evidence_type`
- `summary`
- `notes`
- `created_at`
- `updated_at`

Source types might include:

- `pubmed`
- `doi`
- `website`
- `book`
- `video`
- `manual_note`
- `product_label`
- `coach_advice`
- `other`

Evidence types might include:

- `meta_analysis`
- `systematic_review`
- `randomized_controlled_trial`
- `controlled_trial`
- `observational_human`
- `animal_study`
- `mechanistic`
- `expert_opinion`
- `marketing_claim`
- `personal_observation`
- `unknown`

### `experiment_confounder_links`

Links tracked confounders to an experiment.

Potential fields:

- `id`
- `experiment_id`
- `confounder_log_id`
- `impact_direction`
- `impact_notes`
- `created_at`

This may not be needed immediately if `confounder_logs` can be filtered by date range.

## Minimal First Implementation

The first implementation should be intentionally small.

Suggested MVP experiment workflow:

1. Extend `experiments` only if needed.
2. Add `experiment_interventions`.
3. Add `experiment_outcomes`.
4. Add `experiment_evidence_links`.
5. Use existing visibility/RLS/audit posture.
6. Add hammer tests for ownership and visibility.

Do not implement advanced statistics yet.

## Governance Requirements

Experiment workflow must preserve the existing security model.

Requirements:

- every experiment belongs to a user
- every child record inherits experiment ownership
- public visibility must be explicit
- visibility transitions must be audited
- published experiments must preserve provenance
- evidence links must not imply medical claims
- abandoned experiments must remain historically visible to owner/admin
- public experiment summaries must be careful about uncertainty

## Audit Requirements

Future audit events should include:

- experiment created
- experiment status changed
- experiment visibility changed
- intervention added
- intervention changed
- outcome added
- outcome changed
- evidence link added
- experiment published
- experiment unpublished

Initial implementation can rely on visibility audit triggers already in the database for visibility changes.

Additional lifecycle audit triggers can be added later.

## RLS Requirements

Experiment child tables should follow parent ownership.

Expected behavior:

- owner can create/update/delete own experiment child rows
- owner/admin can access all
- anon can only read child rows attached to public experiments
- professional viewer can read professional-visible experiments if policy allows
- non-owner authenticated users cannot write child rows for another user

Hammer tests should prove:

- owner insert works
- cross-user insert fails
- anon cannot read private experiment child rows
- anon can read public experiment child rows
- visibility transitions affect child visibility

## Publication Model

Publication should be treated as a governance action, not a simple checkbox.

Future fields may include:

- `published_at`
- `published_by`
- `publication_notes`
- `review_status`
- `reviewed_by`
- `reviewed_at`

Do not implement these until actual public reporting workflow exists.

## Relationship to Literature Pipeline

This workflow is the bridge between current experiments and future research/literature features.

The future literature pipeline may discover papers and claims.

Experiment workflow turns selected claims into personal tests.

The relationship should be:

1. Literature claim inspires experiment idea.
2. Experiment defines protocol and outcomes.
3. Personal data is collected.
4. Result is interpreted carefully.
5. Public summary may link back to evidence.

Do not let literature ingestion automatically create recommendations.

## Claim Safety

Experiment summaries should avoid:

- medical advice
- universal supplement recommendations
- overclaiming causality
- declaring proof from one personal trial
- ignoring confounders

Preferred language:

- "In this N=1 test..."
- "This result suggests..."
- "This did not prove..."
- "Confounders included..."
- "This may be worth retesting..."

## Example Experiment

### Title

Creatine dose increase test

### Hypothesis

Increasing creatine monohydrate by 2 grams per day for four weeks may improve training performance or body weight trend without worsening subjective fatigue.

### Intervention

- supplement: creatine monohydrate
- change: +2 grams per day
- timing: morning
- duration: 28 days

### Primary Outcome

- workout volume load

### Secondary Outcomes

- body weight trend
- subjective recovery
- perceived fatigue
- resting heart rate

### Confounders

- sleep disruption
- illness
- travel
- calorie changes
- training program changes

### Result Framing

The result should be interpreted as personal evidence, not general proof.

## Do Not Overbuild Yet

Do not build:

- statistical engine
- automated recommendation system
- full literature ingestion
- multi-user study coordination
- public dataset releases
- AI experiment designer

Build enough to run one real, well-documented experiment.

## Open Questions

- Should experiment interventions be fully normalized now or start semi-structured?
- Should outcomes link directly to existing measurements/workout/nutrition tables?
- Should experiment status changes be audited immediately?
- How much publication metadata is needed before the first public experiment?
- Should evidence links be independent now or wait for the literature module?
- Should abandoned experiments be publicly visible if they were pre-registered?

## Status

Planning document.

No schema should be implemented until this design is reviewed and tightened.

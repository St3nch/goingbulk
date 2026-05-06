# GoingBulk Data Boundary and VedaOps Context

## Purpose

This document defines the working boundary between GoingBulk and the VedaOps ecosystem.

VedaOps doctrine is context only for these GoingBulk docs. The VedaOps docs repository must remain read-only unless explicitly handled through its own governed process.

## Current Working Model

GoingBulk begins as an idea that would normally be shaped in Project V, then handed off to V Forge for execution.

Because GoingBulk planning started early in conversation, these docs should be treated as pre-intake discovery material until formally admitted or structured inside VedaOps.

## VedaOps Role Mapping

### Project V

Project V would own GoingBulk planning truth:

- project intake;
- project scope;
- readiness;
- decisions;
- blockers;
- priorities;
- handoff packages;
- return-to-planning handling.

Project V should not own GoingBulk's long-lived runtime data or execution truth.

### V Forge

V Forge is where coding and execution happen for a project like GoingBulk after Project V handoff.

V Forge would own:

- implementation truth;
- coding/build work;
- content graph of what was built;
- pages;
- entities;
- internal links;
- schema usage;
- publication continuity;
- execution findings.

### VEDA

VEDA would observe GoingBulk's external reality after GoingBulk has public surfaces.

VEDA may observe:

- search performance;
- SERP data;
- Search Console data;
- GA4 data;
- YouTube data;
- AI citations/mentions;
- external platform signals.

VEDA should not own GoingBulk's internal content graph or health data.

### VEDA Strategy

VEDA Strategy may derive opportunity intelligence from VEDA signal.

Examples:

- content gaps;
- SEO/GEO opportunities;
- competitor patterns;
- AI citation opportunities;
- topic clusters.

It should not own planning decisions or execution state.

## GoingBulk Truth Domain

GoingBulk owns the measured reality of the brand.

This includes:

- nutrition imports and logs;
- workout sessions and exercise sets;
- body metrics;
- supplement logs;
- bloodwork summaries/results;
- DEXA results;
- device and wearable readings;
- progress photos;
- experiment protocols/results;
- product usage windows;
- product review source data;
- sponsor/affiliate records specific to GoingBulk.

## Strong Boundary Sentence

```text
GoingBulk owns the measured reality.
V Forge owns the built representation.
VEDA owns external observations.
Project V owns the plan.
```

## Physical Storage vs Ownership

A future implementation may use:

- a separate GoingBulk database;
- a separate GoingBulk schema inside a shared Postgres instance;
- a hybrid model where V Forge owns content graph state and GoingBulk owns runtime health data.

The important rule:

```text
Storage location does not define ownership.
Truth domain defines ownership.
```

## Recommended Working Boundary

The clean working model is:

```text
GoingBulk DB/schema:
  raw and normalized health, fitness, product, experiment, and dashboard data

V Forge:
  content graph, built pages, internal links, schema records, publication state

Project V:
  planning, decisions, readiness, handoffs, roadmap

VEDA:
  external signal and observability
```

## MCP/API Access Posture

Future LLM or VedaOps access to GoingBulk should happen through governed APIs or MCP tools.

The LLM should not directly query GoingBulk tables.

Correct pattern:

```text
LLM intent
-> MCP/tool wrapper
-> GoingBulk API
-> GoingBulk database/schema
```

Potential tools:

```text
get_active_experiments
get_recent_health_summary
compare_experiment_periods
get_product_review_status
get_public_dashboard_summary
get_content_publication_state
```

## Pre-Intake Status

These docs are not VedaOps doctrine.

They are GoingBulk planning documents that may later be used as input for:

- Project V intake;
- Project V planning;
- V Forge handoff preparation;
- GoingBulk implementation planning.

## Non-Goals

GoingBulk should not become:

- a shadow VEDA;
- a shadow V Forge;
- a shadow Project V;
- a blended database containing unrelated ecosystem truth;
- a general-purpose data aggregator for all VedaOps projects.

## Practical Rule

When uncertain, ask:

```text
Does this data answer what happened in the body/product/experiment?
If yes, GoingBulk probably owns it.

Does this data answer what page/entity/schema/link was built?
If yes, V Forge probably owns it.

Does this data answer what external platforms observed?
If yes, VEDA probably owns it.

Does this data answer what should be done next?
If yes, Project V probably owns it.
```

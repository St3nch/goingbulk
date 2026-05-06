# GoingBulk LLM Partner Operating Model

## Purpose

GoingBulk will eventually use an LLM assistant as a project partner.

The assistant should understand the brand, data model, experiments, content graph, product reviews, sponsor rules, and publication state.

The LLM should help operate the system, but it should not become the source of truth.

## Core Principle

```text
The database and governed APIs are the source of truth.
The LLM is the interpreter, analyst, assistant, and drafting partner.
```

## Main Roles

### Data Analyst

The LLM can help answer:

- what changed this week?
- what changed during this supplement window?
- what metrics support or weaken an experiment result?
- what confounders are present?
- what looks unusual?
- what should be summarized for the public dashboard?

### Content Partner

The LLM can draft:

- experiment reports;
- YouTube scripts;
- short-form hooks;
- X threads;
- newsletter updates;
- product review drafts;
- monthly reports;
- professional summaries.

### Site Architecture Assistant

The LLM can suggest:

- missing entity pages;
- internal link opportunities;
- schema updates;
- stale pages;
- content gaps;
- related experiment links;
- citation-ready summaries.

### Claim Safety Assistant

The LLM can flag wording that overclaims.

Examples:

Bad:

```text
This supplement lowered my blood pressure.
```

Better:

```text
My average blood pressure was lower during this period, but this N=1 experiment does not prove the supplement caused the change.
```

### Sponsor/Product Assistant

The LLM can help prepare:

- sponsor-ready summaries;
- review pages;
- disclosure checks;
- product usage summaries;
- affiliate page updates;
- data confidence notes.

## Access Pattern

The LLM, connected agents, MCP tools, automation systems, or external assistants must not directly query Supabase/Postgres or otherwise act as database clients.

Correct pattern:

```text
LLM or agent intent
-> governed tool/API client
-> GoingBulk API
-> Supabase/Postgres
```

Forbidden pattern:

```text
LLM or agent
-> direct Supabase SQL/Postgres access
```

The API is the enforcement layer for:

- authentication;
- authorization;
- visibility rules;
- public/professional/private boundaries;
- validation;
- write permissions;
- audit/event logging;
- source/confidence handling;
- approval-sensitive operations.

This mirrors the VedaOps MCP posture: tools are transport, agents are bounded callers, and the API is the enforcement layer.

## Suggested API/Tool Surface

Read tools:

```text
get_recent_health_summary
get_daily_log_summary
get_active_experiments
get_experiment_detail
compare_date_ranges
get_supplement_usage_window
get_product_review_status
get_public_dashboard_summary
get_page_graph
get_entity_detail
get_internal_link_opportunities
get_schema_status
```

Draft/recommendation tools:

```text
draft_weekly_report
suggest_content_from_recent_data
suggest_internal_links
suggest_schema_for_page
prepare_product_review_draft
prepare_experiment_summary
check_claim_risk
```

Write tools should be limited and approval-aware.

## Human Approval

The LLM should not publish, approve, or mutate sensitive state without human approval.

Approval-sensitive actions include:

- publishing a page;
- changing public bloodwork interpretation;
- approving sponsor claims;
- changing experiment verdicts;
- creating or activating affiliate links;
- changing medical/health disclaimers;
- deleting records;
- importing data without review if anomalies exist.

## Public vs Private Assistant

### Internal Assistant

Private assistant can access broader internal data through approved APIs.

It may help with:

- planning;
- content drafting;
- data analysis;
- import review;
- sponsor prep;
- VedaOps handoff context.

### Public Assistant

A future public site chatbot should only access:

- published pages;
- public dashboard summaries;
- public experiment reports;
- approved product/review information;
- public methodology and disclaimers.

It should not access:

- private raw logs;
- unpublished bloodwork;
- sponsor negotiations;
- private notes;
- unapproved drafts;
- admin-only records.

## Memory Model

The LLM should rely on structured records, not vague memory.

Useful durable records:

```text
brand rules
claim rules
experiment protocols
data confidence definitions
page summaries
entity definitions
sponsorship policy
public/private visibility rules
```

## Claim Rules

GoingBulk should maintain a claim safety rule set.

Example:

```text
Do not claim causation from N=1 data.
Use associated with, during, changed while, or my data showed instead of caused, cured, fixed, or proven.
```

## Weekly Operator Flow

A future weekly LLM workflow could be:

```text
1. Read latest nutrition, workout, supplement, body, and device summaries.
2. Compare against current goals and active experiments.
3. Flag anomalies and confounders.
4. Generate weekly public summary.
5. Suggest social content.
6. Suggest internal links or page updates.
7. Check claim wording.
8. Prepare draft report for human review.
```

## VedaOps Context

When integrated with VedaOps:

- Project V should own formal planning and decisions;
- V Forge should own execution/coding/content graph work;
- VEDA should own external observations;
- GoingBulk should expose bounded APIs for its own measured reality and runtime data.

The LLM should respect those boundaries.

## Do Not Let The LLM

- invent missing data;
- silently correct records;
- make medical claims;
- publish unreviewed health interpretations;
- treat N=1 results as universal proof;
- bypass approval;
- merge VedaOps truth domains;
- expose private data publicly;
- use drama framing when reviewing claims.

## Core Rule

```text
The LLM can help find, explain, draft, compare, and recommend.
The LLM should not be the unchecked authority that decides, publishes, or rewrites truth.
```

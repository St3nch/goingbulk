# GoingBulk Content Model and Page Types

## Purpose

This document defines how GoingBulk should manage content, pages, entities, reports, datasets, and long-form writing.

GoingBulk should not be structured like a simple blog. It should be structured as an entity-first content system with wiki-style pages, experiment reports, data pages, product/service reviews, methodology pages, and topical hubs.

## Core Principle

```text
Content is not just prose.
Content is a structured representation of entities, data, experiments, products, methods, and decisions.
```

## Recommended Content Model

GoingBulk should use a hybrid content model.

```text
Structured metadata in Postgres
+ long-form content in MDX or rich content blocks
+ entity/page relationships in the database
+ generated schema and internal link records
```

This gives GoingBulk both editorial flexibility and machine-readable structure.

## Why Hybrid

### MDX Strengths

MDX is good for:

- human-written essays;
- methodology pages;
- glossary/wikistyle pages;
- experiment narrative;
- custom embedded charts/components;
- version-controlled content;
- fast static rendering.

### Database Content Strengths

Database-backed content is good for:

- page metadata;
- entity records;
- internal links;
- schema records;
- product review status;
- affiliate disclosures;
- experiment statuses;
- dataset metadata;
- admin-managed content;
- LLM-readable summaries.

### Recommended Hybrid Rule

Use the database for structure and state.
Use MDX or structured content blocks for long-form human explanation.

## Core Page Types

### Hub Page

Purpose: organize a topical cluster.

Examples:

```text
/nutrition
/training
/supplements
/body-composition
/bloodwork
/devices
/products
/experiments
/glossary
```

Required elements:

- topic summary;
- core entities;
- related experiments;
- related products/services;
- latest reports;
- methodology links;
- data links;
- internal links to child pages.

### Entity Page

Purpose: canonical record for an important thing.

Examples:

```text
/supplements/creatine
/devices/hume-pod
/body-composition/dexa
/glossary/training-volume
```

Required elements:

- definition;
- why it matters to GoingBulk;
- related experiments;
- related products/services;
- related metrics;
- source/confidence context;
- internal links;
- schema.

### Experiment Page

Purpose: report a structured N=1 experiment.

Required elements:

- question/claim;
- source/research context;
- protocol;
- baseline;
- intervention;
- follow-up when relevant;
- results;
- confounders;
- limitations;
- verdict;
- related data page;
- related products/entities;
- N=1 disclaimer.

### Dataset Page

Purpose: make important data citeable and exportable.

Required elements:

- dataset name;
- description;
- date range;
- variables/columns;
- data sources;
- methodology;
- confidence labels;
- summary table;
- export links;
- limitations;
- Dataset schema.

### Product Review Page

Purpose: review a product or service with disclosure and data context.

Required elements:

- product/service summary;
- disclosure;
- usage dates;
- usage protocol;
- data context;
- subjective experience;
- pros/cons;
- limitations;
- verdict;
- would-use-if-not-paid answer;
- affiliate link where applicable.

### Methodology Page

Purpose: explain how GoingBulk collects or evaluates data.

Examples:

```text
/methodology/nutrition-logging
/methodology/workout-logging
/methodology/body-composition-tracking
/methodology/data-confidence-labels
```

Required elements:

- method summary;
- source/device/tool used;
- conditions;
- confidence level;
- limitations;
- related metrics;
- related experiments.

### Glossary/Wiki Page

Purpose: explain a concept in a concise, linkable way.

Examples:

```text
/glossary/n-of-1-experiment
/glossary/confounder
/glossary/training-volume
```

Required elements:

- definition;
- plain-language explanation;
- GoingBulk-specific usage;
- related entities/pages;
- examples.

### Report Page

Purpose: summarize a time period.

Examples:

```text
/reports/weekly/2027-01-07
/reports/monthly/2027-01
/reports/quarterly/2027-q1
```

Required elements:

- period summary;
- nutrition summary;
- training summary;
- body metrics;
- supplement adherence;
- active experiments;
- confounders;
- lessons;
- related pages;
- charts/tables.

## Page Metadata Fields

Each page should have structured metadata.

```text
id
title
slug
url
page_type
status
audience
primary_entity_id
meta_title
meta_description
canonical_url
llm_summary
quick_facts
schema_type
visibility
published_at
updated_at
created_at
```

## Content Statuses

Suggested statuses:

```text
draft
in_review
approved
published
needs_update
archived
```

## Audience Modes

Pages may target:

```text
general
professional
admin
sponsor
llm/crawler
```

This does not mean separate pages always exist. It means the content model should support different levels of detail.

## Long-Form Content Storage Options

### Option A: MDX Files

Good for:

- version control;
- developer-friendly editing;
- static generation;
- custom components.

Weakness:

- harder for admin dashboard editing;
- needs metadata sync with database.

### Option B: Database Rich Content Blocks

Good for:

- admin editing;
- dynamic publishing;
- workflow status;
- LLM review tools.

Weakness:

- more implementation work;
- harder to version cleanly unless explicitly designed.

### Option C: Hybrid

Recommended.

Use MDX for foundational editorial pages and database records for structured content metadata, reports, experiments, products, and entities.

## Required Page Blocks

Reusable page blocks:

```text
Quick Facts
Citation Summary
Data Sources
Confidence Label
Limitations
Related Entities
Related Experiments
Related Products
Methodology Note
Affiliate Disclosure
N=1 Disclaimer
Key Metrics Table
Interactive Table
Export Links
```

## LLM Readability

Every major page should include:

- summary near the top;
- Quick Facts;
- citation summary;
- clear headings;
- source/confidence labels;
- limitations;
- related canonical links.

Do not make important meaning exist only inside charts or interactive components.

## Internal Link Requirements

Each page should connect to:

- parent hub;
- primary entity;
- related methodology;
- related glossary terms;
- related experiments;
- related products/services when relevant;
- related data pages.

## Content Governance Questions

Open questions:

- Should foundational pages start in MDX and later move to a CMS?
- Should admin users edit long-form reports in the dashboard?
- Should V Forge eventually own page/content graph records?
- How should published content be versioned?
- How should AI-generated drafts be marked before approval?

## Core Rule

```text
Every public page should be useful to humans, legible to machines, connected to entities, and honest about its data sources.
```

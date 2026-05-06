# GoingBulk Entity SEO/GEO Architecture

## Purpose

GoingBulk should be built as an entity-structured website, not just a blog.

The goal is to be useful to humans while also being machine-readable for search engines, AI answer engines, LLM citation systems, and future VedaOps/V Forge workflows.

## Core Principle

```text
Humans need clear pages.
Machines need explicit entities, relationships, schema, summaries, and stable URLs.
```

## Main Entity Types

GoingBulk should model important concepts as entities.

Examples:

```text
Person
Brand
Dataset
Experiment
Claim
Study
Supplement
Product
Workout Program
Exercise
Food
Meal
Metric
Blood Marker
Device
Lab Test
Review
Page
Internal Link
Schema Record
```

## Canonical Pages

Important entities should have canonical pages.

Examples:

```text
/supplements/creatine
/experiments/hume-vs-dexa-12-week-comparison
/products/hume-pod-review
/bloodwork/hba1c
/glossary/training-volume
/methodology/blood-pressure-measurement
```

## Recommended URL Structure

```text
/
/about
/dashboard
/data
/data-dictionary
/methodology
/experiments
/experiments/[slug]
/claims
/claims/[slug]
/supplements
/supplements/[slug]
/products
/products/[slug]
/workouts
/workouts/[program-slug]
/exercises
/exercises/[slug]
/bloodwork
/bloodwork/[marker-slug]
/devices
/devices/[slug]
/glossary
/glossary/[term-slug]
/for-professionals
/sponsorship-policy
/affiliate-disclosure
/roadmap
```

## Content Graph

GoingBulk should connect related entities clearly.

Example:

```text
Creatine
-> supplement page
-> product reviews
-> creatine experiment
-> training volume metrics
-> bodyweight trend
-> bloodwork marker: creatinine
-> methodology: supplement tracking
```

## Page Metadata

Each page should store metadata such as:

```text
id
title
slug
url
page_type
status
audience
primary_entity_id
secondary_entities
meta_title
meta_description
canonical_url
llm_summary
quick_facts
schema_type
published_at
updated_at
```

## Entity Metadata

Each entity should store:

```text
id
name
slug
entity_type
description
canonical_url
schema_type
same_as_links
status
llm_definition
```

## Internal Links

Internal links should be stored or at least inspectable.

Useful fields:

```text
source_page_id
target_page_id
anchor_text
context
link_type
status
```

The LLM/V Forge should eventually be able to answer:

```text
What pages should link to this new experiment?
What canonical entity page is missing?
Which pages mention creatine but do not link to /supplements/creatine?
```

## Schema Strategy

Use JSON-LD for structured data.

Potential schema types:

```text
WebSite
Organization
Person
WebPage
Article
Dataset
Product
Review
ItemList
BreadcrumbList
FAQPage only when real FAQs exist
MedicalWebPage only with caution
MedicalTest only when appropriate
DietarySupplement where appropriate
```

Schema must match visible page content.

Do not use fake ratings, fake reviews, invisible claims, or unsupported medical claims.

## LLM Citation Readiness

Major pages should include citation-ready sections.

Examples:

```text
Quick Facts
Methodology Summary
Data Sources
Limitations
Suggested Citation
Last Updated
```

LLMs and answer engines need crawlable text, not just charts.

Every chart should have a plain-text summary near it.

Bad:

```text
interactive chart only
```

Good:

```text
From May 1 to May 30, average daily protein intake was 186g, average calories were 2,780 kcal, and bodyweight increased from 184.2 lb to 187.1 lb.
```

## Normal View and Expert View

Major pages should support two levels:

### Normal View

- simple summary;
- visual charts;
- practical takeaways;
- verdicts;
- plain language.

### Expert View

- date ranges;
- methods;
- sources;
- confidence labels;
- confounders;
- raw/summary data;
- limitations;
- schema/citation details.

## Important Evergreen Pages

GoingBulk should eventually include:

```text
/methodology
/data-dictionary
/for-professionals
/sponsorship-policy
/affiliate-disclosure
/experiments
/supplements
/products
/bloodwork
/devices
/glossary
```

These pages support trust, search visibility, and machine understanding.

## SEO/GEO Content Types

### Entity Pages

Examples:

- creatine;
- Hume Pod;
- DEXA scan;
- training volume;
- HbA1c.

### Experiment Reports

Examples:

- Hume vs DEXA 12-week comparison;
- 90-day creatine protocol;
- 12-week hypertrophy block.

### Product Data Reviews

Examples:

- Hume Pod review;
- protein powder review;
- training app review.

### Monthly/Quarterly Reports

Examples:

- GoingBulk June 2026 Report;
- GoingBulk Q3 Health and Fitness Report.

## Data Dictionary

Define terms clearly.

Examples:

```text
Training volume = sets x reps x load
Protein target hit rate = days meeting protein target / total days
Supplement adherence = logged doses taken / planned doses
Hume-estimated body fat = body fat estimate from Hume device, not clinical measurement
```

## Avoid

- important content hidden only in JavaScript charts;
- infinite scroll for core pages;
- login walls for public reports;
- thin AI-generated glossary spam;
- unsupported schema;
- fake review/rating markup;
- medical claims without appropriate framing;
- orphan pages with no internal links.

## Core Rule

```text
Every important claim, experiment, product, metric, and page should be connected to an entity and a canonical URL.
```

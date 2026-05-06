# GoingBulk SEO, GEO, and LLM Citation Strategy

## Purpose

This document defines how GoingBulk should be structured to maximize long-term SEO, GEO, AI answer visibility, LLM citation potential, and SERP performance.

GoingBulk should not be built like a normal blog.

GoingBulk should be built as a public, entity-structured, data-backed fitness and health knowledge graph.

## Core Strategy

```text
Entity-first architecture
+ topical hubs
+ experiment reports
+ dataset pages
+ methodology pages
+ product/service review graph
+ wiki/glossary layer
+ server-rendered summaries
+ schema
+ exportable data
+ strong internal links
+ original first-party data
```

The goal is to make GoingBulk understandable to:

- humans;
- doctors and nutritionists;
- search engines;
- AI answer engines;
- LLM crawlers;
- future VedaOps/V Forge tooling;
- sponsors and product partners.

## Core Positioning

GoingBulk should be positioned as:

```text
A data-backed, entity-first, experiment-driven fitness knowledge graph.
```

Not:

```text
A fitness blog with charts.
```

The moat is original first-party data.

GoingBulk can publish:

- nutrition logs;
- workout logs;
- DEXA results;
- bloodwork summaries;
- Hume/wearable comparisons;
- supplement usage windows;
- product usage records;
- experiment protocols;
- confounder logs;
- monthly reports;
- quarterly reports.

Most fitness websites summarize studies. GoingBulk can publish structured personal data and receipts.

## Page Type System

GoingBulk should use explicit page types.

### Hub Pages

Hub pages organize major topical clusters.

Examples:

```text
/nutrition
/training
/supplements
/body-composition
/bloodwork
/devices
/experiments
/products
/services
/glossary
/for-professionals
```

Hub pages should link to:

- core entity pages;
- experiment reports;
- product/service reviews;
- methodology pages;
- data pages;
- glossary pages;
- reports;
- professional explorer views where appropriate.

### Entity Pages

Entity pages are canonical records for important things.

Examples:

```text
/supplements/creatine
/devices/hume-pod
/body-composition/dexa
/bloodwork/hba1c
/glossary/training-volume
/products/hume-pod-review
```

Each entity page should answer:

```text
What is it?
Why does it matter to GoingBulk?
What data exists for it?
What experiments involve it?
What products/services involve it?
What claims connect to it?
What methodology applies?
What should the reader visit next?
```

### Experiment Pages

Experiment pages are core SEO/GEO assets.

Examples:

```text
/experiments/baseline-30-days
/experiments/creatine-90-day-test
/experiments/hume-vs-dexa-12-week-comparison
```

Each experiment should include:

- claim or question;
- source/research review;
- protocol;
- baseline;
- intervention;
- follow-up when useful;
- results;
- confounders;
- limitations;
- verdict;
- key metrics table;
- charts;
- exports;
- schema.

### Dataset Pages

Dataset pages should make important data citeable.

Examples:

```text
/data/baseline-30-days
/data/hume-vs-dexa-12-week-comparison
/data/creatine-90-day-test
/data/bloodwork-q1-2027
```

Each dataset page should include:

- dataset name;
- description;
- creator;
- date range;
- variables/columns;
- source systems;
- methodology;
- confidence labels;
- download/export links;
- limitations;
- related experiment;
- Dataset schema.

### Product and Service Review Pages

Product and service pages connect monetization to evidence.

Examples:

```text
/products/hume-pod-review
/services/cronometer-review
/products/brand-x-creatine-review
```

Each review should include:

- disclosure;
- usage dates;
- affiliate/sponsor status;
- data context;
- subjective experience;
- measurable context;
- limitations;
- cost/value;
- verdict;
- would-use-if-not-paid answer;
- related experiments;
- schema.

### Methodology Pages

Methodology pages support trust, expert review, and LLM citations.

Examples:

```text
/methodology/nutrition-logging
/methodology/supplement-tracking
/methodology/body-composition-tracking
/methodology/blood-pressure-measurement
/methodology/workout-logging
/methodology/data-confidence-labels
```

### Glossary/Wiki Pages

Glossary pages support topical depth and internal linking.

Examples:

```text
/glossary/n-of-1-experiment
/glossary/confounder
/glossary/training-volume
/glossary/protein-target-hit-rate
/glossary/baseline-period
/glossary/intervention-period
```

Glossary pages should be useful and connected, not thin AI spam.

## Standard Page Structure

Every important page should follow a predictable structure:

```text
1. Clear title
2. Two-to-four sentence answer or summary
3. Quick Facts block
4. Main explanation
5. GoingBulk-specific data/context
6. Key table or chart summary
7. Source and confidence labels
8. Limitations
9. Related entities/pages
10. JSON-LD schema where appropriate
11. Last updated date
```

## LLM Citation Blocks

Major pages should include a citation-ready summary.

Example:

```text
Citation Summary

GoingBulk's 90-Day Creatine Test was an N=1 personal experiment conducted from [start date] to [end date]. The experiment tracked daily creatine use, bodyweight, workout volume, nutrition, sleep, and confounders. The results showed [summary], but the experiment does not prove causation and should not be treated as clinical evidence.
```

Citation summaries should be:

- short;
- factual;
- date-specific;
- source-labeled;
- limitation-aware;
- easy to quote;
- free from hype.

## Quick Facts Blocks

Every major entity, experiment, product, dataset, or report page should include Quick Facts.

Example:

```text
Quick Facts

Experiment: Hume vs DEXA 12-Week Comparison
Type: N=1 personal experiment
Dates: TBD
Primary metrics: body fat estimate, lean mass estimate, bodyweight, waist measurement
Data sources: Hume Pod, DEXA scan, bodyweight logs, progress photos
Confidence: Medium
Limitations: BIA noise, hydration effects, N=1 design, training and nutrition changes
```

Quick Facts blocks are valuable for:

- humans;
- search snippets;
- AI answer extraction;
- LLM citations;
- internal summaries;
- future VedaOps/V Forge tooling.

## Table Readability Strategy

Interactive tables should not be the only place important data exists.

For important public or professional data tables, include:

```text
plain-language summary
Quick Facts block
server-rendered HTML key table
source/confidence notes
interactive TanStack table
export/download link
related entity links
schema where appropriate
```

### HTML Summary Table Example

```text
Metric | Baseline | Intervention | Change
Bodyweight | 184.2 lb | 187.8 lb | +3.6 lb
Protein | 182g/day | 194g/day | +12g/day
Training Volume | 42,300 lb/week | 47,800 lb/week | +13%
```

The summary table is for SEO/GEO/LLM readability.

The interactive table is for human exploration.

## Canonical vs Exploratory URLs

Not every filtered view should be indexed.

### Indexable Canonical Pages

Examples:

```text
/experiments/creatine-90-day-test
/experiments/creatine-90-day-test/data
/supplements/creatine
/products/hume-pod-review
/body-composition/hume-vs-dexa
/bloodwork/q1-2027-summary
```

### Noindex Exploratory Views

Examples:

```text
/pro/data-explorer?protein_min=180&sleep_max=6
/pro/data-explorer?exclude=illness,travel
```

Use URL state for sharing and saved views, but avoid allowing infinite filter combinations to become crawlable index pages.

## Schema Strategy

Use JSON-LD honestly and consistently.

### Sitewide Schema

```text
WebSite
Organization
Person
BreadcrumbList
```

### Experiment Pages

```text
Article
Dataset
WebPage
BreadcrumbList
```

### Dataset Pages

```text
Dataset
DataDownload
DataCatalog later if useful
```

### Product Pages

```text
Product
Review
Brand
Offer only if price/availability is maintained
BreadcrumbList
```

### Glossary and Methodology Pages

```text
DefinedTerm where useful
Article
WebPage
FAQPage only when real FAQs exist
```

## Schema Rules

Do:

- match schema to visible page content;
- include source and date context;
- use Dataset schema for real datasets;
- use Product/Review schema only for real reviews;
- validate schema;
- keep schema updated.

Do not:

- create hidden claims in schema;
- fake ratings;
- fake reviews;
- mark up unavailable offers as current;
- use medical schema casually;
- use FAQ schema for fake FAQ spam.

## Internal Linking Strategy

GoingBulk should use rule-based internal linking.

### Experiment Pages Link To

```text
primary entity
related supplement/product/service
methodology page
data page
glossary terms
professional explorer view when appropriate
related experiments
```

### Product Pages Link To

```text
product entity
brand entity
related experiment
related supplement/ingredient
usage window
affiliate disclosure
methodology
```

### Hub Pages Link To

```text
core entities
top experiments
top products/services
top methodology pages
latest reports
related glossary terms
```

### Glossary Pages Link To

```text
methodology pages
experiments that use the term
related metrics
related entities
```

Avoid orphan pages.

## Dataset SEO Strategy

GoingBulk should eventually have a dataset catalog.

Example:

```text
/data
/data/nutrition-baseline-2027
/data/hume-vs-dexa-2027
/data/creatine-90-day-test
/data/bloodwork-q1-2027
```

Each dataset should include:

- description;
- date range;
- creator;
- fields/columns;
- source systems;
- methodology;
- confidence labels;
- limitations;
- related pages;
- download/export options;
- Dataset schema.

## GEO / AI Search Strategy

GEO should be treated as SEO plus extractability, entity clarity, freshness, trust, and original data.

Priorities:

### 1. Original First-Party Data

GoingBulk's strongest advantage is original personal tracking data.

### 2. Clear Answers

Each major page should answer the core question in the first few sentences.

### 3. Structured Sections

Use predictable headings:

```text
Summary
Quick Facts
Protocol
Results
Limitations
Data Sources
Verdict
Related Pages
```

### 4. Entity Consistency

Use stable names and URLs.

Examples:

```text
Creatine -> /supplements/creatine
Hume Pod -> /devices/hume-pod
DEXA Scan -> /body-composition/dexa
```

### 5. Freshness

Maintain monthly and quarterly reports.

Examples:

```text
/reports/monthly/2027-01
/reports/quarterly/2027-q1
```

### 6. YouTube/Social Integration

Videos and social posts should point back to canonical pages.

Preferred flow:

```text
YouTube video or social post
-> canonical experiment/product/data page
-> related entity pages
-> newsletter signup or affiliate action
```

## llms.txt Posture

GoingBulk may add:

```text
/llms.txt
/llms-full.txt
```

This is a low-cost future enhancement, but it should not be treated as the core GEO strategy.

The real strategy is:

```text
clear pages
strong summaries
stable entities
first-party data
schema
internal links
external citations
```

## Programmatic SEO Rule

Programmatic pages are allowed only when they are useful, entity-backed, internally linked, and enhanced by GoingBulk-specific context.

Good examples:

```text
/bloodwork/hba1c
/supplements/creatine
/glossary/training-volume
/exercises/bench-press
```

Bad examples:

```text
thin food keyword pages
near-duplicate supplement pages
AI-generated glossary filler
indexable filtered table spam
```

## Technical SEO Rules

GoingBulk should support:

- fast pages;
- server rendering or static rendering for important content;
- hydrated client components for interactive extras;
- clean URLs;
- XML sitemap;
- robots.txt;
- canonical tags;
- breadcrumbs;
- image alt text;
- Open Graph/Twitter cards;
- schema validation;
- noindex for junk/filter pages;
- redirect hygiene;
- accessible UI;
- mobile performance.

Important content should not depend only on client-side rendering.

## Authority Building

Site structure alone is not enough.

GoingBulk should earn external authority through:

- YouTube videos linking to canonical experiment pages;
- expert commentary;
- podcast appearances;
- product brands linking to reviews;
- doctors/nutritionists critiquing or discussing the data;
- dataset/report pages that others can reference;
- monthly/quarterly reports;
- original comparisons such as Hume vs DEXA.

## Build Order For SEO/GEO

### Phase 1: Foundation Pages

```text
/about
/methodology
/data-dictionary
/experiments
/supplements
/products
/affiliate-disclosure
/sponsorship-policy
/for-professionals
```

### Phase 2: First Dataset and Experiment

```text
/experiments/baseline-30-days
/data/baseline-30-days
/body-composition/dexa
/devices/hume-pod
/methodology/nutrition-logging
```

### Phase 3: Product and Device Graph

```text
/devices/hume-pod
/products/hume-pod-review
/experiments/hume-vs-dexa-12-week-comparison
/data/hume-vs-dexa-12-week-comparison
```

### Phase 4: Repeatable Reports

```text
/reports/monthly/[yyyy-mm]
/reports/quarterly/[yyyy-q]
```

### Phase 5: Professional Explorer

```text
/for-professionals/data-explorer
```

The professional explorer can be useful and shareable, but most exploratory filter states should be noindex.

## Hard Rules

### Rule 1

Every major page gets:

```text
summary
quick facts
methodology/source/confidence
related entities
schema
last updated
```

### Rule 2

Every important dataset gets:

```text
landing page
human summary
HTML key table
download/export
Dataset schema
limitations
```

### Rule 3

Every product review gets:

```text
disclosure
usage dates
data context
verdict
would-use-if-not-paid
related experiment
```

### Rule 4

Every experiment gets:

```text
claim/question
research/source
protocol
baseline
intervention
results
confounders
limitations
N=1 disclaimer
```

### Rule 5

Interactive tables never replace crawlable content.

They enhance it.

## Bottom Line

GoingBulk wins by becoming the best-structured source for its own public fitness experiments.

The goal is not to publish more content than everyone else.

The goal is to publish better-structured, data-backed, entity-connected content that is easier for humans, experts, search engines, and AI systems to trust and cite.

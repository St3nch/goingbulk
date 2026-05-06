# GoingBulk Entity-Structured Wiki and Topical Architecture

## Purpose

GoingBulk should be built as an entity-structured website, not a loose collection of blog posts.

The site may feel like a wiki in parts, but the deeper architecture should be an entity graph: people, products, supplements, experiments, metrics, claims, studies, workouts, foods, devices, services, and pages all connected by explicit relationships.

This document locks in the direction for GoingBulk's wiki-like knowledge base, topical authority structure, product/service graph, affiliate layer, and LLM/SEO/GEO-readable architecture.

## Core Idea

```text
GoingBulk is a public data brand built on an entity graph.

Every important thing gets a canonical identity.
Every important identity can connect to data, pages, experiments, products, claims, sources, and schema.
```

## Why This Matters

GoingBulk will contain a growing amount of structured information:

- tables;
- dashboards;
- nutrition data;
- training data;
- supplement logs;
- product usage;
- service usage;
- device readings;
- bloodwork;
- DEXA results;
- experiments;
- claims;
- research notes;
- affiliate links;
- sponsor disclosures;
- content pages;
- social/video references.

A normal blog structure will eventually become chaotic.

An entity-first architecture gives the site a durable backbone.

## Wiki vs Entity Graph

GoingBulk can include wiki-style pages, but it should not be only a wiki.

### Wiki Page

A wiki page explains a concept.

Example:

```text
/glossary/training-volume
```

### Entity Page

An entity page is a canonical record for a thing that may connect to data and other entities.

Example:

```text
/supplements/creatine
```

This page may connect to:

- creatine experiments;
- creatine products;
- supplement logs;
- training data;
- bodyweight trends;
- bloodwork marker: creatinine;
- research claims;
- product reviews;
- affiliate links;
- schema records.

The entity page is more powerful than a basic wiki page.

## Core Architecture Sentence

```text
GoingBulk should operate like a data-backed wiki where every important topic is an entity, every entity has relationships, and important claims connect back to evidence or personal data.
```

## Main Entity Types

### Brand and Identity Entities

```text
GoingBulk
creator/person
public dataset
project phase
content series
```

### Health and Fitness Entities

```text
bodyweight
body fat percentage
lean mass
waist measurement
blood pressure
fasting glucose
HbA1c
LDL-C
HDL-C
triglycerides
resting heart rate
HRV
sleep duration
training volume
estimated 1RM
```

### Nutrition Entities

```text
food
meal
macro
micronutrient
protein target
fiber target
sodium intake
calorie target
Cronometer import
```

### Training Entities

```text
workout program
program phase
workout template
exercise
muscle group
movement pattern
set
rep
load
RPE
rest time
```

### Supplement and Product Entities

```text
supplement ingredient
supplement category
specific product
brand
serving/dose
product usage window
review
affiliate link
sponsor relationship
```

### Device and Lab Entities

```text
Hume Pod
Hume Band
Samsung Watch
DEXA scan
blood lab
blood pressure cuff
CGM
measurement method
source confidence level
```

### Claim and Research Entities

```text
claim
study
paper
research source
intervention
outcome metric
effect size
limitations
N=1 experiment
```

### Content Entities

```text
page
article
experiment report
YouTube video
short-form clip
newsletter issue
social post
monthly report
quarterly report
```

### Commercial Entities

```text
product
service
affiliate offer
sponsor
merchant
subscription
coupon/code
review verdict
would-use-if-not-paid status
```

## Topical Architecture

SEO terminology may vary, but the useful idea is topical structure.

GoingBulk should organize content into topical hubs and supporting pages.

Think:

```text
Topic Hub
-> Entity Pages
-> Experiment Pages
-> Product/Service Pages
-> Data Pages
-> Methodology Pages
-> Glossary/Wiki Pages
```

## Major Topical Hubs

### Nutrition Hub

```text
/nutrition
/nutrition/protein
/nutrition/fiber
/nutrition/sodium
/nutrition/calories
/nutrition/cronometer-imports
/nutrition/high-protein-meals
```

Connects to:

- food logs;
- Cronometer imports;
- meal templates;
- nutrition experiments;
- product reviews;
- bloodwork context.

### Training Hub

```text
/training
/training/programs
/training/volume
/training/exercises
/training/progression
/training/12-week-hypertrophy-block
```

Connects to:

- workout programs;
- exercise entities;
- exercise set logs;
- strength trends;
- training experiments;
- supplement experiments.

### Supplements Hub

```text
/supplements
/supplements/creatine
/supplements/whey-protein
/supplements/caffeine
/supplements/magnesium
```

Connects to:

- supplement logs;
- product reviews;
- ingredient pages;
- research claims;
- experiments;
- affiliate links;
- sponsor disclosures.

### Body Composition Hub

```text
/body-composition
/body-composition/dexa
/body-composition/hume-vs-dexa
/body-composition/bodyweight
/body-composition/waist-measurement
```

Connects to:

- DEXA results;
- Hume readings;
- progress photos;
- body metrics;
- training phases;
- nutrition phases.

### Bloodwork and Biomarkers Hub

```text
/bloodwork
/bloodwork/glucose
/bloodwork/hba1c
/bloodwork/lipids
/bloodwork/vitamin-d
/bloodwork/testosterone
```

Connects to:

- lab results;
- nutrition context;
- supplement windows;
- bodyweight trends;
- professional notes;
- methodology.

### Devices and Services Hub

```text
/devices
/devices/hume-pod
/devices/hume-band
/devices/samsung-watch
/services
/services/cronometer
/services/dexa-scan-provider
/services/bloodwork-provider
```

Connects to:

- product reviews;
- service reviews;
- affiliate links;
- data source records;
- comparison experiments;
- methodology.

### Experiments Hub

```text
/experiments
/experiments/baseline-30-days
/experiments/hume-vs-dexa-12-week-comparison
/experiments/creatine-90-day-test
/experiments/high-protein-bulk
```

Connects to:

- claims;
- research;
- products;
- supplements;
- data tables;
- dashboards;
- source/confidence labels.

### Product Reviews Hub

```text
/products
/products/hume-pod-review
/products/brand-x-creatine-review
/products/protein-powder-review
```

Connects to:

- product entity;
- brand entity;
- supplement ingredient;
- usage window;
- affiliate link;
- sponsor disclosure;
- experiment data;
- verdict.

### Wiki / Glossary Hub

```text
/glossary
/glossary/n-of-1-experiment
/glossary/training-volume
/glossary/confounder
/glossary/adherence
/glossary/baseline-period
/glossary/intervention-period
```

Connects to:

- methodology pages;
- experiment pages;
- professional explorer;
- data dictionary;
- entity pages.

## Hub and Spoke Model

Each major topic should have a hub page.

Each hub page should link to:

- core entity pages;
- related experiments;
- related products/services;
- methodology pages;
- glossary pages;
- dashboards;
- reports.

Example:

```text
/supplements
  -> /supplements/creatine
  -> /products/brand-x-creatine-review
  -> /experiments/creatine-90-day-test
  -> /methodology/supplement-tracking
  -> /glossary/supplement-adherence
```

## Entity Relationship Examples

### Creatine

```text
Entity: Creatine
Type: Supplement ingredient
Canonical URL: /supplements/creatine
Related products: Brand X Creatine, Brand Y Creatine
Related experiments: 90-Day Creatine Test
Related metrics: bodyweight, training volume, strength, creatinine
Related pages: supplement tracking methodology, product reviews, glossary terms
Commercial links: affiliate products where applicable
```

### Hume Pod

```text
Entity: Hume Pod
Type: Device/product
Canonical URL: /devices/hume-pod
Related experiment: Hume vs DEXA 12-week comparison
Related metrics: bodyweight, body fat estimate, lean mass estimate
Related method: BIA estimate
Related product review: /products/hume-pod-review
Commercial links: affiliate link if used
```

### DEXA Scan

```text
Entity: DEXA Scan
Type: Lab/body composition method
Canonical URL: /body-composition/dexa
Related experiment: Hume vs DEXA
Related metrics: body fat percentage, lean mass, fat mass, bone density
Related service: DEXA provider if reviewed
Confidence: high relative to consumer device trend data
```

### Training Volume

```text
Entity: Training Volume
Type: Metric/glossary concept
Canonical URL: /glossary/training-volume
Formula: sets x reps x load
Related data: workout logs, exercise sets, program blocks
Related experiments: creatine test, hypertrophy block
```

## Data Table Readability For SEO/GEO/LLMs

Important table data should not exist only inside an interactive client-side table.

For important public and professional pages, include:

1. plain-language summary;
2. Quick Facts block;
3. small server-rendered HTML summary table;
4. source and confidence notes;
5. interactive table below;
6. export links where appropriate;
7. related entity links;
8. JSON-LD schema when appropriate.

## Canonical vs Exploratory Pages

Not every filtered view should be indexed.

### Canonical Pages

These can be indexable:

```text
/experiments/creatine-90-day-test
/experiments/creatine-90-day-test/data
/supplements/creatine
/products/hume-pod-review
/body-composition/hume-vs-dexa
/bloodwork/q1-2027-summary
```

### Exploratory Filter Views

These should usually be noindex:

```text
/pro/data-explorer?protein_min=180&sleep_max=6
/pro/data-explorer?exclude=illness,travel
```

Use URL state for sharing and saved views, but avoid creating infinite crawlable filter combinations.

## Schema Strategy

Use JSON-LD to describe important pages and entities.

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
MedicalWebPage with caution
MedicalTest with caution
DietarySupplement where appropriate
```

Schema must match visible content.

Do not use schema to make hidden claims.

## Affiliate and Product Graph

Products and services should be first-class entities.

Each product/service can connect to:

- brand;
- category;
- product type;
- supplement ingredient if applicable;
- usage windows;
- experiments;
- review page;
- affiliate links;
- sponsor relationship;
- verdict;
- would-use-if-not-paid status.

This supports both monetization and trust.

## Content Types

GoingBulk should support these content types:

```text
entity page
hub page
experiment report
product review
service review
methodology page
data page
glossary/wiki page
monthly report
quarterly report
professional report
social/video reference page
```

## Entity Database Concepts

Potential tables:

```text
entities
entity_relationships
pages
page_entities
internal_links
schema_records
products
services
affiliate_links
experiments
experiment_entities
claims
claim_sources
metrics
metric_sources
```

## Internal Link Rules

Every important page should link to:

- its parent hub;
- its primary entity;
- related experiments;
- related methodology;
- related glossary definitions;
- related products/services where relevant;
- related data/dashboard pages.

Avoid orphan pages.

## Naming Rule

Use stable, boring, descriptive URLs.

Good:

```text
/supplements/creatine
/experiments/hume-vs-dexa-12-week-comparison
/glossary/training-volume
```

Bad:

```text
/blog/this-one-weird-thing
/post?id=123
/creatine-results-wow
```

## Long-Term Vision

GoingBulk should become a data-backed knowledge graph around one person's public fitness and health transformation.

The site should answer:

```text
What was tested?
What was used?
What changed?
What data supports that?
What limitations exist?
What products/services were involved?
What pages and entities are related?
```

## Core Rule

```text
If something matters to the brand, data, experiments, products, or claims, make it an entity and connect it.
```

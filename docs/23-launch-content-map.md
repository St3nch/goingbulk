# GoingBulk Launch Content Map

## Purpose

This document defines the initial public content map for GoingBulk.

This document has been revised after the Claude audit. The original launch map was too large for an MVP and has been tightened to support the revised MVP scope.

## Launch Content Goal

The first public version should answer:

```text
What is GoingBulk?
Who is behind it?
How is data collected?
What is being tracked first?
What is the baseline experiment?
What data is public?
What are the limitations?
Why is this not medical advice?
```

The first launch does not need to answer every future product, service, professional, device, lab, SEO, and entity-graph question.

## MVP Launch Page Set

These are launch blockers:

```text
/
/about
/experiments/baseline-30-days
/experiments/baseline-30-days/pre-registration
/data/baseline-30-days
/methodology
/methodology/changelog
/medical-disclaimer
/affiliate-disclosure
/privacy
```

Optional if time allows:

```text
/nutrition
/training
/supplements
```

Defer:

```text
/for-professionals
/products
/services
/body-composition
/bloodwork
/devices
/glossary
/roadmap
/sponsorship-policy
```

These deferred pages remain important, but they are not required to prove the first public GoingBulk loop.

## Homepage Requirements

The homepage should include:

- one-sentence positioning;
- creator/project identity;
- current mission;
- baseline experiment status;
- latest public data snapshot;
- methodology link;
- medical disclaimer link;
- newsletter or contact call-to-action if available;
- social links if active.

Example positioning:

```text
GoingBulk is a public N=1 fitness documentation project tracking nutrition, training, bodyweight, supplements, and experiments with the data left on.
```

Avoid overclaiming early device/lab scope before those data streams exist.

## About Page Requirements

The About page is critical.

It should answer:

1. Who is behind GoingBulk?
2. Is this a real name, public persona, or pseudonym?
3. What is the creator's fitness starting point?
4. What credentials does the creator have or not have?
5. Why does GoingBulk exist?
6. Why should anyone care about this data?
7. What does N=1 mean?
8. What will GoingBulk not claim?
9. How are sponsors/affiliate links handled?
10. How can experts critique the work?

This page should follow `24-creator-positioning-and-credentials.md`.

## First Experiment Page

MVP experiment:

```text
/experiments/baseline-30-days
```

Purpose:

```text
Establish the starting point for GoingBulk by documenting 30 days of nutrition, training, bodyweight, supplements, and basic confounders.
```

Required sections:

- Quick Facts;
- N=1 disclaimer;
- medical disclaimer note;
- purpose;
- date range;
- data collected;
- methodology summary;
- nutrition summary;
- training summary;
- bodyweight summary;
- supplement summary;
- confounders;
- limitations;
- next phase.

Not required for this page:

- DEXA results;
- bloodwork;
- Hume comparison;
- product review verdicts;
- professional explorer embeds;
- full entity graph.

## First Dataset Page

MVP dataset:

```text
/data/baseline-30-days
```

Required sections:

- dataset summary;
- date range;
- data sources;
- included columns/fields;
- server-rendered summary table;
- CSV export link;
- visibility note;
- source/confidence notes;
- limitations;
- related experiment link;
- not medical advice note.

The dataset page should be useful even without advanced filters.

## Methodology Page

MVP methodology can be one combined page:

```text
/methodology
```

It should explain:

- Cronometer import workflow;
- bodyweight logging method;
- workout logging method;
- supplement logging method;
- confidence labels;
- visibility/publication rules;
- N=1 limitations;
- what is not yet being tracked.

Future separate methodology pages can be created later:

```text
/methodology/nutrition-logging
/methodology/workout-logging
/methodology/supplement-tracking
/methodology/body-composition-tracking
/methodology/data-confidence-labels
```

## Legal and Trust Pages

### Medical Disclaimer

Required:

```text
/medical-disclaimer
```

Must clearly state:

- GoingBulk is not medical advice;
- creator is not a medical professional unless true;
- experiments are N=1 personal documentation;
- do not replicate protocols without professional guidance;
- do not change medication/medical care based on the site.

### Privacy Policy

Required:

```text
/privacy
```

Must explain visitor data, newsletter/contact data if used, third-party services, and how creator data is intentionally published.

### Affiliate Disclosure

Required even if affiliate links are not active yet:

```text
/affiliate-disclosure
```

This creates trust posture early and supports later product/service pages.

### Sponsorship Policy

Optional for MVP, but recommended before accepting sponsors:

```text
/sponsorship-policy
```

## Optional MVP Hubs

If time allows, add these simple hub pages:

```text
/nutrition
/training
/supplements
```

Each should be short, honest, and status-aware.

Example status label:

```text
This hub is early. Detailed reports will appear after the first baseline dataset is complete.
```

Do not create thin placeholder hubs that pretend the site is larger than it is.

## Deferred Page Families

These are future phases:

### Professional Pages

```text
/for-professionals
/for-professionals/data-explorer
```

Defer until there is enough data and access policy is ready.

### Product and Service Pages

```text
/products
/services
/products/[slug]
/services/[slug]
```

Defer until real product/service usage windows and disclosure records exist.

### Device and Lab Pages

```text
/devices
/body-composition
/bloodwork
```

Defer until DEXA, Hume, bloodwork, or device data exists and redaction/privacy rules are tested.

### Glossary/Wiki Pages

```text
/glossary
/glossary/[term]
```

Defer broad glossary creation. Add glossary pages only when terms appear repeatedly and need canonical definitions.

## Launch SEO/GEO Requirements

Every MVP launch page should include:

- clear title;
- meta title;
- meta description;
- canonical URL;
- short summary near the top;
- related links;
- last updated date;
- appropriate schema only when it matches visible content.

Major pages should include:

- Quick Facts;
- crawlable summary;
- source/confidence notes;
- limitations;
- related links.

## Schema Guidance For MVP

Use conservative schema:

```text
WebSite
Person if creator identity is public enough
WebPage
Article for experiment page
BreadcrumbList
```

Do not rush into MedicalWebPage or complex Dataset schema before validating whether it is appropriate for N=1 personal data.

## Internal Linking Requirements

At MVP launch:

- homepage links to About, baseline experiment, methodology, disclaimer, and dataset;
- About links to methodology and disclaimer;
- experiment page links to dataset, methodology, disclaimer, and About;
- dataset page links to experiment and methodology;
- methodology links to experiment, dataset, and disclaimer;
- affiliate disclosure is linked from any page containing affiliate links.

## Content Status Labels

Use transparent status labels when something is early:

```text
Planned
In Progress
Currently Tracking
Published
Needs Update
Archived
```

Do not make unfinished pages look complete.

## First 30-Day Content Rhythm

During the baseline phase, publish lightly:

```text
Week 0: launch overview / baseline start
Week 1: logging process update
Week 2: early data-quality lessons
Week 3: what is hard to log consistently
Week 4: baseline report and dataset
```

This creates content before the full dataset exists without pretending results are ready.

## Core Rule

```text
Launch with fewer pages that are real, structured, honest, and connected rather than many thin future-facing pages.
```

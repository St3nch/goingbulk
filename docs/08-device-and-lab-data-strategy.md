# GoingBulk Device and Lab Data Strategy

## Purpose

GoingBulk will combine manually logged data, consumer device data, lab data, and body composition scans.

The goal is not to pretend every metric is equally accurate.
The goal is to label sources clearly and compare trends honestly.

## Data Source Layers

### Tier 1: Manually Verified / High-Trust Data

Examples:

- weighed food logs;
- Cronometer imports;
- workout sets/reps/load;
- supplement dose/adherence;
- lab bloodwork;
- DEXA scan summaries.

### Tier 2: Consumer Device Trend Data

Examples:

- Hume Pod body composition estimates;
- Hume Band data;
- Samsung watch data;
- sleep duration estimates;
- resting heart rate;
- HRV;
- steps;
- wearable workout metrics.

### Tier 3: Experimental or Contextual Data

Examples:

- CGM data;
- device-generated readiness scores;
- metabolic scores;
- subjective energy/mood/soreness.

## DEXA Strategy

DEXA should be treated as a higher-quality body composition checkpoint.

It can provide:

- body fat estimate;
- lean mass estimate;
- fat mass estimate;
- regional distribution;
- bone density data if included.

Recommended cadence:

```text
baseline DEXA
+ repeat every 8-12 weeks during major phases if budget allows
```

DEXA is not daily tracking. It is a periodic anchor.

## Hume Strategy

Hume Pod/Band data should be treated as frequent trend data.

Useful for:

- bodyweight trend;
- body composition estimate trend;
- wearable recovery context;
- sleep and activity context;
- comparison against DEXA changes.

Label as:

```text
Hume-estimated body fat
Hume-estimated lean mass
Hume device trend
```

Do not present Hume values as absolute clinical truth.

## Bloodwork Strategy

Bloodwork creates serious credibility but must be handled carefully.

Possible markers:

- fasting glucose;
- HbA1c;
- lipid panel;
- liver enzymes;
- kidney markers;
- vitamin D;
- ferritin;
- CRP;
- thyroid markers;
- testosterone if appropriate.

Recommended posture:

```text
summarize personal values
include date and fasting status
avoid medical claims
encourage professional interpretation
```

## Blood Pressure Strategy

If blood pressure is tracked, the measurement protocol should be standardized.

Suggested protocol:

```text
same cuff
same arm
same time of day
seated/rested for 5 minutes
no recent caffeine/exercise if possible
2-3 readings averaged
track sodium, sleep, stress, caffeine, and bodyweight
```

## Device vs Lab Comparison Experiments

One flagship experiment:

```text
Hume Pod vs DEXA: Can consumer body composition tracking follow the same trend direction over 12 weeks?
```

This should compare:

- DEXA baseline vs follow-up;
- Hume daily/weekly averages;
- bodyweight trend;
- measurements;
- progress photos;
- nutrition and training context.

Key question:

```text
Is the consumer device useful for trend tracking between DEXA scans?
```

Not:

```text
Is the consumer device as accurate as DEXA for everyone?
```

## Measurement Table Pattern

Use a generalized measurements table.

```text
measurements
- id
- measured_at
- metric_key
- value
- unit
- source
- device
- method
- confidence_level
- conditions
- notes
```

Examples:

```text
metric_key: body_fat_percent
value: 24.1
source: Hume Pod
method: BIA estimate
confidence_level: medium
conditions: morning fasted after bathroom
```

```text
metric_key: body_fat_percent
value: 26.4
source: DEXA
method: dual-energy x-ray absorptiometry
confidence_level: high
conditions: scan appointment
```

## Confidence Labels

Suggested labels:

```text
High: lab result, DEXA, weighed food, logged load/reps
Medium: consumer device trend, wearable sleep duration, Hume body composition trend
Low: subjective estimate, restaurant estimate, inconsistent measurement
Experimental: device-generated proprietary scores
```

## Public Display Rule

Always include source and method when showing sensitive or noisy data.

Good:

```text
Body fat: 24.1% | Source: Hume Pod | Method: BIA estimate | Confidence: Medium
```

Better for comparisons:

```text
DEXA-estimated body fat: 26.4%
Hume-estimated body fat weekly average: 24.1%
```

Avoid:

```text
Body fat: 24.1%
```

with no source or confidence.

## Privacy and Redaction

Sensitive documents may require redaction before publication.

Examples:

- lab addresses;
- patient ID numbers;
- personal address;
- provider account numbers;
- exact timestamps/location patterns;
- private clinical notes.

## Professional View

Professional-facing reports should include:

- measurement method;
- source;
- date;
- conditions;
- reference ranges if available;
- confidence level;
- limitations;
- related interventions;
- confounders.

## Core Rule

```text
Device data is useful when honestly labeled. Lab and DEXA data are stronger anchors, but still require context.
```

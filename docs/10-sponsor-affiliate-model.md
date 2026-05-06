# GoingBulk Sponsor and Affiliate Model

## Purpose

GoingBulk can monetize through affiliate links, product reviews, sponsored product tests, newsletter sponsorships, and content partnerships.

Monetization must not weaken trust.

## Core Principle

```text
Data first. Disclosure always. Money never edits the conclusion.
```

## Monetization Types

### Affiliate Links

GoingBulk may earn commission when users buy through certain links.

Affiliate links can be used for:

- supplements;
- devices;
- food tools;
- gym gear;
- training apps;
- nutrition apps;
- lab testing services;
- meal prep tools;
- wearable products.

### Sponsored Product Tests

A brand may provide product or payment for a defined test.

Sponsored tests must have:

- visible disclosure;
- defined test window;
- protocol;
- relevant metrics;
- limitations;
- editorial independence;
- honest outcome.

### Product Reviews

Product reviews should function like case studies.

They should include:

- what the product is;
- why it was used;
- dates used;
- dose/frequency;
- sponsor/affiliate status;
- subjective experience;
- measurable context;
- limitations;
- would-use-again verdict.

### Newsletter Sponsorship

Future weekly/monthly reports may include sponsor placements if clearly disclosed.

### Video Sponsorship

YouTube/video sponsorships may be accepted if they do not control the conclusion of the experiment or product review.

## Disclosure Labels

Every product/service should have one or more labels.

```text
Purchased Myself
Affiliate Link
Gifted Product
Sponsored Test
Paid Partnership
No Brand Control
Currently Testing
Completed Test
Would Buy Again
Stopped Using
Not Recommended
```

## Product Statuses

Suggested product status values:

```text
not_tested
currently_using
currently_testing
completed_test
stopped_using
not_recommended
would_buy_again
sponsored
affiliate
```

## Product Review Page Structure

Recommended sections:

1. Product summary
2. Disclosure status
3. Why I tested it
4. Usage protocol
5. Date range
6. Subjective experience
7. Relevant data during use
8. Confounders
9. Cost/value
10. Pros and cons
11. Would I still use it if nobody paid me?
12. Verdict
13. Limitations
14. Affiliate link or product link

## Key Verdict Question

Every review should answer:

```text
Would I still use this if nobody paid me?
```

Possible answers:

```text
Yes
No
Maybe
Still testing
Only in specific situations
```

## Review Confidence

Product reviews should carry a data confidence rating.

```text
Low: short use, many confounders, mostly subjective.
Medium: meaningful use window, some relevant data, some confounders.
High: longer use, good adherence, stable context, relevant data available.
```

## Affiliate Link Routing

Use internal redirect links for manageability.

Example:

```text
/go/hume-pod
/go/food-scale
/go/cronometer
/go/protein-brand-x
```

The destination page or nearby call-to-action must disclose affiliate status.

## Affiliate Tables

### products

```text
id
name
brand
category
slug
status
current_use_status
would_buy_again
summary
```

### affiliate_links

```text
id
product_id
merchant
destination_url
internal_slug
commission_type
disclosure_text
active
created_at
updated_at
```

### sponsor_relationships

```text
id
brand
product_id
relationship_type
start_date
end_date
compensation_type
brand_control_allowed
disclosure_required
notes
```

### product_reviews

```text
id
product_id
review_status
data_confidence
start_date
end_date
summary
pros
cons
limitations
verdict
would_use_if_not_paid
```

## Editorial Independence Policy

GoingBulk should state publicly:

- sponsorships are disclosed;
- affiliate links are disclosed;
- brands cannot buy positive conclusions;
- negative or neutral results may still be published;
- brands do not control the data;
- brands may not edit final conclusions;
- personal experience is separated from measurable data;
- N=1 data is not presented as universal proof.

## Sponsor Package Ideas

Potential future packages:

| Package | Includes |
|---|---|
| Product Review | dedicated review page and disclosure |
| 30-Day Test | tracked usage window and summary |
| 90-Day Protocol | deeper experiment with public dashboard context |
| Video + Dashboard | YouTube/video content plus data page |
| Newsletter Feature | disclosed placement in weekly/monthly report |
| Expert Review | professional commentary if available |

## Product Test Readiness

Not every product should be reviewed immediately.

Suggested minimum windows:

| Product Type | Suggested Minimum |
|---|---|
| Protein powder | 2-4 weeks |
| Creatine | 8-12 weeks |
| Sleep supplement | 2-4 weeks |
| Wearable/device | 8-12 weeks |
| Training app | 8-12 weeks |
| Meal service | 2-4 weeks |

## Public Pages

GoingBulk should include:

```text
/what-i-use
/products
/products/[slug]
/services
/services/[slug]
/sponsorship-policy
/affiliate-disclosure
/partners
/media-kit
/contact/partner
```

## Social Media Use

Affiliate links may appear on social platforms, but GoingBulk should usually drive users back to the site first.

Preferred flow:

```text
social post/video
-> experiment or review page
-> disclosed affiliate/product link
```

This builds trust, owned traffic, SEO value, and better analytics.

## Hard Rule

GoingBulk should be willing to publish:

```text
This product did not clearly help me.
```

That is what makes positive reviews believable.

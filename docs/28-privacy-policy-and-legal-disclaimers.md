# GoingBulk Privacy Policy and Legal Disclaimers

## Purpose

This document defines the legal, privacy, medical disclaimer, affiliate disclosure, and publication-safety posture for GoingBulk.

This document is a planning draft, not legal advice. Before public launch, the final legal pages and disclaimer language should be reviewed by a qualified attorney, especially because GoingBulk may publish health, supplement, bloodwork, blood pressure, glucose, DEXA, and body composition content.

## Core Rule

```text
GoingBulk is personal documentation, not medical advice.
```

This rule must appear across the site, not only on one buried disclaimer page.

## Required Public Legal Pages

MVP should include:

```text
/privacy
/medical-disclaimer
/affiliate-disclosure
/sponsorship-policy
/terms
```

If analytics or cookies are used, also consider:

```text
/cookie-policy
```

## Site-Wide Medical Disclaimer Component

Every public page should include a concise disclaimer in the footer or near health-sensitive sections.

Example:

```text
GoingBulk is a personal N=1 fitness and health documentation project. It is not medical advice. I am not a doctor or licensed healthcare provider. Do not use this site to diagnose, treat, prevent, or manage any condition. Talk to a qualified professional before changing diet, exercise, supplements, medications, or health routines.
```

## Full Medical Disclaimer Requirements

The full `/medical-disclaimer` page should state:

- GoingBulk is for personal documentation, education, and entertainment;
- the creator is not a doctor unless true;
- experiments are N=1 personal tracking;
- content is not clinical research;
- content is not medical advice;
- readers should not replicate protocols without professional guidance;
- readers should not start, stop, or change medication based on GoingBulk;
- supplements, diet changes, exercise, fasting, and health experiments can carry risks;
- emergencies require emergency services, not website content.

## High-Risk Content Disclaimer Blocks

### Supplement Experiments

Use near the top of supplement experiment pages:

```text
Important: This is a personal supplement-use log, not a recommendation. Supplements can interact with medications, medical conditions, pregnancy, surgery, liver/kidney function, blood pressure, glucose, and other health factors. Do not copy this protocol without consulting a qualified healthcare professional.
```

### Blood Pressure Content

```text
This page includes personal blood pressure tracking. It is not guidance for hypertension, cardiovascular disease, medication decisions, or emergency care. If you have high blood pressure or symptoms, consult a qualified healthcare professional.
```

### Blood Glucose / HbA1c Content

```text
This page includes personal glucose or HbA1c tracking. It is not diabetes advice, diagnosis, treatment guidance, or medication guidance. If you have abnormal glucose values or diabetes-related concerns, consult a qualified healthcare professional.
```

### Bloodwork Content

```text
This page includes personal lab values. Lab results require interpretation by qualified professionals and must be understood in context. GoingBulk does not diagnose, treat, or recommend medical actions based on lab results.
```

### Exercise / Training Content

```text
Exercise can carry injury and health risks. GoingBulk training logs describe what I did, not what you should do. Consult a qualified professional if you have medical conditions, injuries, or concerns.
```

## Privacy Policy Requirements

The `/privacy` page should explain:

### Data Collected From Visitors

Potential visitor data:

- newsletter email;
- contact form submissions;
- analytics events;
- affiliate link clicks;
- server logs;
- cookies if used;
- account data if professional accounts are added later.

### Data Not Collected From Visitors By Default

GoingBulk should make clear that the creator's self-tracking data is about the creator, not visitor health records.

If user accounts are added later, update privacy policy before launch.

### Third-Party Services

Disclose services such as:

```text
Vercel
Supabase
Cloudflare
email/newsletter provider
analytics provider
affiliate networks
payment processor if sponsors/payments are handled
```

### User Rights

Include:

- unsubscribe instructions;
- data deletion request contact;
- data access request contact;
- contact email for privacy concerns.

## Creator Data Publication Policy

GoingBulk publishes selected creator data intentionally.

However, not all creator data should be public.

Default visibility:

| Data Type | Default Visibility |
|---|---|
| raw lab PDFs | private |
| redacted lab summaries | professional/public by choice |
| DEXA summaries | public/professional by choice |
| unredacted DEXA reports | private |
| raw food logs | private/internal unless promoted |
| nutrition summaries | public |
| workout summaries | public |
| exact timestamps | private/internal by default |
| progress photos | private until watermarked/promoted |
| sponsor negotiations | private |
| affiliate status | public when links appear |
| private notes | private |

## Redaction Requirements

Before publishing lab reports, DEXA reports, PDFs, screenshots, or photos, check for:

```text
[ ] full name
[ ] date of birth
[ ] address
[ ] phone number
[ ] email
[ ] patient ID / account number
[ ] insurance information
[ ] lab facility full address
[ ] physician/provider names if not intended public
[ ] barcodes or QR codes
[ ] hidden PDF metadata
[ ] EXIF/GPS metadata on images
```

Use real redaction that removes data, not black boxes layered over text.

## Progress Photo Policy

Progress photos should be:

- reviewed before publication;
- stripped of EXIF/GPS data;
- watermarked;
- optionally face-blurred or cropped;
- linked to date/phase only when safe;
- never uploaded raw to public storage accidentally.

Suggested watermark:

```text
GoingBulk.com - Personal documentation - Not for commercial use
```

## Affiliate Disclosure Requirements

FTC-style principle:

```text
Affiliate disclosures must be clear, unavoidable, and appear before or near affiliate links.
```

Do not rely only on a footer or standalone disclosure page.

Example component:

```text
This page contains affiliate links. If you buy through these links, I may earn a commission at no extra cost to you. This does not change the data, protocol, or conclusion. See the full affiliate disclosure.
```

## Sponsorship Disclosure Requirements

Sponsored pages must disclose:

- sponsor name;
- product/service involved;
- compensation type;
- date range;
- whether product was gifted;
- whether money changed hands;
- whether sponsor had review/edit rights;
- whether negative conclusions are allowed;
- whether affiliate links are present.

Preferred GoingBulk standard:

```text
Sponsors cannot buy positive conclusions.
```

## Terms of Service Requirements

Terms should include:

- informational use only;
- no medical advice;
- no doctor-patient relationship;
- no guarantee of accuracy or completeness;
- intellectual property ownership;
- acceptable use;
- limitation of liability;
- affiliate/sponsor references;
- jurisdiction/governing law;
- contact information.

Attorney review strongly recommended.

## Incident Response Triggers

Create an incident response if:

- private health data is accidentally published;
- unredacted PDF is exposed;
- affiliate disclosure is missing;
- sponsor influence is misrepresented;
- harmful medical wording is published;
- user/contact data is leaked;
- progress photos are misused;
- a reader claims injury from copying a protocol.

## Legal Review Checklist Before Launch

```text
[ ] medical disclaimer reviewed
[ ] privacy policy reviewed
[ ] terms reviewed
[ ] affiliate disclosure reviewed
[ ] sponsorship policy reviewed
[ ] supplement experiment wording reviewed
[ ] bloodwork/blood pressure/glucose disclaimer reviewed
[ ] progress photo/copyright/privacy posture reviewed
[ ] liability insurance considered
```

## Core Principle

```text
Transparency does not mean publishing everything. It means publishing intentionally, with context, consent, and safety boundaries.
```

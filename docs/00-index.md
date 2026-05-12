# GoingBulk Docs Index

## Purpose

This folder contains the working foundation docs for GoingBulk.

GoingBulk is a public, data-driven fitness and health brand built around transparent personal tracking, structured experiments, public dashboards, product testing, and expert-readable reports.

These docs are separate from the VedaOps doctrine repository. VedaOps docs are context only. GoingBulk docs live here as the project-specific planning foundation.

## Current Doc Set

1. `01-project-overview.md` - high-level identity, mission, and positioning.
2. `02-product-vision.md` - product experience, audiences, and core website/app concept.
3. `03-system-architecture.md` - Next.js/Postgres architecture and major modules.
4. `04-data-boundary-and-vedaops-context.md` - how GoingBulk relates to Project V, V Forge, VEDA, and VedaOps without blurring ownership.
5. `05-experiment-framework.md` - claim-to-research-to-N=1 experiment model.
6. `06-nutrition-import-pipeline.md` - Cronometer export/import strategy.
7. `07-workout-program-logging.md` - mobile workout logging and 12-week program builder model.
8. `08-device-and-lab-data-strategy.md` - DEXA, bloodwork, Hume, wearables, and confidence labels.
9. `09-entity-seo-geo-architecture.md` - entity-first site structure, schema, internal linking, and LLM citation readiness.
10. `10-sponsor-affiliate-model.md` - product reviews, affiliate links, sponsorship rules, and disclosure posture.
11. `11-llm-partner-operating-model.md` - future LLM assistant behavior, tool access, and governance posture.
12. `12-professional-data-explorer.md` - advanced filtering, sorting, saved views, exports, and pro-facing data exploration.
13. `13-entity-structured-wiki-and-topical-architecture.md` - wiki-style topical hubs, entity graph structure, product/service entities, table readability, and SEO/GEO architecture.
14. `14-seo-geo-llm-citation-strategy.md` - strategy for maximizing SEO, GEO, AI answer visibility, LLM citations, schema, datasets, and entity-first SERP performance.
15. `15-mvp-scope-and-build-phases.md` - MVP scope, non-scope, launch criteria, and phased build plan.
16. `16-database-schema-draft.md` - first-pass schema draft for nutrition, workouts, experiments, products, entities, reports, and daily facts.
17. `17-content-model-and-page-types.md` - hybrid content model, page types, content statuses, reusable blocks, and LLM-readable page structure.
18. `18-schema-governance-and-database-discipline.md` - hard rules for Supabase/Postgres schema discipline, migrations, JSON discipline, visibility, RLS, and anti-spaghetti database design.
19. `19-mobile-logging-ux.md` - mobile-first logging flow, Today screen, workout logging, supplement checklist, body metrics, and confounder capture.
23. `23-launch-content-map.md` - first public page set, launch hubs, initial methodology/entity/glossary pages, and launch SEO requirements.
24. `24-creator-positioning-and-credentials.md` - creator identity, credentials, positioning, trust posture, About page requirements, and open identity questions.
25. `25-supabase-rls-policy-design.md` - Supabase Row Level Security model, visibility rules, role access, storage policy posture, and RLS testing requirements.
26. `26-api-security-and-agent-access.md` - API security, agent/LLM access, API keys, scopes, rate limits, audit logs, exports, and no-direct-DB enforcement.
27. `27-writing-style-guide.md` - voice, claim-safety language, forbidden phrases, no-drama policy, sponsor wording, and pre-publish checklist.
28. `28-privacy-policy-and-legal-disclaimers.md` - planning draft for privacy, medical disclaimer, affiliate/sponsor disclosure, redaction, progress photos, and legal review checklist.
29. `29-migration-and-deployment-strategy.md` - Vercel/Supabase deployment posture, Drizzle migration recommendation, environments, backups, and smoke tests.
30. `30-claude-project-docs-audit-prompt.md` - prompt for an external Claude audit to challenge assumptions, find gaps, and produce recommendations.
31. `31-revised-mvp-scope-after-audit.md` - tightened MVP scope after Claude audit, focused on proving the data-to-report loop in one real month.
32. `32-full-project-roadmap.md` - start-to-end roadmap from foundation and MVP through pro explorer, entity graph, LLM/API integration, VedaOps/V Forge alignment, monetization, and mature platform state.
33. `33-early-trust-features.md` - MVP-adjacent trust features including experiment pre-registration, methodology changelog, and staged backlog for later high-value ideas.
34. `34-local-dev-now-vforge-portability-plan.md` - plan for starting local development now while keeping GoingBulk standalone, portable, and ready for later VedaOps/V Forge integration.
35. `35-repo-github-professional-setup.md` - professional local repo and GitHub setup, including branch strategy, secrets policy, issue/milestone workflow, CI, and V Forge portability requirements.
36. `36-mvp-schema-implementation-contract.md` - implementation-ready MVP schema contract covering table list, fields, constraints, indexes, RLS, imports, audit logging, and Drizzle/Supabase notes.
37. `37-detailed-nutrient-modeling.md` - architecture decision for detailed Cronometer nutrient storage using `nutrient_definitions` and `nutrition_log_nutrients`.
38. `38-training-program-template-and-scheduling-model.md` - planned workout program, scheduling, daily execution, and planned-vs-actual tracking model based on the collected Jim Stoppani program structures.
39. `39-transparency-data-display-and-tracking-model.md` - transparency-focused display and tracking model covering planned-vs-actual, modifications, recovery context, symptoms, costs, scorecards, and public-safe summaries.
40. `40-training-program-schema-contract.md` - implementation-ready schema contract for planned training programs, scheduling, planned sets, substitutions, rest tracking, planned-vs-actual links, and public/private display rules.

## Working Principle

Boring, consistent logging creates trustworthy data. Trustworthy data creates better content. Better content creates audience, expert attention, and sponsor value.

## Non-Goals

GoingBulk is not intended to be a medical advice platform, clinical trial, drama channel, or replacement for professional care.

GoingBulk experiments are personal N=1 documentation unless explicitly stated otherwise.



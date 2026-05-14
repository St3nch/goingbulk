# Literature Evidence and Supplement Experiment Pipeline

## Purpose

GoingBulk should eventually support a research-aware workflow for discovering, storing, evaluating, and translating supplement, nutrition, training, recovery, and biomarker studies into personal experiment ideas.

This is a future capability, not an MVP dependency.

The goal is to let GoingBulk answer questions like:

- What human studies exist for a supplement, dose, protocol, or outcome?
- Which findings are plausible enough to test personally?
- Which claims are weak, overhyped, animal-only, or not applicable?
- Which paper-backed claims map cleanly into N=1 experiments?
- Did the creator's own result align with, partially align with, or contradict the research claim?

This feature should turn research into structured, transparent experiment planning without pretending that personal tracking is clinical proof.

## Core Idea

GoingBulk can maintain a literature evidence layer alongside personal data.

The pipeline is:

1. Discover relevant papers, reviews, and meta-analyses.
2. Store citation metadata and availability status.
3. Extract structured claims and study context.
4. Link claims to supplements, nutrients, exercises, recovery methods, biomarkers, or training protocols.
5. Rate the evidence quality and applicability.
6. Convert selected claims into pre-registered personal experiment ideas.
7. Compare personal outcomes against the original research claim.
8. Publish a careful, non-medical summary when appropriate.

## Potential Data Sources

Potential sources include:

- PubMed for biomedical citations and abstracts.
- Europe PMC for open-access biomedical/life-science papers and full text where available.
- Crossref for DOI and citation metadata.
- OpenAlex for broad scholarly graph metadata.
- PubTator or similar biomedical entity tools for linking compounds, conditions, genes, proteins, and outcomes.
- Publisher pages when full text or abstracts are available.
- Manual user-entered citations for papers discovered outside automated search.

The system should store source metadata and access status, but it must not assume full-text access is always available.

## Paywall and Access Rules

GoingBulk should not depend on pirated papers or unauthorized full-text scraping.

Each paper should support an access status such as:

- `abstract_only`
- `open_access_full_text`
- `publisher_full_text_available`
- `paywalled`
- `manual_user_provided_notes`
- `unavailable`

If a paper is paywalled, GoingBulk can still store:

- title
- DOI
- PMID/PMCID where available
- authors
- journal
- publication year
- abstract when legally available
- source URL
- user notes
- evidence tags
- claims manually extracted from accessible material

The system should avoid storing unauthorized full-text content.

## Candidate Future Tables

This section is intentionally conceptual. Do not implement until the feature is prioritized.

### `research_papers`

Stores citation-level metadata.

Potential fields:

- `id`
- `title`
- `abstract`
- `doi`
- `pmid`
- `pmcid`
- `source_url`
- `journal`
- `publication_year`
- `authors_json`
- `study_type`
- `access_status`
- `full_text_url`
- `open_access_license`
- `created_at`
- `updated_at`

### `research_claims`

Stores structured claims extracted from papers.

Potential fields:

- `id`
- `paper_id`
- `claim_text`
- `intervention`
- `dose`
- `duration`
- `population`
- `outcome`
- `effect_direction`
- `effect_size_text`
- `evidence_quality`
- `applicability_to_creator`
- `limitations`
- `created_at`
- `updated_at`

### `research_entities`

Links papers and claims to known entities.

Potential entity types:

- supplement
- nutrient
- food
- exercise
- training protocol
- recovery method
- biomarker
- symptom
- device
- lab marker

### `experiment_ideas`

Turns a research claim into a possible personal experiment.

Potential fields:

- `id`
- `research_claim_id`
- `title`
- `hypothesis`
- `proposed_protocol`
- `target_metrics`
- `confounders_to_track`
- `risk_notes`
- `status`
- `created_at`
- `updated_at`

### `experiment_research_links`

Links real GoingBulk experiments to papers and claims.

Potential fields:

- `experiment_id`
- `paper_id`
- `research_claim_id`
- `relationship_type`
- `notes`

Relationship types might include:

- `inspired_by`
- `replicates_protocol`
- `tests_related_claim`
- `contradicts_claim`
- `supports_claim_for_creator`
- `inconclusive`

## Evidence Quality Labels

The feature should use plain-language evidence labels instead of pretending precision.

Possible labels:

- `meta_analysis`
- `systematic_review`
- `randomized_controlled_trial`
- `controlled_trial`
- `observational_human`
- `case_study`
- `animal_study`
- `mechanistic`
- `in_vitro`
- `expert_opinion`
- `marketing_claim`
- `unknown`

The app should distinguish:

- human vs animal evidence
- acute vs chronic intervention
- trained vs untrained population
- male/female/age applicability
- healthy vs clinical population
- performance vs health outcome
- statistically significant vs practically meaningful

## Personal Experiment Translation

A research claim should not automatically become a recommendation.

The translation workflow should ask:

1. Is the study human-relevant?
2. Does the dose make sense for the creator?
3. Is the intervention legal, safe, and reasonable?
4. Does it interact with current supplements, medications, labs, or medical conditions?
5. Can the outcome be measured with available tools?
6. Can confounders be tracked?
7. Is the experiment worth the risk/cost/effort?
8. Does it require professional review before testing?

The output should be framed as:

- "possible experiment idea"
- "research-inspired hypothesis"
- "not medical advice"
- "requires professional review" when appropriate

## LLM Role

An LLM can help with:

- finding candidate papers
- summarizing abstracts
- extracting structured claims
- identifying dose/duration/population/outcome
- flagging weak evidence
- drafting experiment hypotheses
- mapping claims to existing GoingBulk metrics
- generating reviewer questions

An LLM must not:

- invent papers
- overstate causal claims
- ignore paywall/access limits
- present supplement protocols as medical advice
- recommend unsafe dosing
- hide uncertainty
- replace professional review

Every LLM-generated claim should store provenance:

- model/source used
- timestamp
- source citation
- confidence label
- human review status

## Public Display Model

Public pages should separate:

- what the paper found
- what the creator tested
- what the creator observed
- what remains unknown

Suggested public language:

- "This paper reported..."
- "My personal test was inspired by..."
- "My result did/did not match the claim in this N=1 context..."
- "This does not prove the claim generally."

Avoid:

- "proves"
- "guarantees"
- "clinically validated for me"
- "everyone should take"

## Governance Requirements

Before implementing this feature:

1. Add new migrations only. Do not rewrite existing migrations after real data exists.
2. Keep paper metadata separate from personal experiment results.
3. Add RLS from the beginning.
4. Add audit logging for claim promotion and public publishing.
5. Track paywall/open-access status explicitly.
6. Store source citations for every extracted claim.
7. Require human review before any claim becomes public-facing.
8. Hammer-test ownership, visibility, and publication behavior.

## MVP Deferral

This feature should wait until the core GoingBulk loop is working:

1. Log nutrition, training, supplements, body metrics, and confounders.
2. Import Cronometer data.
3. Run basic experiments.
4. Generate transparent reports.
5. Publish public-safe summaries.

After that, literature-aware experiment discovery becomes a powerful differentiator.

## Open Questions

- Should this be part of GoingBulk directly or a separate research module?
- Should papers be attached only to experiments, or also to supplements/entities/wiki pages?
- Should paper ingestion be manual-first before automated search?
- What level of evidence quality scoring is useful without becoming fake precision?
- Should professional reviewers have a role in approving claim summaries?
- How should copyrighted full text be handled safely?
- Should this eventually integrate with an LLM agent or remain human-curated?

## Status

Backlog / future architecture candidate.

Do not implement until after the MVP data loop and audit logging foundation are stable.

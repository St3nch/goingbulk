I'll conduct a comprehensive audit of the GoingBulk project documentation. Let me first examine the full documentation set to provide a thorough, evidence-based critique.

# 1. Executive Verdict

**Is the project coherent?** Yes, surprisingly so. The vision is clear and the documentation demonstrates unusual discipline for a pre-build project.

**Is it buildable?** Yes, but with significant scope reduction needed.

**Is the MVP realistic?** No. The "MVP" includes 30+ pages, multiple complex data pipelines, professional data explorer, schema governance, entity graphs, and SEO optimization. This is 6-12 months of work presented as a minimum viable product.

**Biggest strength:** The clear separation between data capture (Cronometer) and data analysis/publishing (GoingBulk). This is strategically brilliant and prevents rebuilding a food database.

**Biggest risk:** Health/medical liability exposure from publishing blood pressure, glucose, bloodwork, and supplement protocols without adequate legal review and disclaimers. The N=1 framing helps but may not be sufficient legal protection.

**Biggest missing decision:** Who is the actual human being behind GoingBulk? The docs never name the creator, define their credentials (or lack thereof), or establish why anyone should care about their personal data. This is a fatal marketing/positioning gap.

# 2. Evidence Quotes From The Docs

**Quote 1:**
> "GoingBulk should not be positioned as another generic fitness influencer brand. The stronger position is: A public personal fitness dataset, experiment log, and product-testing media brand."

**Why it matters:** This is the core strategic positioning, but it assumes the dataset itself is inherently valuable. Without a compelling human story or unique credentials, why would anyone care about random person #47's DEXA results?

**Quote 2:**
> "The LLM, connected agents, MCP tools, automation systems, or external assistants must not directly query Supabase/Postgres or otherwise act as database clients."

**Why it matters:** This is excellent architectural discipline that prevents future security disasters. However, the docs don't specify how to enforce this technically—is it just a policy or will there be network/credential controls?

**Quote 3:**
> "The first public version should answer: What is GoingBulk? How is data collected? What is being tracked? What experiment is active or starting?"

**Why it matters:** The launch content map lists 30+ pages. This is not an MVP, it's a full v1 product launch. The contradiction between "MVP" language and actual scope is severe.

**Quote 4:**
> "Do not claim causation from N=1 data. Use associated with, during, changed while, or my data showed instead of caused, cured, fixed, or proven."

**Why it matters:** This is essential legal protection, but it's buried in doc 11 rather than being a prominent system-wide requirement enforced at the database/UI level.

**Quote 5:**
> "Not every field should be public. Fields should support visibility levels: private, internal, professional, public"

**Why it matters:** This is mentioned but never implemented in the schema. The database draft doesn't include visibility columns on most tables, creating a dangerous gap between principle and practice.

**Quote 6:**
> "Cronometer CSV export -> GoingBulk import tool -> raw import batch stored -> import preview and validation -> normalized nutrition logs -> dashboard/report update"

**Why it matters:** This is the only clearly defined data pipeline. Everything else (DEXA, bloodwork, Hume, wearables) is vague or deferred, suggesting the nutrition pipeline should be the true MVP focus.

**Quote 7:**
> "The mobile app exists to protect consistency. Consistency creates the dataset. The dataset creates the brand."

**Why it matters:** This reveals the core dependency chain, but "mobile app" is defined as a PWA which may not provide the polish/speed needed for daily gym logging. This is an unvalidated technical bet.

**Quote 8:**
> "GoingBulk will contain years of data: nutrition logs; workout logs; supplement logs; body metrics; bloodwork; DEXA results; device readings; experiments; claims; products; services; affiliate links; content entities; reports; professional data explorer views."

**Why it matters:** This describes a multi-year data accumulation without explaining what happens during months 1-12 when most of these datasets don't exist yet. The content strategy for the bootstrapping period is undefined.

**Quote 9:**
> "Approval-sensitive actions include: publishing a page; changing public bloodwork interpretation; approving sponsor claims; changing experiment verdicts; creating or activating affiliate links; changing medical/health disclaimers; deleting records"

**Why it matters:** This defines critical workflows but doesn't specify who approves, how approval is tracked, or what happens if the sole creator is unavailable. Single point of failure risk.

**Quote 10:**
> "Use TanStack Table and shadcn/ui should power the first version because they fit the GoingBulk Next.js/Tailwind app direction"

**Why it matters:** This is a specific technical decision with rationale, but AG Grid is mentioned as a possible future upgrade. Starting with the simpler option is correct, but the docs should confirm TanStack can handle 1000+ row daily_facts tables.

**Quote 11:**
> "Schema changes should be migration-controlled. Avoid production schema changes made manually in the dashboard without a corresponding migration record."

**Why it matters:** This is excellent discipline but contradicts Supabase's ease-of-use selling point. The docs need to specify the actual migration tooling (Prisma? Drizzle? Raw SQL?).

**Quote 12:**
> "public assistant can access: published pages; public dashboard summaries; public experiment reports; approved product/review information; public methodology and disclaimers. It should not access: private raw logs; unpublished bloodwork; sponsor negotiations"

**Why it matters:** This defines two different LLM assistants (internal vs public) but doesn't explain the technical implementation. Are these different system prompts? Different API keys? Different databases?

**Quote 13:**
> "If long-form content live in MDX files, Postgres, or both?"

**Why it matters:** This is listed as an "open question" in doc 16, meaning a core architectural decision remains unmade. You cannot build an MVP without knowing where content lives.

**Quote 14:**
> "The product must make logging easier than avoidance. If data entry is painful, the brand loses its foundation."

**Why it matters:** This is the most important product requirement, but the mobile UX doc doesn't include any validation plan. How will you know if logging is actually easy before building months of backend infrastructure?

**Quote 15:**
> "DEXA-estimated body fat: 26.4% Hume-estimated body fat weekly average: 24.1%"

**Why it matters:** This example shows a 2.3% discrepancy that will confuse users. The docs don't explain how to handle device vs lab disagreements in the UI or whether to show both values simultaneously.

**Quote 16:**
> "GoingBulk experiments are personal N=1 documentation unless explicitly stated otherwise."

**Why it matters:** This disclaimer appears in multiple docs but never as a site-wide banner/footer requirement. The legal team will want this more prominent than buried in methodology pages.

**Quote 17:**
> "Products and services should be first-class entities. Each product/service can connect to: brand; category; product type; supplement ingredient if applicable; usage windows; experiments; review page; affiliate links; sponsor relationship; verdict; would-use-if-not-paid status."

**Why it matters:** This is a sophisticated product graph that suggests GoingBulk could evolve into a product database/review platform. But this potential pivot isn't discussed in the vision docs.

**Quote 18:**
> "If using Supabase Row Level Security, policies must be written intentionally. Do not rely on vague assumptions"

**Why it matters:** RLS is mentioned as a feature but never designed. The MVP cannot ship without explicit RLS policies for every table, or data will leak.

**Quote 19:**
> "Daily logging checklist takes under one minute outside workouts; workout logging does not disrupt training; supplement logging is one tap; bodyweight logging is under 10 seconds"

**Why it matters:** These are specific, measurable success criteria. The docs should include a testing plan to validate these before launch.

**Quote 20:**
> "The moat is original first-party data. GoingBulk can publish: nutrition logs; workout logs; DEXA results; bloodwork summaries; Hume/wearable comparisons; supplement usage windows; product usage records; experiment protocols; confounder logs; monthly reports; quarterly reports."

**Why it matters:** This positions data transparency as the competitive advantage, but doesn't address the question: why would Google/Perplexity cite random person #47's bloodwork instead of Mayo Clinic? The SEO strategy assumes the data is inherently authoritative.

# 3. Top 10 Critical or High-Risk Issues

## Issue 1: Health/Medical Liability Exposure
**Severity:** Critical

**Issue:** Publishing blood pressure experiments, glucose tracking, supplement protocols, and bloodwork without explicit medical review creates potential liability. The N=1 disclaimer may not be adequate legal protection if someone replicates a protocol and gets hurt.

**Where it appears:** Docs 5, 8, 14, 18

**Recommended fix:** 
- Require legal review before launch
- Add prominent site-wide medical disclaimer (not just methodology pages)
- Consider liability insurance
- Add "Do not replicate without medical supervision" to all experiment pages
- Require age gate (18+) before viewing health data
- Add explicit "not medical advice" to every page footer via site-wide component

## Issue 2: No Creator Identity or Credentials
**Severity:** Critical

**Issue:** The docs never define who the creator is, their background, credentials, or why their data matters. This is a fatal positioning gap. "Random person's DEXA results" isn't compelling. "Former obese programmer's transformation" or "registered dietitian's self-experiment" would be.

**Where it appears:** Nowhere—this is a missing section

**Recommended fix:**
- Add doc: `24-creator-positioning-and-credentials.md`
- Define: who is the creator, what's their story, why should people care
- Address credential question explicitly (certified? experienced hobbyist? medical background? none of the above?)
- Position the lack of credentials as transparency rather than pretending authority

## Issue 3: MVP Is Actually 6-12 Months of Work
**Severity:** Critical

**Issue:** The "MVP" includes 30+ launch pages, professional data explorer, advanced filters, saved views, schema governance, entity graph, SEO optimization, mobile PWA, and multiple import pipelines. This is not minimum or viable—it's a full product v1.

**Where it appears:** Doc 15, 23

**Recommended fix:**
True MVP should be:
- Homepage
- About page
- ONE baseline experiment page
- ONE dataset page with CSV export
- Cronometer import only (defer DEXA/bloodwork/Hume)
- Basic bodyweight/workout logging
- Medical disclaimer
- Affiliate disclosure
- No professional explorer (defer to Phase 2)
- No entity graph (defer to Phase 2)
- No saved views (defer to Phase 2)

Ship this in 6-8 weeks, then iterate.

## Issue 4: RLS Policies Undefined
**Severity:** High

**Issue:** Supabase RLS is mentioned but never designed. Without explicit RLS policies, the database will either leak private health data or block public pages. This must be designed before build, not during.

**Where it appears:** Doc 18

**Recommended fix:**
- Add doc: `25-supabase-rls-policy-design.md`
- Define policies for every table
- Map visibility levels (private/internal/professional/public) to RLS rules
- Design admin override pattern
- Design professional viewer access pattern
- Test policies before launch

## Issue 5: Visibility Columns Missing From Schema
**Severity:** High

**Issue:** The docs emphasize visibility levels (private/internal/professional/public) but the database schema draft doesn't include visibility columns on most tables. This is a dangerous gap between principle and implementation.

**Where it appears:** Doc 16, 18

**Recommended fix:**
Add `visibility` enum column to these tables:
- nutrition_logs
- workout_sessions
- supplement_logs
- measurements
- bloodwork_results
- dexa_results
- progress_photos
- experiments
- product_reviews
- reports
- datasets

Default to 'private' and require explicit promotion to 'public'.

## Issue 6: Content Storage Location Undecided
**Severity:** High

**Issue:** Doc 16 lists "Should long-form content live in MDX files, Postgres, or both?" as an open question. You cannot build an MVP without deciding where content lives and how it's edited.

**Where it appears:** Doc 16, 17

**Recommended fix:**
**Decision:** Use MDX for MVP.
**Rationale:** 
- Faster to build
- Version control built-in
- No CMS needed
- Easy to migrate to DB later if needed
- Metadata goes in frontmatter
- Page/entity relationships go in DB

Move content to DB only if admin users need in-dashboard editing (Phase 2+).

## Issue 7: LLM/Agent API Enforcement Undefined
**Severity:** High

**Issue:** The docs correctly state LLMs must use APIs not direct DB access, but don't specify enforcement. Is this just a policy or are there technical controls?

**Where it appears:** Doc 11, 18

**Recommended fix:**
- Create separate DB user for GoingBulk API with limited permissions
- LLM/agent tools get API keys, not DB credentials
- Network policies block direct Postgres access from LLM infrastructure
- Document this in new section: `26-api-security-and-agent-access.md`

## Issue 8: Approval Workflows Not Implemented
**Severity:** Medium-High

**Issue:** Doc 11 lists approval-sensitive actions but doesn't specify approval tracking, who approves, or what happens if creator is unavailable.

**Where it appears:** Doc 11

**Recommended fix:**
Add to schema:
```
approval_queue
- id
- action_type
- resource_id
- requested_by
- requested_at
- status (pending/approved/rejected)
- approved_by
- approved_at
- notes
```

For MVP: creator approves everything manually. Phase 2: add trusted reviewer roles.

## Issue 9: Professional Viewer Auth Undefined
**Severity:** Medium-High

**Issue:** The professional data explorer is described in detail but doesn't specify how professionals get access. Accounts? Public no-login? Invite-only? Magic links?

**Where it appears:** Doc 12, 14

**Recommended fix:**
**For MVP:** Make professional view public but noindex. No login required.
**For Phase 2:** Add invite-only accounts with email magic links (no password complexity hell).

This defers the auth complexity while keeping data accessible to doctors/nutritionists.

## Issue 10: Single Point of Failure (Creator Dependency)
**Severity:** Medium

**Issue:** All approval workflows, logging, and content creation depend on the sole creator. No continuity plan if creator gets sick, injured, or unavailable.

**Where it appears:** Implied throughout

**Recommended fix:**
- Add trusted backup admin account (partner/friend)
- Document emergency procedures: how to pause experiments, publish holding pattern content, handle sponsor commitments
- Add `creator_status` field to track active/paused/archived state
- Design graceful degradation: site stays up even if logging stops

# 4. MVP Scope Review

## What Should Stay in MVP

**Core Data Loop (This is the real MVP):**
- Cronometer CSV import pipeline
- Nutrition dashboard (calories, protein, basic macros)
- Basic bodyweight logging
- Basic workout session logging (simplified—just exercises/sets/reps/weight)
- Supplement checklist (daily taken/missed tracking)
- ONE baseline experiment page (30-day nutrition/training baseline)
- ONE dataset page with CSV export
- Homepage with current status
- About page with creator story
- Methodology page (how data is collected)
- Medical disclaimer page
- Affiliate disclosure page

**Rationale:** This proves the core loop: log data → import data → display data → publish data. If this works, everything else is iteration.

## What Should Move to Phase 2+

**Phase 2 (Post-Launch Iteration):**
- DEXA integration
- Bloodwork logging
- Hume/wearable imports
- Professional data explorer
- Advanced filters
- Saved views
- Compare date ranges
- Product review pages
- Multiple experiments running simultaneously
- Entity graph

**Phase 3 (Scaling):**
- LLM assistant
- VedaOps integration
- Public chatbot
- Sponsor reporting packages
- Newsletter automation
- AG Grid upgrade if needed

**Phase 4+:**
- Mobile native apps (PWA should prove demand first)
- Advanced progression algorithms
- Meal templates
- Custom food database

## What Is Missing From MVP

**Critical Missing Pieces:**
1. **Creator positioning doc** - Who is this person and why should anyone care?
2. **Legal review requirements** - What needs lawyer signoff before launch?
3. **RLS policy design** - Actual Supabase policies for every table
4. **Migration tooling decision** - Prisma? Drizzle? Raw SQL?
5. **Content storage decision** - MDX vs DB vs hybrid (recommend MDX for MVP)
6. **Launch validation plan** - How to test logging speed/ease before building everything else
7. **Privacy/redaction rules** - What gets auto-redacted from lab PDFs, screenshots
8. **Backup/export strategy** - How does creator export their own data if GoingBulk dies?
9. **Incident response plan** - What if private data leaks? What if someone gets hurt replicating a protocol?
10. **First 90 days content calendar** - What content ships when if you only have baseline data?

## What Is Too Vague to Build

**Needs Clarification:**
1. **"Professional viewer" access model** - Public? Gated? Invite-only? Freemium?
2. **Device import workflows** - Hume/Samsung/wearables mentioned but no import specs
3. **Bloodwork OCR** - "eventual" but no format/provider specified
4. **Affiliate link routing** - `/go/` structure mentioned but no click tracking specified
5. **Experiment verdict workflow** - Who decides "worked for me" vs "inconclusive"? Is there a checklist?
6. **Confounder capture UX** - Daily prompt? Manual tagging? Both?
7. **Progress photo privacy** - Face blurred? Timestamp removed? EXIF stripped?
8. **LLM draft review** - How does human approve LLM-generated weekly reports?

## Recommended Revised MVP

**Ship in 6-8 weeks:**

**Public Pages (7 total):**
1. Homepage (dashboard snapshot)
2. About (creator story + positioning)
3. Baseline Experiment page
4. Baseline Dataset page (with CSV export)
5. Methodology (how data is logged)
6. Medical Disclaimer
7. Affiliate Disclosure

**Admin Features:**
- Cronometer CSV import
- Import validation screen
- Nutrition log review
- Bodyweight logging form
- Workout session logging (simplified)
- Supplement checklist
- Basic charts (nutrition over time, bodyweight trend)

**Data Model:**
- nutrition_import_batches
- nutrition_import_rows
- nutrition_logs
- body_measurements
- workout_sessions (simplified)
- exercise_sets (simplified)
- supplement_logs
- experiments (baseline only)

**Skip for Now:**
- Entity graph
- Internal links table
- Schema records table
- Professional explorer
- Saved views
- Advanced filters
- Product reviews
- Multiple simultaneous experiments
- DEXA/bloodwork/Hume
- LLM assistant

**Success Metrics:**
- Daily logging takes <2 minutes
- Weekly Cronometer import works reliably
- Baseline experiment page is understandable to non-technical reader
- Dataset CSV is usable by Excel/Google Sheets
- Medical disclaimer is prominent and clear

**After 90 Days:**
If the above works and there's audience traction, add Phase 2 features iteratively based on actual user feedback.

# 5. Database and Schema Review

## Overall Assessment
The schema draft (doc 16) is well-structured but has critical gaps in visibility, confidence, and governance implementation.

## Critical Issues

### Issue 1: Missing Visibility Columns
**Problem:** Most tables lack the `visibility` column despite being core to the privacy model.

**Fix:**
```sql
-- Add to these tables:
ALTER TABLE nutrition_logs ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE workout_sessions ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE supplement_logs ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE measurements ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE bloodwork_results ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE dexa_results ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE progress_photos ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE experiments ADD COLUMN visibility visibility_enum DEFAULT 'private';
ALTER TABLE product_reviews ADD COLUMN visibility visibility_enum DEFAULT 'internal';
ALTER TABLE reports ADD COLUMN visibility visibility_enum DEFAULT 'private';

-- Create enum:
CREATE TYPE visibility_enum AS ENUM ('private', 'internal', 'professional', 'public');
```

### Issue 2: Missing Confidence Columns
**Problem:** Many measurement tables lack confidence tracking.

**Fix:**
```sql
-- Add to relevant tables:
ALTER TABLE nutrition_logs ADD COLUMN confidence_level confidence_enum;
ALTER TABLE measurements ADD COLUMN confidence_level confidence_enum;
ALTER TABLE bloodwork_results ADD COLUMN confidence_level confidence_enum DEFAULT 'high';
ALTER TABLE dexa_results ADD COLUMN confidence_level confidence_enum DEFAULT 'high';

CREATE TYPE confidence_enum AS ENUM ('low', 'medium', 'high', 'experimental');
```

### Issue 3: Confounder Table Needs More Structure
**Problem:** `confounder_logs` is too simple for complex confounders.

**Fix:**
```sql
CREATE TABLE confounder_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  confounder_type confounder_type_enum NOT NULL,
  severity severity_enum,
  impact_areas TEXT[], -- ['nutrition', 'training', 'sleep']
  notes TEXT,
  visibility visibility_enum DEFAULT 'private',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TYPE confounder_type_enum AS ENUM (
  'poor_sleep', 'high_stress', 'illness', 'injury', 
  'travel', 'missed_workout', 'missed_supplement', 
  'high_sodium', 'alcohol', 'deload', 'new_program', 
  'calorie_change', 'medication_change'
);

CREATE TYPE severity_enum AS ENUM ('minor', 'moderate', 'major');
```

### Issue 4: Experiment Metrics Relationship Unclear
**Problem:** `experiment_metrics` table doesn't clearly link to actual measurement tables.

**Fix:**
```sql
CREATE TABLE experiment_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  experiment_id UUID REFERENCES experiments(id),
  metric_key TEXT NOT NULL, -- 'bodyweight', 'protein_daily_avg', etc.
  metric_role metric_role_enum NOT NULL,
  source_table TEXT, -- 'measurements', 'nutrition_logs', etc.
  aggregation_method TEXT, -- 'daily_avg', 'weekly_total', etc.
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TYPE metric_role_enum AS ENUM ('primary', 'secondary', 'confounder_tracking');
```

### Issue 5: Daily Facts Needs Implementation Spec
**Problem:** `daily_facts` is described as a view/materialized view but not specified.

**Fix - Option A (View):**
```sql
CREATE VIEW daily_facts AS
SELECT 
  d.date,
  -- Nutrition
  SUM(nl.calories) as calories,
  SUM(nl.protein_g) as protein_g,
  SUM(nl.carbs_g) as carbs_g,
  SUM(nl.fat_g) as fat_g,
  SUM(nl.fiber_g) as fiber_g,
  SUM(nl.sodium_mg) as sodium_mg,
  -- Body
  m_bw.value as bodyweight_lb,
  m_waist.value as waist_in,
  -- Training
  COUNT(DISTINCT ws.id) as workouts_completed,
  SUM(es.actual_reps * es.actual_load) as training_volume_lb,
  COUNT(es.id) as sets_completed,
  -- Supplements
  (COUNT(sl.id) FILTER (WHERE sl.adherence_status = 'taken')::FLOAT / 
   NULLIF(COUNT(sl.id), 0) * 100) as supplement_adherence_pct,
  -- Confounders
  ARRAY_AGG(DISTINCT cl.confounder_type) FILTER (WHERE cl.id IS NOT NULL) as confounder_flags
FROM generate_series(
  (SELECT MIN(date) FROM nutrition_logs),
  CURRENT_DATE,
  '1 day'::interval
)::date AS d
LEFT JOIN nutrition_logs nl ON nl.date = d
LEFT JOIN measurements m_bw ON m_bw.measured_at::date = d AND m_bw.metric_key = 'bodyweight'
LEFT JOIN measurements m_waist ON m_waist.measured_at::date = d AND m_waist.metric_key = 'waist'
LEFT JOIN workout_sessions ws ON ws.date = d
LEFT JOIN exercise_sets es ON es.workout_session_id = ws.id
LEFT JOIN supplement_logs sl ON sl.date = d
LEFT JOIN confounder_logs cl ON cl.date = d
GROUP BY d.date, m_bw.value, m_waist.value;
```

**Fix - Option B (Materialized View - Recommended for Performance):**
```sql
CREATE MATERIALIZED VIEW daily_facts AS 
[same query as above];

CREATE UNIQUE INDEX ON daily_facts(date);

-- Refresh strategy
CREATE OR REPLACE FUNCTION refresh_daily_facts()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY daily_facts;
END;
$$ LANGUAGE plpgsql;

-- Trigger or cron job to refresh nightly
```

### Issue 6: Missing Audit Trail
**Problem:** No audit logging for sensitive changes.

**Fix:**
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action audit_action_enum NOT NULL,
  old_values JSONB,
  new_values JSONB,
  changed_by UUID REFERENCES users(id),
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

CREATE TYPE audit_action_enum AS ENUM ('insert', 'update', 'delete', 'visibility_change', 'approval');

CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at);
```

### Issue 7: Nutrition Import Needs Deduplication
**Problem:** No unique constraint prevents duplicate imports.

**Fix:**
```sql
ALTER TABLE nutrition_import_batches 
ADD CONSTRAINT unique_file_hash UNIQUE (file_hash);

-- Also add import row dedup
CREATE UNIQUE INDEX idx_nutrition_import_row_dedup 
ON nutrition_import_rows(batch_id, raw_date, raw_food_name, raw_calories)
WHERE status != 'rejected';
```

### Issue 8: Product/Sponsor Relationships Need Status Tracking
**Problem:** `sponsor_relationships` lacks active/inactive state.

**Fix:**
```sql
ALTER TABLE sponsor_relationships 
ADD COLUMN status sponsor_status_enum DEFAULT 'active',
ADD COLUMN disclosure_text TEXT,
ADD COLUMN contract_value_usd DECIMAL(10,2),
ADD COLUMN deliverables TEXT[];

CREATE TYPE sponsor_status_enum AS ENUM ('proposed', 'active', 'completed', 'cancelled');
```

### Issue 9: Missing Indexes for Common Queries
**Problem:** No indexes specified for common filter patterns.

**Fix:**
```sql
-- Date-based queries (most common)
CREATE INDEX idx_nutrition_logs_date ON nutrition_logs(date);
CREATE INDEX idx_workout_sessions_date ON workout_sessions(date);
CREATE INDEX idx_supplement_logs_date ON supplement_logs(date);
CREATE INDEX idx_measurements_date ON measurements(measured_at);

-- Experiment queries
CREATE INDEX idx_experiments_status ON experiments(status);
CREATE INDEX idx_experiments_dates ON experiments(baseline_start, intervention_start, followup_start);

-- Entity/page queries
CREATE INDEX idx_entities_type_slug ON entities(entity_type, slug);
CREATE INDEX idx_pages_status_type ON pages(status, page_type);

-- Visibility queries
CREATE INDEX idx_nutrition_logs_visibility ON nutrition_logs(visibility);
CREATE INDEX idx_experiments_visibility ON experiments(visibility);

-- Full-text search (future)
CREATE INDEX idx_experiments_search ON experiments USING gin(to_tsvector('english', title || ' ' || COALESCE(question, '')));
```

### Issue 10: JSON Usage Needs Constraints
**Problem:** JSONB columns have no validation.

**Fix:**
```sql
-- Add JSON schema validation for critical JSONB columns
ALTER TABLE schema_records
ADD CONSTRAINT valid_json_ld CHECK (
  json_ld IS NULL OR (
    json_ld ? '@context' AND
    json_ld ? '@type'
  )
);

-- Validate micronutrients structure
ALTER TABLE foods
ADD CONSTRAINT valid_micronutrients CHECK (
  micronutrients_json IS NULL OR (
    jsonb_typeof(micronutrients_json) = 'object'
  )
);
```

## Normalization Issues

**Generally Good:** The separation of planned vs actual (templates vs sessions) is correct.

**Issue:** `page_entities` junction table is good, but needs a `primary_entity` boolean to avoid ambiguity:

```sql
ALTER TABLE page_entities 
ADD COLUMN is_primary BOOLEAN DEFAULT false;

CREATE UNIQUE INDEX idx_page_entities_one_primary 
ON page_entities(page_id) 
WHERE is_primary = true;
```

## Recommended Schema Migration Strategy

**Tooling Decision Needed:**
Recommend **Drizzle ORM** for GoingBulk because:
- Type-safe migrations
- Great Supabase integration
- Lighter than Prisma
- SQL-first approach fits the schema governance philosophy

```typescript
// Example migration
import { sql } from 'drizzle-orm';
import { pgTable, uuid, text, timestamp, pgEnum } from 'drizzle-orm/pg-core';

export const visibilityEnum = pgEnum('visibility', ['private', 'internal', 'professional', 'public']);

export const nutritionLogs = pgTable('nutrition_logs', {
  id: uuid('id').defaultRandom().primaryKey(),
  date: date('date').notNull(),
  // ... other fields
  visibility: visibilityEnum('visibility').default('private'),
  createdAt: timestamp('created_at').defaultNow(),
});
```

## Supabase-Specific Risks

**Risk 1: RLS Performance**
Row Level Security can be slow on large tables. Daily_facts with 1000+ rows filtered by visibility might need optimization.

**Mitigation:**
- Use materialized view for daily_facts
- Add composite indexes on (visibility, date)
- Consider caching public data in Redis/Vercel KV

**Risk 2: Auth Complexity**
Supabase Auth + RLS + custom visibility logic = complexity.

**Mitigation:**
- Start with simple: owner sees all, anonymous sees only public
- Add professional role in Phase 2
- Document RLS policies clearly in codebase comments

**Risk 3: Storage Costs**
Progress photos, DEXA PDFs, bloodwork scans can get expensive.

**Mitigation:**
- Compress images before upload
- Set storage quota alerts
- Archive old photos to cheaper storage after 1 year
- Consider Cloudflare R2 for cheaper storage if Supabase costs spike

# 6. API, Auth, RLS, and Agent Access Review

## Critical Findings

### Finding 1: No API Design Specified
**Problem:** Docs say "LLMs use APIs not DB" but don't specify API design.

**Recommendation:**
```
goingbulk.com/api/v1/
  GET /experiments
  GET /experiments/:slug
  GET /experiments/:slug/data
  GET /nutrition/summary?start=YYYY-MM-DD&end=YYYY-MM-DD
  GET /training/summary?start=YYYY-MM-DD&end=YYYY-MM-DD
  GET /daily-facts?start=YYYY-MM-DD&end=YYYY-MM-DD
  
Admin-only:
  POST /imports/cronometer
  GET /imports/:id/preview
  POST /imports/:id/approve
```

Use Next.js API routes or Route Handlers. Add API key auth for LLM access.

### Finding 2: RLS Policy Design Missing
**Problem:** RLS mentioned but never designed.

**Recommended Policies:**

```sql
-- Public data access
CREATE POLICY "Public can view public nutrition logs"
ON nutrition_logs FOR SELECT
USING (visibility = 'public');

CREATE POLICY "Public can view public experiments"
ON experiments FOR SELECT
USING (visibility = 'public');

-- Admin full access
CREATE POLICY "Admin can do everything"
ON nutrition_logs FOR ALL
USING (auth.uid() = (SELECT id FROM users WHERE role = 'owner'));

-- Professional viewer access (Phase 2)
CREATE POLICY "Professional can view professional data"
ON nutrition_logs FOR SELECT
USING (
  visibility IN ('public', 'professional') 
  AND auth.uid() IN (SELECT id FROM users WHERE role IN ('professional', 'owner'))
);

-- Default deny
ALTER TABLE nutrition_logs ENABLE ROW LEVEL SECURITY;
```

Repeat for every table with sensitive data.

### Finding 3: No Admin Permission Model
**Problem:** Only mentions "owner" role but doesn't define permission granularity.

**Recommendation:**
```sql
CREATE TYPE user_role_enum AS ENUM ('owner', 'admin', 'editor', 'professional_viewer', 'public');

CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  role user_role_enum DEFAULT 'public',
  permissions TEXT[], -- ['approve_imports', 'publish_pages', 'edit_experiments']
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

For MVP: Only 'owner' role needed. Add others in Phase 2.

### Finding 4: API Rate Limiting Not Mentioned
**Problem:** Public API access without rate limits = abuse risk.

**Recommendation:**
```typescript
// Middleware
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(100, "1 h"), // 100 requests per hour
});

export async function middleware(request: Request) {
  const ip = request.headers.get("x-forwarded-for");
  const { success } = await ratelimit.limit(ip);
  
  if (!success) {
    return new Response("Rate limit exceeded", { status: 429 });
  }
}
```

### Finding 5: Export Permissions Unclear
**Problem:** Who can export what data?

**Recommendation:**
```
Public: Can export own public datasets as CSV
Professional: Can export public + professional data
Admin: Can export everything
Anonymous: Can export public datasets only (with rate limit)

Implement via API:
GET /api/v1/exports/:dataset_slug/csv
  - Check user role
  - Check dataset visibility
  - Return CSV or 403
```

### Finding 6: Approval Queue Not Implemented
**Problem:** Approval workflow described but not designed.

**Recommendation:**
```sql
CREATE TABLE approval_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_type approval_action_enum NOT NULL,
  resource_type TEXT NOT NULL, -- 'experiment', 'import', 'page'
  resource_id UUID NOT NULL,
  requested_by UUID REFERENCES users(id),
  requested_at TIMESTAMPTZ DEFAULT NOW(),
  status approval_status_enum DEFAULT 'pending',
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  metadata JSONB -- context-specific data
);

CREATE TYPE approval_action_enum AS ENUM (
  'publish_experiment', 'approve_import', 'activate_affiliate_link', 
  'publish_bloodwork', 'change_experiment_verdict'
);

CREATE TYPE approval_status_enum AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
```

### Finding 7: LLM API Key Management Missing
**Problem:** How do LLM tools authenticate?

**Recommendation:**
```sql
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key_hash TEXT UNIQUE NOT NULL, -- bcrypt hash of actual key
  name TEXT NOT NULL, -- "LLM Assistant", "VEDA Integration"
  scopes TEXT[], -- ['read:experiments', 'read:nutrition']
  rate_limit_per_hour INTEGER DEFAULT 100,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  revoked BOOLEAN DEFAULT false
);

-- Usage log
CREATE TABLE api_key_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_key_id UUID REFERENCES api_keys(id),
  endpoint TEXT NOT NULL,
  status_code INTEGER,
  used_at TIMESTAMPTZ DEFAULT NOW()
);
```

Generate keys like: `gbulk_sk_[random]`, store hash, check on each request.

### Finding 8: Write Operations Need Extra Protection
**Problem:** Imports and logging are write operations that could corrupt data.

**Recommendation:**
```typescript
// API middleware
export async function requireWritePermission(req, action: string) {
  const user = await getUser(req);
  
  if (!user) {
    throw new Error("Authentication required");
  }
  
  if (user.role !== 'owner' && user.role !== 'admin') {
    throw new Error("Insufficient permissions");
  }
  
  // Log all write operations
  await auditLog({
    action,
    user_id: user.id,
    ip: req.ip,
    timestamp: new Date()
  });
}
```

### Finding 9: Public vs Professional Visibility Needs UI Toggle
**Problem:** How do professionals switch between views?

**Recommendation:**
```typescript
// URL param or toggle
/experiments/creatine-test?view=professional

// UI Component
<ViewToggle 
  current="public" 
  available={user?.role === 'professional' ? ['public', 'professional'] : ['public']}
  onChange={setView}
/>
```

Professionals see extra sections:
- Methodology details
- Source/confidence tables
- Confounder breakdown
- Export links

### Finding 10: No API Documentation Plan
**Problem:** External LLM tools need API docs.

**Recommendation:**
Use OpenAPI/Swagger spec:
```yaml
# openapi.yaml
paths:
  /api/v1/experiments:
    get:
      summary: List experiments
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [baseline, active, completed]
        - name: visibility
          in: query
          schema:
            type: string
            enum: [public, professional]
```

Generate docs with Scalar or Redoc.

## Security Checklist

Before launch:
- [ ] RLS enabled on all tables with sensitive data
- [ ] RLS policies tested for every user role
- [ ] API rate limiting implemented
- [ ] API key authentication working
- [ ] Audit logging active for all write operations
- [ ] CORS configured (only allow goingbulk.com origin)
- [ ] SQL injection prevention (use parameterized queries)
- [ ] XSS prevention (sanitize user input, use Content Security Policy)
- [ ] HTTPS enforced
- [ ] Secrets in environment variables, not code
- [ ] Database backups automated
- [ ] Incident response plan documented

# 7. Professional Data Explorer Review

## Overall Assessment
The professional explorer is well-conceived but over-scoped for MVP. The doc correctly identifies TanStack Table as the right choice over AG Grid for Phase 1.

## Critical Issues

### Issue 1: Daily Facts Performance Not Validated
**Problem:** Filtering/sorting 1000+ daily_facts rows in browser could be slow.

**Recommendation:**
- Start with server-side filtering/sorting/pagination
- Use Tanstack Table with manual pagination mode
- API endpoint: `GET /api/v1/professional/daily-facts?page=1&limit=50&sort=date_desc&filter[protein_min]=180`
- Test with 1000 rows before launch
- If slow, add Redis cache for common filters

### Issue 2: Saved Views Not Scoped
**Problem:** Should saved views be per-user or global? Anonymous or auth-required?

**Recommendation for MVP:**
- Skip user accounts initially
- Saved views = shareable URL params
- Example: `/pro?view=high-protein-low-sleep` loads preset filters
- Phase 2: Add user accounts + saved views table

### Issue 3: Missing Confounder Filters
**Problem:** Filtering out illness/travel days is mentioned but not designed.

**Recommendation:**
```typescript
interface ProfessionalFilters {
  dateRange: { start: string; end: string };
  experiments?: string[];
  
  // Nutrient filters
  proteinMin?: number;
  proteinMax?: number;
  caloriesMin?: number;
  caloriesMax?: number;
  sodiumMax?: number;
  fiberMin?: number;
  
  // Training filters
  trainingVolumeMin?: number;
  workoutsMin?: number;
  
  // Body filters
  bodyweightMin?: number;
  bodyweightMax?: number;
  
  // Exclude confounders
  excludeConfounders?: ConfounderType[];
  
  // Source filters
  sources?: string[]; // ['cronometer', 'manual', 'hume']
  confidenceLevels?: string[]; // ['high', 'medium']
  
  // Supplement filters
  supplementsUsed?: string[];
  adherenceMin?: number; // %
}
```

### Issue 4: Compare Periods UX Undefined
**Problem:** Doc mentions comparing periods but doesn't show UI.

**Recommendation:**
```
[Period A: Jan 1-31] vs [Period B: Feb 1-28]

Metric           | Period A | Period B | Change
Avg Protein      | 182g     | 194g     | +12g (+6.6%)
Avg Bodyweight   | 184.2lb  | 187.8lb  | +3.6lb (+2.0%)
Training Volume  | 42.3k    | 47.8k    | +5.5k (+13%)
```

Use side-by-side date range pickers + diff view.

### Issue 5: Export Formats Not Prioritized
**Problem:** Lists CSV, JSON, PDF, chart images—all are work.

**MVP Priority:**
1. CSV (critical for Excel/R/Python users)
2. JSON (future API consumers)
3. PDF summary (Phase 2)
4. Chart images (Phase 2)

CSV must include:
- All visible columns
- Current filters applied
- Metadata header (date range, filters, generated timestamp)

### Issue 6: Missing Workflows Doctors/Nutritionists Need

**Recommended Additions:**

**For Doctors:**
- Filter: "Show all days with bloodwork within ±14 days" (see nutrition/training context around lab dates)
- Filter: "Show days with blood pressure >140/90"
- View: "Supplement usage during abnormal lab results"
- Export: "Pre-visit summary package" (bloodwork + 30-day nutrition/training/supplement context)

**For Nutritionists:**
- Filter: "Days below fiber target"
- Filter: "High sodium days (>3000mg)"
- View: "Protein consistency score" (% of days hitting target ±10g)
- View: "Macro distribution trends over time"
- Export: "Nutrition adherence report"

**For Coaches:**
- Filter: "Incomplete workout days"
- View: "Volume progression by muscle group"
- View: "Recovery markers" (sleep + HRV if available)
- View: "Deload periods and performance response"
- Export: "Training block summary"

### Issue 7: No Empty State Design
**Problem:** What if professional views a time range with no data?

**Recommendation:**
```
No data available for this filter combination.

Suggestions:
- Expand date range
- Remove some filters
- Check if data was logged during this period
```

### Issue 8: Column Visibility Needs Defaults
**Problem:** Too many columns = overwhelming.

**Default Column Sets:**

**Nutrition Focus:**
- Date, Calories, Protein, Carbs, Fat, Fiber, Sodium, Bodyweight, Notes

**Training Focus:**
- Date, Workouts, Sets, Volume, Bodyweight, Sleep, Notes

**Supplement Focus:**
- Date, Supplements Taken, Adherence %, Bodyweight, Training Volume, Notes

**Full View:**
- All columns available but user must enable

### Issue 9: Performance Budget Not Defined
**Problem:** No loading time requirements.

**Recommendation:**
- Initial page load: <2 seconds
- Filter change: <500ms
- CSV export generation: <5 seconds for 1 year of data
- If slower, add "generating..." progress indicator

### Issue 10: Privacy Risk in Shared URLs
**Problem:** If saved views are URL params, sharing link = sharing data visibility.

**Mitigation:**
```
/pro?view=saved-view-id-abc123

Where saved-view-id encodes:
- Filters
- Column visibility
- Sort order

But NOT the data itself.

When shared, recipient sees:
- Public data only (if anonymous)
- Professional data only (if professional account)
- Same filters applied to their permission level
```

## Recommended Professional Explorer MVP

**Phase 1 (Include in MVP if resources allow, otherwise defer to Phase 2):**
- Daily facts table with basic filters
- Date range picker
- Protein/calorie/bodyweight filters
- Column visibility toggle
- Sort by date/metric
- CSV export
- URL-based filter state (shareable)

**Phase 2:**
- Compare periods side-by-side
- Advanced confounder filters
- Saved views (with accounts)
- JSON export
- Source/confidence filters

**Phase 3:**
- PDF summary reports
- Chart builder
- Correlation analysis
- Professional account invites

# 8. SEO/GEO/LLM Citation Review

## Overall Assessment
The SEO/GEO strategy (docs 13, 14) is sophisticated and well-researched. However, it makes a critical unfounded assumption: that AI systems will cite personal N=1 data.

## Critical Issues

### Issue 1: Unfounded Citation Authority Assumption
**Problem:** The docs assume AI systems will cite GoingBulk alongside Mayo Clinic.

**Reality Check:**
- LLMs prefer authoritative medical sources
- N=1 data is explicitly low evidence quality
- Personal blogs rarely get AI citations unless they're the only source

**Recommendation:**
Position for SEO/human traffic, not AI citation. Realistic positioning:
> "GoingBulk may appear in 'personal experience' or 'case study' contexts, not clinical guidance. Focus on long-tail queries like 'real person creatine results' rather than 'does creatine work'."

### Issue 2: Entity Graph Overengineered for MVP
**Problem:** Full entity graph, internal links table, schema records table = months of work.

**MVP Recommendation:**
- Skip entity graph database tables initially
- Use simple page relationships via frontmatter
```yaml
# experiment.mdx
---
title: "Creatine 90-Day Test"
entities: ["creatine", "training-volume", "bodyweight"]
products: ["brand-x-creatine"]
related_methodology: ["supplement-tracking"]
---
```
- Generate schema.org JSON-LD from frontmatter
- Add full entity graph in Phase 2

### Issue 3: Schema Strategy Needs Validation
**Problem:** Using Dataset schema for N=1 experiments is questionable.

**Research Needed:**
- Google Dataset Search guidelines say datasets should be "broadly useful"
- N=1 personal data may not qualify
- Test with small dataset first, monitor Search Console

**Conservative Recommendation:**
Use:
- Article schema for experiment pages ✓
- Person schema for creator ✓
- WebPage schema for methodology ✓
- Review schema for product pages ✓

Avoid:
- MedicalWebPage (too risky without medical credentials)
- Dataset (until proven Google accepts N=1 data)

### Issue 4: Crawlable Table Summaries Missing from Examples
**Problem:** Docs say "every chart needs plain text" but don't show implementation.

**Recommendation:**
```tsx
// ExperimentPage.tsx
<section>
  <h2>Results Summary</h2>
  
  {/* Crawlable text first */}
  <p>
    During the 90-day creatine intervention (Jan 1 - Mar 31, 2027), 
    bodyweight increased from 184.2 lb to 187.8 lb (+3.6 lb), 
    average daily protein was 194g (target: 180g), 
    and training volume increased from 42,300 lb/week to 47,800 lb/week (+13%).
  </p>
  
  {/* Interactive chart below */}
  <Chart data={experimentData} />
  
  {/* Quick Facts table - also crawlable */}
  <table>
    <tr><td>Baseline Bodyweight</td><td>184.2 lb</td></tr>
    <tr><td>Final Bodyweight</td><td>187.8 lb</td></tr>
    <tr><td>Change</td><td>+3.6 lb (+2.0%)</td></tr>
  </table>
</section>
```

### Issue 5: Canonical vs Noindex Rules Need Examples
**Problem:** Principles stated but no regex patterns or Next.js config.

**Recommendation:**
```typescript
// next-sitemap.config.js
module.exports = {
  siteUrl: 'https://goingbulk.com',
  generateRobotsTxt: true,
  
  // Exclude dynamic filter pages
  exclude: [
    '/pro/data-explorer',
    '/admin/*',
    '/api/*'
  ],
  
  robotsTxtOptions: {
    policies: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/pro/', '/admin/', '/api/']
      }
    ]
  }
}
```

```tsx
// app/pro/data-explorer/page.tsx
export const metadata = {
  robots: {
    index: false,
    follow: false
  }
}
```

### Issue 6: Internal Linking Strategy Not Automated
**Problem:** Docs describe internal linking rules but not implementation.

**Recommendation - Phase 1 (Manual):**
- MDX components for common links
```tsx
<EntityLink entity="creatine" />
// Renders: <a href="/supplements/creatine">creatine</a>
```

**Recommendation - Phase 2 (Semi-Automated):**
```typescript
// Build-time script
function suggestInternalLinks(content: string, existingLinks: string[]) {
  const entities = extractEntities(content);
  return entities
    .filter(e => !existingLinks.includes(e.url))
    .map(e => ({
      text: e.name,
      url: e.url,
      context: "appears 3 times but not linked"
    }));
}
```

### Issue 7: Quick Facts Blocks Need Component
**Problem:** Every page should have Quick Facts but no reusable component specified.

**Recommendation:**
```tsx
// components/QuickFacts.tsx
interface QuickFact {
  label: string;
  value: string;
}

export function QuickFacts({ facts, className }: { facts: QuickFact[], className?: string }) {
  return (
    <aside className={cn("quick-facts", className)} aria-label="Quick Facts">
      <h2>Quick Facts</h2>
      <dl>
        {facts.map(f => (
          <div key={f.label}>
            <dt>{f.label}</dt>
            <dd>{f.value}</dd>
          </div>
        ))}
      </dl>
    </aside>
  );
}

// Usage in experiment page
<QuickFacts facts={[
  { label: "Type", value: "N=1 personal experiment" },
  { label: "Duration", value: "90 days (Jan 1 - Mar 31, 2027)" },
  { label: "Primary Metric", value: "Bodyweight and training volume" },
  { label: "Confidence", value: "Medium (some confounders present)" }
]} />
```

### Issue 8: Citation Summary Format Undefined
**Problem:** Citation summaries mentioned but no specific format.

**Recommendation:**
```markdown
## Citation Summary

GoingBulk's 90-Day Creatine Test (January 1 - March 31, 2027) was a personal N=1 experiment tracking daily creatine monohydrate supplementation (5g/day), bodyweight, training volume, and nutrition. Bodyweight increased 3.6 lb (184.2 → 187.8 lb) and training volume increased 13% (42.3k → 47.8k lb/week) during the intervention period. Nutrition averaged 2,780 kcal/day and 194g protein/day. Limitations include N=1 design, concurrent training program changes, and inability to isolate creatine's effect from other factors. This experiment does not prove creatine causes weight gain and should not be used for medical guidance.

**Suggested Citation:** GoingBulk. (2027). 90-Day Creatine Monohydrate Personal Experiment [Dataset]. https://goingbulk.com/experiments/creatine-90-day-test
```

### Issue 9: Launch Content Map Too Ambitious
**Problem:** Doc 23 lists 30+ pages for launch.

**Revised Launch Minimum:**

**Critical Pages (Launch Blockers):**
1. Homepage
2. About / Creator Story
3. First Experiment Page
4. First Dataset Page
5. Methodology
6. Medical Disclaimer
7. Affiliate Disclosure

**Helpful But Not Blocking:**
8. Nutrition Hub
9. Training Hub
10. Supplements Hub

**Defer to Post-Launch:**
- All glossary pages except those directly referenced in experiment
- All entity pages except those in first experiment
- Professional explorer
- Product review pages (if no products reviewed yet)
- Multiple experiments

### Issue 10: llms.txt Strategy Mentioned but Not Designed
**Problem:** Doc 14 mentions llms.txt but gives no specifics.

**Recommendation:**
```
# https://goingbulk.com/llms.txt

# GoingBulk - Personal Fitness Experiments

GoingBulk is a personal fitness tracking project documenting nutrition, training, supplements, body composition, bloodwork, and structured N=1 experiments.

## Important Context
- All experiments are N=1 personal documentation, not clinical research
- Data should not be used for medical advice or treatment decisions
- Creator is not a medical professional

## Key Pages
- About: /about
- Experiments: /experiments
- Methodology: /methodology
- Medical Disclaimer: /medical-disclaimer

## Data Access
- Public datasets available at /data
- Professional data explorer at /for-professionals
- API documentation at /api/docs

## Limitations
- Single subject (N=1)
- Confounders present in all experiments
- Observational data, not controlled trials
- Equipment/measurement limitations documented per experiment
```

## SEO Quick Wins for Launch

1. **Optimize for Long-Tail N=1 Queries**
   - "Real person creatine results before after"
   - "DEXA scan vs Hume accuracy comparison"
   - "Cronometer export analysis"

2. **Structured Data Priority**
   - Person schema (creator)
   - Article schema (experiments)
   - Review schema (products)
   - BreadcrumbList

3. **Technical SEO Checklist**
   - sitemap.xml
   - robots.txt
   - canonical tags
   - meta descriptions
   - Open Graph tags
   - Core Web Vitals optimization

4. **Internal Linking**
   - Every experiment → methodology
   - Every experiment → related entities (when they exist)
   - Hub pages → all child pages
   - Glossary terms → experiments that use them

# 9. Content, Editorial, and Claim Safety Review

## Critical Risks

### Risk 1: Medical Claims Creep
**Severity:** Critical

**Problem:** Even with N=1 disclaimers, phrasing like "creatine increased my training volume" could be interpreted as medical advice.

**Examples of Dangerous Phrasing:**
- ❌ "Creatine increased my strength"
- ❌ "This supplement lowered my blood pressure"
- ❌ "High protein improved my body composition"

**Safer Phrasing:**
- ✅ "My training volume increased during creatine use, but this N=1 experiment cannot prove causation"
- ✅ "My blood pressure was lower during this period, but many confounders were present"
- ✅ "My body composition changed while eating higher protein, but I was also training differently"

**Recommended Wording Checklist:**
Create a pre-publish checklist enforced by LLM review:
```
- [ ] No causal language (caused, cured, fixed, proven)
- [ ] N=1 limitation stated clearly
- [ ] Confounders acknowledged
- [ ] "Associated with" or "during" language used
- [ ] "Not medical advice" disclaimer present
- [ ] No universal claims ("everyone should...")
```

### Risk 2: Supplement Safety Claims
**Severity:** Critical

**Problem:** Publishing supplement protocols could encourage unsafe self-experimentation.

**Mitigation:**
Every supplement experiment page must include:
```
⚠️ IMPORTANT SAFETY DISCLAIMER

This is a personal N=1 experiment documenting my own supplement use. 

DO NOT replicate this protocol without:
- Consulting your doctor
- Reviewing potential drug interactions
- Understanding contraindications
- Considering your personal health conditions

Supplements can have serious side effects and interactions. What I did is not a recommendation for what you should do.
```

### Risk 3: Blood Pressure / Glucose Experiments
**Severity:** Critical

**Problem:** Publishing experiments that track blood pressure or glucose could be interpreted as medical guidance for hypertension or diabetes.

**Mitigation:**
Extremely prominent disclaimers:
```
⚠️ MEDICAL DISCLAIMER - BLOOD PRESSURE TRACKING

I tracked my blood pressure as part of personal health monitoring. This is NOT medical advice for hypertension or cardiovascular health.

If you have high blood pressure:
- See a doctor, not a blog
- Do not change medications based on my data
- Do not replicate my interventions

This data is for personal documentation only.
```

Similar for glucose/HbA1c tracking.

### Risk 4: Progress Photos Without Consent
**Severity:** High

**Problem:** Public progress photos could be misused (stolen for fake ads, used in commercial contexts).

**Mitigation:**
- Watermark all progress photos with "GoingBulk.com - Not for commercial use"
- Include visible date stamps
- Consider face blurring for privacy
- Strip EXIF data
- Add copyright footer: "© 2027 GoingBulk. Personal use only."

### Risk 5: DEXA / Bloodwork Data Privacy
**Severity:** High

**Problem:** Lab reports contain PII (name, DOB, address, patient ID).

**Required Redaction Process:**
Before publishing any lab document:
1. Redact full name
2. Redact DOB (show age range or year only)
3. Redact address
4. Redact patient ID / account numbers
5. Redact lab location (city/state okay, not full address)
6. Redact insurance information
7. Keep only: test date, marker names, values, reference ranges

### Risk 6: Sponsor Influence on Verdicts
**Severity:** High

**Problem:** Even with disclosure, sponsor payments could bias "would-use-if-not-paid" verdicts.

**Mitigation:**
- Track verdict decisions BEFORE sponsor contact
- If verdict changes after sponsor contact, explain why prominently
- Never delete negative reviews after sponsor contact
- Consider third-party review audit (professional nutritionist/doctor validates claims)

### Risk 7: Overclaiming from Correlations
**Severity:** Medium-High

**Problem:** "My protein went up and my strength went up" could imply causation.

**Required Pattern:**
```
During the high protein period (180g → 210g/day):
- Bodyweight: 184 → 187 lb
- Bench press 1RM estimate: 225 → 235 lb

However, I also:
- Started a new training program
- Increased overall calories
- Improved sleep consistency

The strength gain cannot be attributed to protein alone.
```

### Risk 8: Research Misrepresentation
**Severity:** Medium-High

**Problem:** Experiment framework doc shows research review but doesn't prevent cherry-picking or misrepresentation.

**Required Research Review Template:**
```markdown
## Research Review: [Claim]

**Original Study:** [Title, Authors, Year, Journal]
**Link:** [DOI or PubMed URL]

**Study Design:** [RCT, meta-analysis, observational, etc.]
**Population:** [N=?, demographics, health status]
**Intervention:** [What exactly was tested]
**Control:** [What was the comparison]
**Duration:** [How long]
**Primary Outcome:** [What was measured]
**Result:** [Effect size, confidence interval, p-value if relevant]
**Limitations:** [What the authors noted]

**My Protocol Differences:**
- Population: I am [age, sex, training status] vs study used [X]
- Dose: I used [X] vs study used [Y]
- Duration: I tracked for [X] vs study ran [Y]
- Context: I was [training/cutting/bulking] vs study participants were [Z]

**Why These Differences Matter:**
[Explain why results might differ]
```

### Risk 9: No Editorial Review Process
**Severity:** Medium

**Problem:** Single creator writing, publishing, and approving without external review = bias risk.

**Recommendation for MVP:**
- Creator writes and self-reviews (acceptable for launch)
- Add review checklist before publish (claim safety, disclaimer presence, citation accuracy)

**Recommendation for Phase 2:**
- Invite professional reviewer (RD, exercise scientist, doctor)
- Reviewer doesn't edit content but flags concerns
- Add "Reviewed by [Name, Credentials]" to methodology pages

### Risk 10: Experiment Verdict Changes
**Severity:** Medium

**Problem:** What if creator's verdict changes months later?

**Recommendation:**
Track verdict history:
```sql
CREATE TABLE experiment_verdict_history (
  id UUID PRIMARY KEY,
  experiment_id UUID REFERENCES experiments(id),
  verdict TEXT NOT NULL,
  reasoning TEXT,
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  changed_by UUID REFERENCES users(id)
);
```

Show on page:
```
Current Verdict: Worth using
Updated: March 15, 2027

Previous Verdict: Inconclusive (Jan 31, 2027)
Reason for change: Continued use for 60 additional days showed clearer pattern.
```

## Content Quality Issues

### Issue 1: No Writing Style Guide
**Problem:** Tone described as "curious, transparent, skeptical but fair" but not operationalized.

**Recommendation:**
Create `27-writing-style-guide.md`:
```markdown
# GoingBulk Writing Style Guide

## Voice
- First person ("I tracked", "My bodyweight increased")
- Direct and honest
- Skeptical of hype
- Transparent about limitations
- No drama or clickbait

## Forbidden Phrases
- "This one weird trick..."
- "Doctors hate this..."
- "Proven to..."
- "Guaranteed results..."
- "You need to..."

## Required Elements
Every experiment page must include:
- N=1 disclaimer
- Confounders section
- Limitations section
- Source/confidence labels
- No medical advice disclaimer
```

### Issue 2: Glossary Terms Undefined
**Problem:** No glossary term creation criteria.

**Recommendation:**
Add to glossary only if:
- Term appears in 3+ experiments/pages
- Term needs consistent definition across site
- Term is GoingBulk-specific ("protein target hit rate") or commonly confused

Skip thin definitional pages for generic fitness terms well-covered elsewhere.

### Issue 3: Experiment Template Not Provided
**Problem:** Framework described but no actual template.

**Recommendation:**
```markdown
# [Experiment Name]

## Quick Facts
- Type: N=1 personal experiment
- Duration: [X days/weeks]
- Dates: [Start] to [End]
- Status: [Baseline/Active/Completed]
- Primary Metrics: [List]
- Confidence: [Low/Medium/High]

## Claim or Question
[What are you testing?]

## Research Review
[What does the research say? Link to studies. Note population differences.]

## My Protocol
[Exactly what you did, daily dose, timing, etc.]

## Baseline
[Pre-intervention data summary]

## Intervention
[During-intervention data summary]

## Results
[Key findings with numbers]

## Confounders
[What else changed? What could explain the results instead?]

## Limitations
[Why this experiment might not apply to others]

## Personal Verdict
[Worth continuing? Would you do again? Why or why not?]

## Related Pages
- Methodology: [How this data was collected]
- Product: [If testing a product]
- Dataset: [Downloadable data]
```

# 10. Privacy, Health, and Legal Risk Review

## Critical Risks

### Risk 1: HIPAA-Adjacent Content
**Severity:** Critical

**Issue:** While HIPAA doesn't apply to personal health blogs, publishing detailed bloodwork/medical records creates privacy expectations.

**Concerns:**
- If GoingBulk ever accepts professional viewers with accounts, does it become a "business associate" if doctors use it for patient care? (Unlikely but worth legal review)
- Progress photos with identifiable features = potential doxxing target
- Location data in device exports could reveal home/work addresses

**Mitigation:**
- Legal review before launch
- Clear privacy policy: "Data I publish about myself is voluntary. No doctor-patient relationship exists."
- If adding professional accounts, consult HIPAA lawyer
- Strip GPS coordinates from all uploads
- Consider pseudonymization even for self (use "the creator" not real name in data)

### Risk 2: Supplement Adverse Event Liability
**Severity:** Critical

**Issue:** If someone replicates a supplement protocol from GoingBulk and has an adverse reaction, could the creator be liable?

**Mitigation:**
- Strong disclaimer on every supplement experiment page
- "I am not a doctor, nutritionist, or medical professional"
- "Supplements can cause serious adverse effects"
- "Consult your doctor before taking any supplement"
- Consider disclaimer popup on first visit (age gate + liability acknowledgment)
- Liability insurance (consult insurance agent about blogger liability coverage)

### Risk 3: Blood Pressure / Glucose Self-Tracking Without Medical Supervision
**Severity:** Critical

**Issue:** Documenting BP/glucose experiments could encourage people with hypertension/diabetes to self-experiment instead of seeking medical care.

**Mitigation:**
- Extremely prominent disclaimers
- "If you have high blood pressure, see a doctor immediately. Do not delay medical care because of anything you read here."
- Consider NOT publishing blood pressure experiments publicly
- Or only publish to professional-gated audience

### Risk 4: Progress Photos Stolen / Misused
**Severity:** High

**Issue:** Fitness transformation photos are frequently stolen for fake ads, scam products, etc.

**Mitigation:**
- Watermark every photo prominently
- Copyright notice in image metadata
- DMCA takedown agent designated (can be creator)
- Consider face blurring or cropping
- Disable right-click save (minor deterrent)
- Monitor reverse image search for misuse

### Risk 5: DEXA / Lab Report PII Leakage
**Severity:** High

**Issue:** Lab reports contain name, DOB, address, patient ID.

**Required Redaction Checklist:**
```
Before publishing any lab document:
[ ] Full name redacted (or use pseudonym)
[ ] Date of birth redacted (age range okay)
[ ] Full address redacted (city/state okay)
[ ] Patient ID / MRN redacted
[ ] Phone number redacted
[ ] Email redacted (if present)
[ ] Insurance info redacted
[ ] Lab facility full address redacted
[ ] Physician name redacted (unless creator approves)
[ ] Only kept: test date, marker names, values, reference ranges
```

Tools: Adobe Acrobat redaction (permanent removal, not just black boxes)

### Risk 6: Device Data Reverse Engineering Location
**Severity:** Medium-High

**Issue:** Wearable/Hume exports may include timestamps precise enough to infer daily schedule, home location.

**Mitigation:**
- Truncate timestamps to hour granularity for public data
- Never publish raw GPS coordinates
- Review device export files before import (check for hidden location data)
- If showing time-series data, use relative time ("Day 1, Hour 0") not absolute timestamps

### Risk 7: Sponsor Contract IP Issues
**Severity:** Medium-High

**Issue:** If sponsor provides product for review, contract may claim rights to content or restrict negative reviews.

**Mitigation:**
- Never sign contract that restricts editorial independence
- Contracts must allow negative or neutral reviews
- Contracts must allow data to remain public after sponsorship ends
- Have contracts reviewed by lawyer
- Publish contract summary: "Sponsor provided product. Editorial independence maintained. Negative reviews permitted."

### Risk 8: Professional Viewer Data Leakage
**Severity:** Medium

**Issue:** If doctors/nutritionists access professional data, could their session leak data to other patients if they use shared computers?

**Mitigation:**
- Session timeout (15 min inactivity)
- No "remember me" option for professional accounts
- Clear session on browser close
- Warning banner: "Do not access on shared computers"

### Risk 9: Email Collection Without Privacy Policy
**Severity:** Medium

**Issue:** Newsletter signup collects emails = data collection = privacy policy required.

**Mitigation:**
- Privacy policy page before launch
- GDPR-compliant if any EU visitors (likely)
- State: what data collected, why, how long stored, how to delete
- Use privacy-friendly email provider (ConvertKit, Buttondown)
- Add unsubscribe link to every email

### Risk 10: Third-Party Service Data Sharing
**Severity:** Medium

**Issue:** Supabase, Vercel, analytics providers have their own privacy policies.

**Mitigation:**
Privacy policy must disclose:
- Hosting: Vercel (privacy policy link)
- Database: Supabase (privacy policy link)
- Analytics: [If using Plausible/Fathom/etc]
- Email: [ConvertKit/etc]
- Payment processing if accepting sponsors: Stripe

State: "These services may collect data as described in their policies."

## Privacy Policy Requirements

**Minimum Sections:**
1. What data we collect
   - Name/email (newsletter)
   - Usage data (analytics)
   - Comments if added
2. Why we collect it
   - Newsletter delivery
   - Site improvement
   - Abuse prevention
3. How we use it
   - Send updates
   - Understand traffic
   - No selling to third parties
4. How long we keep it
   - Until unsubscribe
   - Analytics aggregated after 30 days
5. Your rights
   - Access your data
   - Delete your data
   - Export your data
   - Unsubscribe anytime
6. Contact
   - Email for privacy questions

## Medical Disclaimer Requirements

**Minimum Content:**
```
MEDICAL DISCLAIMER

GoingBulk is a personal documentation project, not medical advice.

1. I am not a doctor, dietitian, nutritionist, or licensed healthcare provider.

2. All experiments are N=1 personal tracking. They are not clinical studies.

3. Do not use this information to diagnose, treat, or prevent any disease.

4. Do not replicate experiments without consulting your doctor.

5. Supplements, dietary changes, and exercise programs can have serious risks.

6. If you have a medical condition, are taking medication, or are pregnant, 
   consult your doctor before making any changes to diet, exercise, or supplements.

7. In case of medical emergency, call 911 (US) or your local emergency number.

This site is for informational and entertainment purposes only.

Last updated: [Date]
```

Place in footer of every page, not just a separate disclaimer page.

# 11. Monetization and Sponsor Trust Review

## Critical Risks

### Risk 1: Undisclosed Affiliate Links
**Severity:** Critical

**Issue:** FTC requires clear disclosure of affiliate relationships BEFORE the link.

**Current Compliance Gap:**
Docs mention disclosure pages but don't specify per-page disclosure.

**Required Fix:**
```tsx
// Every page with affiliate links needs this component
<AffiliateDisclosure>
  This page contains affiliate links. If you purchase through these links, 
  I may earn a commission at no extra cost to you. This does not influence 
  my opinions or recommendations. See full <Link href="/affiliate-disclosure">
  affiliate disclosure</Link>.
</AffiliateDisclosure>
```

Must appear BEFORE first affiliate link, not just in footer.

### Risk 2: "Would Use If Not Paid" Question Creates Verification Problem
**Severity:** High

**Issue:** This is brilliant for trust BUT creates accountability risk. What if creator says "yes" then immediately stops using after payment ends?

**Mitigation:**
Track usage after review:
```sql
ALTER TABLE product_reviews 
ADD COLUMN usage_continued_after_payment BOOLEAN,
ADD COLUMN usage_continued_verified_date DATE,
ADD COLUMN usage_discontinued_reason TEXT;
```

Update verdict if usage stops:
```
Update (June 2027): I originally said I would keep using this product, but 
I discontinued it 30 days after the sponsored period ended because [reason].
```

Honesty >> consistency. Changing answer builds trust if explained.

### Risk 3: Sponsored Experiments Could Bias Protocols
**Severity:** High

**Issue:** If sponsor pays for "creatine test," creator has incentive to design protocol favorable to creatine.

**Mitigation:**
- Protocol designed BEFORE sponsor contact
- Protocol and baseline data published BEFORE intervention starts (can't fudge afterward)
- Commit to publishing results even if negative
- Contract must explicitly allow negative results
- If protocol changes after sponsor contact, disclose what changed and why

### Risk 4: Product Affiliate Database Not Designed
**Severity:** Medium-High

**Issue:** Affiliate links table exists but no commission tracking, click tracking, or revenue tracking.

**Recommendation:**
```sql
CREATE TABLE affiliate_link_clicks (
  id UUID PRIMARY KEY,
  affiliate_link_id UUID REFERENCES affiliate_links(id),
  clicked_at TIMESTAMPTZ DEFAULT NOW(),
  ip_hash TEXT, -- hashed for privacy
  referrer TEXT,
  user_agent TEXT,
  converted BOOLEAN DEFAULT false, -- set via webhook/API
  commission_amount DECIMAL(10,2)
);

ALTER TABLE affiliate_links
ADD COLUMN total_clicks INTEGER DEFAULT 0,
ADD COLUMN total_conversions INTEGER DEFAULT 0,
ADD COLUMN total_commission_usd DECIMAL(10,2) DEFAULT 0;
```

Helps answer: "Is affiliate strategy working?"

### Risk 5: Sponsor Relationship Status Not Publicly Visible
**Severity:** Medium-High

**Issue:** Product page should show current sponsor status, not just historical.

**Recommendation:**
```tsx
// ProductReviewPage
<SponsorStatus>
  {sponsorRelationship.status === 'active' ? (
    <>
      <AlertIcon /> Active Sponsor Relationship
      <p>I am currently receiving {sponsorRelationship.compensation_type} from {brand.name}.</p>
    </>
  ) : sponsorRelationship.status === 'completed' ? (
    <>
      Previous Sponsor ({sponsorRelationship.start_date} to {sponsorRelationship.end_date})
      <p>This review was completed during a sponsored period, but the relationship has ended.</p>
    </>
  ) : (
    <>
      No Sponsor Relationship
      <p>I purchased this product myself.</p>
    </>
  )}
</SponsorStatus>
```

### Risk 6: Sponsor Payment Amounts Not Disclosed
**Severity:** Medium

**Issue:** FTC doesn't require disclosing exact payment, but NOT disclosing could erode trust.

**Recommendation:**
Two options:

**Option A (Conservative):**
"I received [free product / payment / commission] for this review."

**Option B (Radical Transparency - Recommended for GoingBulk's positioning):**
"I received $500 + free product for this 90-day test."

Specific amounts create more trust than vague "compensation."

### Risk 7: No Affiliate Link Audit Trail
**Severity:** Medium

**Issue:** If affiliate link destination changes (e.g., product reformulated), old pages still link to it.

**Mitigation:**
```sql
CREATE TABLE affiliate_link_audit (
  id UUID PRIMARY KEY,
  affiliate_link_id UUID REFERENCES affiliate_links(id),
  destination_url TEXT NOT NULL,
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  changed_by UUID REFERENCES users(id),
  reason TEXT
);
```

Periodically review: "Is this link still pointing to the product I reviewed?"

### Risk 8: Commission Structure Not Defined
**Severity:** Low-Medium

**Issue:** Different merchants have different commission types.

**Recommendation:**
```sql
ALTER TABLE affiliate_links
ADD COLUMN commission_structure TEXT; 
-- '$10 per sale', '5% of sale', 'free product only', 'flat fee $500'
```

Helps creator evaluate which affiliate relationships are worth maintaining.

### Risk 9: Competing Products Within Same Category
**Severity:** Low-Medium

**Issue:** If creator reviews 3 creatine brands, all with affiliate links, which gets recommended?

**Recommendation:**
- Rank reviews by date (most recent = most current opinion)
- Add "Current Top Pick" badge if applicable
- Explain: "I've reviewed multiple options. Here's my current favorite and why."
- Never recommend product ONLY because it has higher commission

### Risk 10: Sponsor Contract Review Process Undefined
**Severity:** Low-Medium

**Issue:** Creator might accidentally sign contract limiting editorial freedom.

**Checklist Before Signing:**
```
[ ] Can publish negative or neutral review?
[ ] Can publish raw data even if unfavorable?
[ ] No requirement to edit/remove content after payment?
[ ] No requirement to delete negative comments?
[ ] Clear what deliverables are required (1 video? 1 blog post? Social posts?)
[ ] Payment terms clear (upfront? After delivery? Commission only?)
[ ] Can discuss competing products?
[ ] Can update review if opinion changes?
[ ] Termination clause doesn't punish honesty?
```

Have lawyer review if payment >$1000.

# 12. Missing Documents

## Critical Missing Docs (Build Blockers)

### 1. `24-creator-positioning-and-credentials.md`
**Priority:** Critical
**Purpose:** Define who the creator is and why their data matters

**Key Sections:**
- Creator identity (real name or pseudonym?)
- Background / credentials (or explicit lack thereof)
- Why this project exists
- What makes this different from other fitness blogs
- Personal story / transformation context
- Positioning: "I'm not a doctor, but here's why this matters anyway"

**Why Critical:** Without this, GoingBulk is "random person's data" which has zero SEO/GEO value.

---

### 2. `25-supabase-rls-policy-design.md`
**Priority:** Critical
**Purpose:** Define Row Level Security policies for every table

**Key Sections:**
- RLS policy for each table with sensitive data
- Public access rules (visibility = 'public')
- Professional access rules (visibility IN ('public', 'professional'))
- Admin access rules (bypass RLS or owner check)
- Anonymous access rules
- Testing procedure for RLS policies
- Common RLS pitfalls and how to avoid them

**Why Critical:** Without RLS design, database will leak private health data on day one.

---

### 3. `26-api-security-and-agent-access.md`
**Priority:** High
**Purpose:** Design API architecture and security for LLM/agent access

**Key Sections:**
- API endpoint design
- Authentication (API keys, JWT, etc.)
- Rate limiting strategy
- Scope-based permissions (read:experiments, write:imports, etc.)
- LLM-specific security (prevent prompt injection in API params)
- Audit logging for API requests
- API documentation strategy (OpenAPI spec)

**Why Critical:** Docs say LLMs must use APIs, but APIs don't exist yet.

---

### 4. `27-writing-style-guide.md`
**Priority:** High
**Purpose:** Operationalize the "tone" described in vision docs

**Key Sections:**
- Voice and tone guidelines
- Forbidden phrases (clickbait, absolutist claims)
- Required disclaimers for different content types
- Claim safety checklist
- Examples of good vs bad phrasing
- Heading/subheading style
- How to write research reviews
- How to write experiment results

**Why Critical:** Prevents inconsistent tone and medical claim creep.

---

### 5. `28-privacy-policy-and-legal-disclaimers.md`
**Priority:** High
**Purpose:** Draft actual legal pages, not just principles

**Key Sections:**
- Privacy policy (GDPR-compliant)
- Medical disclaimer (site-wide)
- Terms of service
- Cookie policy if using analytics
- Copyright policy
- DMCA agent information
- Contact for legal matters

**Why Critical:** Required before collecting any emails or publishing health data.

---

## Important Missing Docs (Should Exist Before Launch)

### 6. `29-migration-and-deployment-strategy.md`
**Priority:** High
**Purpose:** How to actually deploy and manage schema changes

**Key Sections:**
- Migration tooling choice (Drizzle recommended)
- Local dev → staging → production workflow
- Database backup strategy
- Rollback procedure
- Zero-downtime deployment approach
- Environment variables management

---

### 7. `30-testing-and-validation-strategy.md`
**Priority:** Medium-High
**Purpose:** How to validate the product works before launch

**Key Sections:**
- Unit testing (if any)
- Integration testing (API endpoints)
- E2E testing (critical user flows)
- Performance testing (1000-row table loads)
- RLS policy testing
- CSV import validation
- Mobile logging speed testing (is it actually under 2 minutes?)

---

### 8. `31-backup-and-disaster-recovery.md`
**Priority:** Medium-High
**Purpose:** What happens if database corrupted, creator injured, etc.

**Key Sections:**
- Automated database backups
- Backup verification (are backups actually restorable?)
- Creator incapacitation plan
- Trusted backup admin access
- Data export procedure
- Platform migration procedure (if leaving Supabase someday)

---

### 9. `32-analytics-and-metrics-strategy.md`
**Priority:** Medium
**Purpose:** How to measure success

**Key Sections:**
- Analytics tool choice (Plausible, Fathom, or privacy-first alternative)
- Key metrics to track (page views, bounce rate, time on page, dataset downloads)
- Professional viewer engagement metrics
- Newsletter signup rate
- Experiment completion tracking
- Content effectiveness (which experiments get most traffic)

---

### 10. `33-social-and-distribution-strategy.md`
**Priority:** Medium
**Purpose:** How content reaches audience

**Key Sections:**
- YouTube strategy (if applicable)
- X/Twitter strategy
- Newsletter strategy (frequency, format)
- Reddit/forum participation (if any)
- Cross-promotion between platforms
- Social → site → newsletter → affiliate funnel
- Content calendar approach

---

### 11. `34-mobile-pwa-technical-spec.md`
**Priority:** Medium
**Purpose:** Actual PWA implementation details

**Key Sections:**
- Service worker strategy
- Offline data caching (which pages work offline?)
- Install prompt UX
- Push notifications (if applicable)
- Home screen icon
- Splash screen
- iOS vs Android differences
- Performance budget (Lighthouse score targets)

---

### 12. `35-experiment-template-and-checklist.md`
**Priority:** Medium
**Purpose:** Actual template file + publication checklist

**Key Sections:**
- MDX template with all required sections
- Pre-publish checklist (disclaimer present? confounders listed? N=1 stated?)
- Frontmatter schema
- Verdict decision tree (when is something "works for me" vs "inconclusive"?)
- Research review template
- Data summary template

---

## Nice-to-Have Missing Docs (Phase 2+)

### 13. `36-professional-reviewer-onboarding.md`
**Priority:** Low
**Purpose:** How to add RD/doctor reviewers in Phase 2

---

### 14. `37-sponsor-contract-templates.md`
**Priority:** Low
**Purpose:** Reusable contract templates protecting editorial independence

---

### 15. `38-dataset-citation-guide.md`
**Priority:** Low
**Purpose:** How researchers should cite GoingBulk datasets (if anyone ever does)

---

# 13. Top 25 Actionable Recommendations

## Critical (Must Fix Before Launch)

**1. Add creator identity and positioning document**
- Create `24-creator-positioning-and-credentials.md`
- Define: who is the creator, what's their story, why this matters
- Address credential question explicitly (certified? self-taught? none? BE HONEST)

**2. Design RLS policies for every sensitive table**
- Create `25-supabase-rls-policy-design.md`
- Write policies for nutrition_logs, measurements, bloodwork_results, etc.
- Test policies before launch with dummy data

**3. Add visibility columns to all sensitive tables**
```sql
ALTER TABLE [nutrition_logs, workout_sessions, supplement_logs, measurements, 
  bloodwork_results, dexa_results, progress_photos, experiments, product_reviews, 
  reports, datasets]
ADD COLUMN visibility visibility_enum DEFAULT 'private';
```

**4. Add prominent medical disclaimer to every page footer**
```tsx
<Footer>
  <MedicalDisclaimer>
    ⚠️ Not medical advice. I'm not a doctor. N=1 experiments only. 
    Consult your physician. <Link>Full disclaimer</Link>
  </MedicalDisclaimer>
</Footer>
```

**5. Get legal review before publishing health data**
- Hire lawyer to review medical disclaimer, privacy policy, terms of service
- Specifically ask about supplement experiment liability
- Ask about blood pressure/glucose tracking liability
- Consider liability insurance

**6. Reduce MVP scope drastically**
True MVP:
- 7 pages (homepage, about, baseline experiment, baseline dataset, methodology, medical disclaimer, affiliate disclosure)
- Cronometer import only
- Basic bodyweight/workout/supplement logging
- ONE experiment
- Defer: professional explorer, entity graph, DEXA, bloodwork, multiple experiments

**7. Decide content storage location (recommend MDX for MVP)**
- Use MDX files for long-form content
- Metadata in frontmatter
- Page/entity relationships in Postgres
- Can migrate to DB later if needed

**8. Design API authentication and rate limiting**
- API keys for LLM access (not direct DB access)
- Rate limit: 100 req/hour per IP for public endpoints
- Separate key scopes: read:experiments, read:nutrition, etc.

**9. Create affiliate disclosure component (per-page, not just footer)**
```tsx
// Must appear BEFORE first affiliate link
<AffiliateDisclosure />
```

**10. Add redaction checklist for lab reports**
```
Before publishing DEXA/bloodwork:
[ ] Name redacted
[ ] DOB redacted (age range okay)
[ ] Address redacted
[ ] Patient ID redacted
[ ] Insurance info redacted
```

## High Priority (Should Fix Before Launch)

**11. Create writing style guide**
- `27-writing-style-guide.md`
- Forbidden phrases: "proven to," "guaranteed," "you should"
- Required: N=1 disclaimers, confounder acknowledgment, limitation sections

**12. Add audit logging for sensitive changes**
```sql
CREATE TABLE audit_log (
  id, table_name, record_id, action, old_values, new_values, 
  changed_by, changed_at, ip_address
);
```

**13. Design approval workflow and queue**
```sql
CREATE TABLE approval_queue (
  id, action_type, resource_id, requested_by, status, approved_by, notes
);
```

**14. Watermark all progress photos**
- "GoingBulk.com - Personal use only - Not for commercial use"
- Strip EXIF/GPS data
- Consider face blurring

**15. Add privacy policy and cookie consent**
- Draft privacy policy (GDPR-compliant)
- Cookie consent banner if using analytics
- Disclose all third-party services

**16. Design migration tooling (recommend Drizzle)**
- Choose Drizzle ORM for type-safe migrations
- Set up local → staging → production workflow
- Test rollback procedure

**17. Add confidence_level columns where missing**
```sql
ALTER TABLE [nutrition_logs, measurements, bloodwork_results]
ADD COLUMN confidence_level confidence_enum;
```

**18. Create experiment template with all required sections**
- MDX template file
- Pre-publish checklist
- Verdict decision criteria

**19. Add sponsor relationship status to product pages**
```tsx
<SponsorStatus 
  active={true} 
  amount="$500 + free product" 
  dates="Jan-Mar 2027"
/>
```

**20. Design daily_facts as materialized view (not regular view)**
```sql
CREATE MATERIALIZED VIEW daily_facts AS [query];
CREATE UNIQUE INDEX ON daily_facts(date);
-- Refresh nightly via cron
```

## Medium Priority (Fix Soon After Launch)

**21. Add internal link suggestions**
```typescript
// Build-time script
function suggestInternalLinks(content, existingLinks) {
  // Return entities mentioned but not linked
}
```

**22. Implement CSV export for daily_facts**
```typescript
// API route
GET /api/v1/exports/daily-facts.csv
  ?start=2027-01-01
  &end=2027-03-31
  &filters[protein_min]=180
```

**23. Create backup and recovery plan**
- Automated daily backups
- Backup restoration testing
- Trusted backup admin account (friend/partner)
- Creator incapacitation procedure

**24. Add Quick Facts component to all major pages**
```tsx
<QuickFacts facts={[
  { label: "Type", value: "N=1 experiment" },
  { label: "Duration", value: "90 days" },
  { label: "Confidence", value: "Medium" }
]} />
```

**25. Set up analytics (recommend privacy-first tool)**
- Plausible or Fathom (not Google Analytics)
- Track: page views, dataset downloads, time on page
- Add to privacy policy

# 14. Hard Questions

The project owner must answer these before build begins:

## Identity and Positioning

1. **What is your real name and will you use it publicly?** Or is this a pseudonymous project? (Impacts credibility and SEO authority)

2. **What are your actual credentials?** If none, how will you position "trust my data even though I'm not certified"?

3. **Why should anyone care about YOUR specific data?** What makes your transformation/story compelling vs 10,000 other fitness bloggers?

4. **Are you comfortable being the public face of this?** Progress photos, talking on camera, etc.? Or is this data-only?

5. **What happens to GoingBulk if you get injured, sick, or lose interest?** Is there a continuity plan?

## Legal and Liability

6. **Have you consulted a lawyer about medical liability?** Specifically for publishing blood pressure, glucose, supplement protocols?

7. **Do you have liability insurance?** What happens if someone replicates your creatine protocol and has an adverse reaction?

8. **Are you prepared to publish results even if a sponsor pays and the product fails?** Will you sign contracts that protect editorial independence?

9. **What's your age?** (If under 18, different legal considerations)

10. **Are you in the US?** (Impacts legal jurisdiction, FTC rules, etc.)

## Monetization

11. **What's your revenue target?** $500/mo? $5000/mo? $50k/mo? (Determines how aggressive monetization needs to be)

12. **Are you comfortable with aggressive affiliate disclosure?** "I made $X from this link" vs vague "I may earn commission"?

13. **Will you accept sponsors that restrict negative reviews?** (If yes, credibility = destroyed)

14. **What if your most popular experiment concludes "this expensive supplement didn't work"?** Will you still publish?

15. **How will you handle conflicts of interest?** E.g., if Hume sponsors you, can you fairly review competing body composition devices?

## Privacy and Safety

16. **Are you okay with your bloodwork, body weight, and body composition being permanently public?** This data will be archived/cached even if you delete it later.

17. **Are you prepared for your progress photos to be stolen and used in scam ads?** This WILL happen if you get popular.

18. **Do you have a plan if someone doxxes you?** Public health blogger = target for harassment.

19. **Will you show your face or keep it private?** Impacts personal safety and marketing effectiveness.

20. **What will you redact from lab reports?** Full name? Date of birth? Address? How will you balance transparency with privacy?

## Technical and Operational

21. **Do you know how to code?** Or are you hiring a developer? (Impacts feasibility and timeline)

22. **What's your actual time budget?** Hours per week for logging, content creation, coding, social media?

23. **Can you commit to daily logging for 12+ months?** If logging stops, the brand dies.

24. **Do you have the discipline to manually review every Cronometer import?** Or will you automate and hope for the best?

25. **What happens if Supabase shuts down or raises prices 10x?** Is there a migration plan?

## Content and Credibility

26. **How will you handle contradictory research?** E.g., if Study A says X helps and Study B says X doesn't help?

27. **What if your personal results contradict popular research?** Will you publish anyway and explain the discrepancy?

28. **How will you avoid cherry-picking data?** E.g., only publishing experiments that worked?

29. **What's your policy on updating past verdicts?** If you say "creatine worked" then later decide it didn't, will you update old posts?

30. **Are you prepared for professional criticism?** Doctors/RDs may publicly critique your N=1 methodology or conclusions.

## Audience and Distribution

31. **Who is your primary audience?** General fitness enthusiasts? Data nerds? Doctors? (Changes content strategy)

32. **Why would Google rank you over Mayo Clinic?** For what specific queries do you have an advantage?

33. **Are you committed to video content?** Or is this text/data only? (YouTube is hard to ignore for fitness content)

34. **How will you get your first 100 visitors?** SEO takes months; what's the bootstrap distribution plan?

35. **What's your newsletter strategy?** Weekly? Monthly? Ad-supported? Subscriber-funded?

## Experiments and Data

36. **What if your baseline shows you're already unhealthy?** E.g., pre-diabetic glucose levels. Will you publish that?

37. **How will you handle confounders you can't control?** Illness, stress, work changes, etc.

38. **Are you willing to run 90-day experiments even if they're boring?** Or will you give up after 30 days if nothing changes?

39. **What's your protocol for experiments that show harm?** E.g., supplement that raises blood pressure. Immediate stop?

40. **How often will you get DEXA scans?** Every 8 weeks? Every 6 months? (Costs $100-200 each)

## Product and Sponsor Relationships

41. **Will you review products you purchase vs only sponsored products?** (Purchased = more credible but costs money)

42. **How will you handle gifted products?** Accept and review? Decline to avoid bias?

43. **What's your minimum sponsor payment?** Will you review a product for $50? $500? $5000?

44. **Are you comfortable with Amazon affiliate commission rates (1-4%)?** Or do you need higher-paying affiliate programs?

45. **What if a sponsor wants to review/edit your draft before publication?** Will you allow that?

## Scaling and Future

46. **Is this a 1-year project or a 10-year brand?** (Impacts how much infrastructure to build)

47. **Do you want to hire staff eventually?** RD reviewer, video editor, developer?

48. **Would you sell GoingBulk if offered $100k? $1M?** (Impacts how much ownership structure matters)

49. **Do you want to add user-contributed data eventually?** Or keep it N=1 forever?

50. **What's your exit strategy if this fails?** Archive the site? Delete everything? Keep it up read-only?

# 15. Recommended Next Step

**Single Best Next Step:**

## Write the Creator Positioning Document First

**Why this before anything else:**

1. **Credibility foundation:** Without knowing who the creator is and why their data matters, the entire project positioning collapses. Are you a former obese programmer who lost 100 lbs? A certified personal trainer testing claims on yourself? A curious hobbyist with no credentials who's just very disciplined? Each of these is a valid but DIFFERENT positioning.

2. **Legal clarity:** The creator's credentials determine liability exposure. "Certified RD testing claims" has different legal implications than "random person with no credentials testing claims."

3. **Content strategy:** If you're a nobody with no credentials, the content must lean HEAVILY into radical transparency and humility. If you have relevant credentials, you can be slightly more authoritative (while still maintaining N=1 framing).

4. **SEO strategy:** Google ranks based on E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness). Your positioning determines which of these you lean into. No credentials = lean into Experience and Trustworthiness through transparency.

**Specific Action:**

Create `24-creator-positioning-and-credentials.md` answering:
- Who are you? (Real name or pseudonym)
- What's your background?
- What credentials do you have (or don't have)?
- Why are you doing this?
- What makes YOUR data valuable vs random person #47?
- How will you build trust despite lack of credentials (if applicable)?
- What's your transformation story (if any)?

**Once this exists:**

Then and only then can you:
- Write authentic About page
- Set appropriate disclaimers
- Design risk-appropriate legal protections
- Create realistic SEO strategy
- Determine if professional reviewers are needed (Phase 1 vs Phase 2)

**This document should take 2-4 hours to write but will save months of repositioning later.**

Without this, you're building a platform before knowing what the brand even is.
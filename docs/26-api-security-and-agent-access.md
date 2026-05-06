# GoingBulk API Security and Agent Access

## Purpose

This document defines how GoingBulk APIs, LLM agents, MCP tools, automations, and external integrations should access data.

GoingBulk may eventually connect to VedaOps, LLM assistants, MCP tools, public/professional data views, and internal automations. None of these should access Supabase/Postgres directly.

## Core Rule

```text
Agents are not database clients.
APIs are the gatekeepers.
```

Correct pattern:

```text
LLM / agent / MCP tool / automation
-> governed API client
-> GoingBulk API
-> Supabase/Postgres
```

Forbidden pattern:

```text
LLM / agent / MCP tool / automation
-> direct Supabase SQL/Postgres access
```

## Why This Matters

GoingBulk will contain sensitive health, fitness, product, sponsor, and private operational data.

Direct database access would bypass:

- application validation;
- visibility rules;
- approval workflows;
- audit logs;
- rate limits;
- scoped permissions;
- source/confidence handling;
- public/professional/private boundaries.

The API layer must be the enforcement point.

## API Layers

### Public Web APIs

Used by public pages and public datasets.

Should expose only:

- published pages;
- public experiment summaries;
- public datasets;
- public product/review information;
- public methodology/disclaimer content.

### Admin APIs

Used by the private admin dashboard.

Can support:

- imports;
- logging;
- editing experiments;
- approving visibility changes;
- managing products/affiliates;
- managing content metadata;
- generating exports.

### Professional APIs

Future Phase 2+.

Can expose professional-level records where:

```text
visibility IN ('public', 'professional')
```

### Agent/LLM APIs

Used by internal LLM tools, future VedaOps integrations, or MCP wrappers.

Should be scoped, logged, and rate-limited.

## Suggested API Structure

```text
/api/v1/public/experiments
/api/v1/public/experiments/:slug
/api/v1/public/datasets/:slug
/api/v1/public/nutrition-summary
/api/v1/public/training-summary
/api/v1/public/products/:slug

/api/v1/admin/imports/cronometer
/api/v1/admin/imports/:id/preview
/api/v1/admin/imports/:id/approve
/api/v1/admin/workouts
/api/v1/admin/supplements
/api/v1/admin/body-metrics
/api/v1/admin/experiments
/api/v1/admin/products
/api/v1/admin/pages

/api/v1/pro/daily-facts
/api/v1/pro/exports
/api/v1/pro/compare-periods

/api/v1/agent/recent-health-summary
/api/v1/agent/active-experiments
/api/v1/agent/experiment-detail
/api/v1/agent/page-graph
/api/v1/agent/claim-risk-check
```

## API Authentication

### Public APIs

May allow anonymous access but must return only public data.

### Admin APIs

Require authenticated owner/admin session.

### Professional APIs

Require professional viewer account or invite link when Phase 2 exists.

### Agent APIs

Require API keys with explicit scopes.

## API Key Table

```sql
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key_hash TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  scopes TEXT[] NOT NULL,
  rate_limit_per_hour INTEGER DEFAULT 100,
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  revoked BOOLEAN DEFAULT false
);
```

Never store raw API keys.

Store only hashes.

Suggested key format:

```text
gbulk_sk_[random]
```

## API Key Usage Log

```sql
CREATE TABLE api_key_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_key_id UUID REFERENCES api_keys(id),
  endpoint TEXT NOT NULL,
  method TEXT NOT NULL,
  status_code INTEGER,
  used_at TIMESTAMPTZ DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);
```

## Scope Examples

Read scopes:

```text
read:public
read:experiments
read:nutrition_summary
read:training_summary
read:products
read:page_graph
read:professional
```

Write scopes:

```text
write:imports
write:logs
write:drafts
write:approval_requests
```

Dangerous scopes:

```text
publish:pages
change:visibility
approve:imports
approve:verdicts
activate:affiliate_links
```

Dangerous scopes should not be granted to LLM agents by default.

## Agent Access Default

Default LLM/agent keys should be read-only.

Recommended MVP agent scopes:

```text
read:public
read:experiments
read:nutrition_summary
read:training_summary
read:products
read:page_graph
```

No raw private logs.
No direct write access.
No publish access.
No visibility changes.

## Write Operations

Write operations should require:

- authenticated owner/admin user;
- explicit permission;
- validation;
- audit log;
- optional approval queue;
- idempotency where useful.

Example protected actions:

```text
approve Cronometer import
publish experiment
change experiment verdict
publish bloodwork summary
activate affiliate link
change public visibility
```

## Audit Log

All sensitive API writes should create an audit record.

```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT,
  record_id UUID,
  action TEXT NOT NULL,
  old_values JSONB,
  new_values JSONB,
  changed_by UUID REFERENCES user_profiles(id),
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);
```

## Approval Queue

Approval-sensitive actions can be requested but not automatically executed.

```sql
CREATE TABLE approval_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_type TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID NOT NULL,
  requested_by UUID REFERENCES user_profiles(id),
  requested_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'pending',
  approved_by UUID REFERENCES user_profiles(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  metadata JSONB
);
```

MVP can keep approval manual through the owner account.

Phase 2 can add more formal review roles.

## Rate Limiting

Public and agent endpoints should be rate-limited.

Suggested starting defaults:

```text
public anonymous: 100 requests/hour/IP
agent API key: configured per key, default 100 requests/hour
admin: higher but still protected from abuse
exports: stricter, such as 10/hour/IP or per user
```

Rate limiting can use Vercel middleware plus Upstash Redis or another rate-limit layer.

## Export Security

Exports are high-risk because they can leak large data slices.

Export rules:

- public exports only include public records;
- professional exports require professional access;
- admin exports require owner/admin;
- all exports should be logged;
- private exports should expire;
- raw private health exports should not be publicly linked;
- CSV export should include metadata about filters and visibility.

## Public Assistant vs Internal Assistant

### Internal Assistant

May access approved internal APIs with owner authorization.

Can help with:

- drafting;
- summarization;
- anomaly detection;
- claim-safety checks;
- import review;
- report preparation.

### Public Assistant

Should only access public content APIs.

Must not access:

- private raw logs;
- unpublished bloodwork;
- sponsor negotiations;
- private notes;
- unapproved drafts;
- admin-only records.

## Prompt Injection and Tool Safety

Agent tools must not blindly follow user-provided text from database fields.

Risks:

- imported notes containing malicious instructions;
- comments or drafts telling the agent to reveal private data;
- public pages containing prompt injection text.

Mitigation:

- tool responses should be structured data, not executable instructions;
- agents should treat retrieved content as data, not commands;
- API should enforce visibility before returning content;
- sensitive actions require approval.

## OpenAPI Documentation

GoingBulk should eventually maintain an OpenAPI spec.

MVP can document endpoints manually.

Phase 2 should generate docs for:

```text
public APIs
professional APIs
agent APIs
admin APIs where useful
```

## CORS Rules

CORS should be restrictive.

Allow:

```text
https://goingbulk.com
https://www.goingbulk.com
local development origins
```

Do not allow wildcard origins for authenticated APIs.

## Environment and Secrets

Rules:

- never expose service role key to browser;
- keep API keys in environment variables;
- rotate keys if leaked;
- separate development/staging/production secrets;
- avoid sharing Supabase credentials with LLM agents;
- use scoped API keys instead.

## MVP API Security Scope

For MVP, implement:

- public read APIs for published public data;
- owner/admin APIs for imports/logging;
- no professional accounts yet;
- no public assistant yet;
- no direct LLM database access;
- basic rate limiting;
- audit logs for imports and visibility changes;
- service role only server-side.

## Core Principle

```text
Every integration gets the least access required to do its job, and every sensitive action leaves a trail.
```

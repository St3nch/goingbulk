# Current Security Posture

## Purpose

This document snapshots the current security, governance, auditability, and operational posture of GoingBulk.

It exists to:

- prevent accidental weakening of guarantees
- preserve architectural intent
- document known limitations
- track deliberate tradeoffs
- guide future hardening work
- reduce security and governance drift over time

Update this document whenever major changes are made to:

- RLS
- grants and revokes
- audit systems
- visibility governance
- auth flows
- migration discipline
- CI validation
- public dataset publication systems

## Current Security Model

GoingBulk currently uses:

- Next.js
- Supabase
- PostgreSQL
- Drizzle ORM

The security posture emphasizes:

- explicit governance
- behavioral validation
- immutable auditing
- reproducibility
- minimal hidden magic
- deny-by-default discipline

## Current Guarantees

### Row-Level Security

RLS is enabled on governed application tables.

Current governed entities include:

- `user_profiles`
- `nutrition_logs`
- `nutrition_log_nutrients`
- `measurements`
- `workout_sessions`
- `exercise_sets`
- `supplements`
- `supplement_logs`
- `experiments`
- `confounder_logs`
- `datasets`
- `dataset_exports`
- `audit_log`
- import infrastructure tables

Behavioral hammer tests validate:

- anon visibility restrictions
- authenticated ownership rules
- owner/admin elevated access
- child-table visibility inheritance
- `auth.uid()` resolution
- non-owner write denial
- self-promotion denial
- direct audit write denial

### Privilege Escalation Protections

Current protections:

- authenticated users cannot update themselves to elevated roles
- authenticated users cannot insert themselves as elevated roles
- role changes require owner/admin privileges
- role changes generate immutable audit rows

Reference tables are SELECT-only for authenticated users:

- `exercises`
- `supplements`
- `nutrient_definitions`

### Audit Integrity

Current audit posture:

- `audit_log` is append-only
- UPDATE is blocked
- DELETE is blocked
- TRUNCATE is blocked
- authenticated users cannot directly insert audit rows
- audit writes should occur through SECURITY DEFINER triggers/functions only

Current audited event coverage:

- user role changes

Planned future audit coverage:

- visibility transitions
- dataset publication
- dataset promotion/demotion
- governance approvals
- experiment lifecycle events

Known limitation:

- PostgreSQL superusers and service-role connections can still bypass normal application protections.
- Current posture assumes trusted infrastructure operators.

## Visibility Governance Model

Current visibility enum:

- `private`
- `internal`
- `professional`
- `public`

Current behavior:

- anon can only view public rows
- professional viewers can view professional/public rows where policies permit it
- owner/admin can view all governed rows
- regular authenticated users can access their own private rows

Visibility transitions are not yet fully audited.

Planned future improvements:

- immutable visibility transition audit rows
- publication metadata
- promotion reason tracking
- review workflow support
- curated public projections/views

## Migration Discipline

Current posture:

- migrations are validated via rebuild CI
- hammer tests run against a rebuilt database
- manual governance SQL exists alongside Drizzle migrations
- behavioral RLS tests run in CI

Current protections:

- migration rebuild verification
- hardened object existence assertions
- grant posture verification
- realtime publication verification

Known limitation:

- manual migration plus Drizzle snapshot coordination remains operationally sensitive.

Future improvements:

- schema snapshot drift detection
- migration hash verification
- idempotence validation
- backup/restore CI

## Realtime Posture

Current posture:

- no governed tables are intentionally exposed to realtime publication
- hammer tests validate sensitive tables are not published

Known limitation:

- future realtime adoption must undergo separate RLS and publication review.

## Operational Assumptions

Current assumptions:

- trusted local development environment
- trusted CI environment
- trusted infrastructure operators
- service-role usage remains tightly controlled

Known limitation:

- service-role connections bypass RLS.

Future mitigation ideas:

- stricter service-role usage isolation
- internal admin-only service layers
- service-role access auditing

## Current Threat Model

Currently defended against:

- accidental public exposure of private rows through RLS
- self-promotion privilege escalation
- direct audit tampering by authenticated users
- non-owner writes to governed rows
- non-owner private reads
- reference-table mutation by authenticated users
- accidental realtime publication drift

Not fully defended against:

- malicious infrastructure operators
- service-role abuse
- compromised CI secrets
- application-layer logic bugs
- future unsafe public projections
- future unsafe LLM tooling

## Future Governance Goals

### Near-Term

- visibility transition audit writers
- publication governance metadata
- public dataset projection strategy
- dataset release workflow
- stronger migration reproducibility

### Medium-Term

- evidence/literature ingestion
- provenance-aware experiment workflows
- reproducible dataset exports
- research citation linkage
- experiment approval/review flows

### Long-Term

- public research portal
- scientific reproducibility tooling
- provenance-aware analytics
- controlled dataset publication pipelines
- stronger cryptographic audit integrity

## Anti-Goals

The platform intentionally avoids:

- hidden ORM magic
- implicit auth assumptions
- broad default grants
- app-only integrity enforcement
- premature microservice complexity
- premature partitioning
- overengineered distributed systems

## Security Review Process

Current review posture:

- adversarial review is encouraged
- external AI review is used aggressively
- behavioral validation is preferred over theoretical assumptions
- governance changes require hammer validation
- CI rebuild validation is required before merge

## Important Principle

The project prioritizes:

1. correctness
2. auditability
3. reproducibility
4. maintainability
5. explicit governance

Above:

- speed hacks
- clever abstractions
- hidden convenience behavior
- premature scale theater

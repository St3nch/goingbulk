# Auth Foundation MVP Notes

Purpose:
Establish the smallest safe authentication/session foundation required for governed writes.

Why this exists:
Nutrition import persistence correctly requires authenticated ownership (`uploaded_by`).
The current governance model intentionally rejects anonymous or fake-user persistence.

Required MVP capabilities:
- authenticated Supabase session
- current-user resolution
- user_profile bootstrap
- protected admin routes
- authenticated import ownership linkage

Explicitly deferred:
- RBAC dashboard
- organization/team model
- granular permission editor
- OAuth provider sprawl
- custom credential system
- enterprise auth features

Next planned follow-up after auth foundation:
- persisted nutrition import batches
- persisted raw import rows
- DB-backed import preview workflow

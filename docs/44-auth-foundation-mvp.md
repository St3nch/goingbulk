# Auth Foundation MVP Notes

Purpose:
Establish the smallest safe authentication/session foundation required for governed writes.

Current status:
- Supabase SSR session infrastructure implemented
- middleware-based admin route protection implemented
- current-user helper implemented
- auth callback flow implemented
- user_profile bootstrap trigger implemented
- authenticated import batch persistence implemented
- DB-backed Cronometer import preview implemented

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
- manual authenticated workflow validation
- import approval/rejection workflow
- normalization into nutrition_logs



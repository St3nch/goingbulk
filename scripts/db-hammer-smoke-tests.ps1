#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Write-Output "=== GoingBulk DB Hammer Smoke Tests ==="

$container = if ($env:GOINGBULK_DB_CONTAINER) { $env:GOINGBULK_DB_CONTAINER } else { "supabase_db_goingbulk" }

function Run-Sql {
  param([string]$Sql)
  docker exec $container psql -U postgres -d postgres -tAc $Sql
}

function Run-Sql-Command {
  param([string]$Sql)
  docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c $Sql
}

function Run-Role-Sql {
  param(
    [string]$Role,
    [string]$Sub,
    [string]$Sql
  )

  $wrappedSql = "SET ROLE $Role; SET request.jwt.claim.sub = '$Sub'; $Sql"
  $output = docker exec $container psql -X -q -U postgres -d postgres -v ON_ERROR_STOP=1 -tA -c $wrappedSql
  $output | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 1
}

function Run-Role-Sql-Expect-Fail {
  param(
    [string]$Role,
    [string]$Sub,
    [string]$Sql,
    [string]$ExpectedPattern
  )

  $sessionSql = "BEGIN; SET LOCAL ROLE $Role; SET LOCAL request.jwt.claim.sub = '$Sub'; $Sql; ROLLBACK;"
  $output = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -tAc $sessionSql 2>&1
  $exitCode = $LASTEXITCODE
  Write-Output $output
  if ($exitCode -eq 0) {
    throw "Expected SQL to fail for role $Role but it succeeded: $Sql"
  }
  if (($output | Out-String) -notmatch $ExpectedPattern) {
    throw "SQL failed for role $Role, but not with expected pattern '$ExpectedPattern'."
  }
}

function Run-Role-Sql-Persist {
  param(
    [string]$Role,
    [string]$Sub,
    [string]$Sql
  )

  $sessionSql = "BEGIN; SET LOCAL ROLE $Role; SET LOCAL request.jwt.claim.sub = '$Sub'; $Sql; COMMIT;"
  docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c $sessionSql
}

Write-Output "--- verify expected tables exist ---"
$expectedTables = @(
  "audit_log",
  "dataset_exports",
  "datasets",
  "exercises",
  "confounder_logs",
  "experiments",
  "measurements",
  "nutrition_import_batches",
  "nutrition_import_rows",
  "nutrient_definitions",
  "nutrition_log_nutrients",
  "nutrition_logs",
  "supplement_logs",
  "supplements",
  "user_profiles",
  "exercise_sets",
  "workout_sessions"
)
foreach ($table in $expectedTables) {
  $exists = Run-Sql "SELECT to_regclass('public.$table') IS NOT NULL;"
  if ($exists.Trim() -ne "t") {
    throw "Missing expected table: $table"
  }
}

Write-Output "--- verify RLS enabled count ---"
$rlsCount = Run-Sql "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('audit_log','dataset_exports','datasets','exercises','confounder_logs','experiments','measurements','nutrition_import_batches','nutrition_import_rows','nutrient_definitions','nutrition_log_nutrients','nutrition_logs','supplement_logs','supplements','user_profiles','exercise_sets','workout_sessions') AND rowsecurity=true;"
Write-Output "RLS tables: $rlsCount"
if ([int]$rlsCount -ne 17) {
  throw "Expected exactly 17 RLS-enabled GoingBulk public tables."
}

Write-Output "--- verify helper functions exist ---"
$fnCount = Run-Sql "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND proname IN ('set_updated_at','current_user_role','is_owner_or_admin','can_view_visibility','can_view_owned_visibility','can_view_owned_dataset','handle_new_auth_user','audit_log_immutable');"
Write-Output "Helper functions: $fnCount"
if ([int]$fnCount -ne 8) {
  throw "Missing expected helper functions."
}

Write-Output "--- verify policy coverage ---"
$policyCount = Run-Sql "SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename IN ('audit_log','dataset_exports','datasets','exercises','confounder_logs','experiments','measurements','nutrition_import_batches','nutrition_import_rows','nutrient_definitions','nutrition_log_nutrients','nutrition_logs','supplement_logs','supplements','user_profiles','exercise_sets','workout_sessions');"
Write-Output "Policies: $policyCount"
if ([int]$policyCount -lt 40) {
  throw "Expected broad RLS policy coverage."
}

Write-Output "--- verify API role grants ---"
$grantChecks = @(
  "anon:nutrition_logs:SELECT",
  "anon:nutrient_definitions:SELECT",
  "anon:exercises:SELECT",
  "anon:supplements:SELECT",
  "authenticated:user_profiles:UPDATE",
  "authenticated:nutrition_logs:INSERT",
  "authenticated:measurements:INSERT",
  "authenticated:workout_sessions:SELECT",
  "authenticated:exercise_sets:INSERT",
  "authenticated:supplement_logs:DELETE"
)
foreach ($grantCheck in $grantChecks) {
  $parts = $grantCheck.Split(":")
  $role = $parts[0]
  $table = $parts[1]
  $priv = $parts[2]
  $hasGrant = Run-Sql "SELECT has_table_privilege('$role', 'public.$table', '$priv');"
  Write-Output "$grantCheck => $hasGrant"
  if ($hasGrant.Trim() -ne "t") {
    throw "Missing expected table privilege: $grantCheck"
  }
}

Write-Output "--- verify operational tables are not granted to API roles ---"
$blockedGrantChecks = @(
  "anon:audit_log:SELECT",
  "authenticated:audit_log:INSERT",
  "anon:nutrition_import_batches:SELECT",
  "authenticated:nutrition_import_rows:SELECT",
  "authenticated:exercises:INSERT",
  "authenticated:exercises:UPDATE",
  "authenticated:exercises:DELETE",
  "authenticated:supplements:INSERT",
  "authenticated:supplements:UPDATE",
  "authenticated:supplements:DELETE",
  "authenticated:nutrient_definitions:INSERT",
  "authenticated:nutrient_definitions:UPDATE",
  "authenticated:nutrient_definitions:DELETE"
)
foreach ($grantCheck in $blockedGrantChecks) {
  $parts = $grantCheck.Split(":")
  $role = $parts[0]
  $table = $parts[1]
  $priv = $parts[2]
  $hasGrant = Run-Sql "SELECT has_table_privilege('$role', 'public.$table', '$priv');"
  Write-Output "$grantCheck => $hasGrant"
  if ($hasGrant.Trim() -ne "f") {
    throw "Unexpected API table privilege: $grantCheck"
  }
}

Write-Output "--- seed RLS behavior fixtures ---"
$ownerId = "11111111-1111-1111-1111-111111111111"
$viewerId = "22222222-2222-2222-2222-222222222222"
$otherId = "33333333-3333-3333-3333-333333333333"
Run-Sql-Command "INSERT INTO auth.users (id, email) VALUES ('$ownerId', 'hammer-owner@example.test') ON CONFLICT (id) DO UPDATE SET email=EXCLUDED.email;"
Run-Sql-Command "INSERT INTO auth.users (id, email) VALUES ('$viewerId', 'hammer-viewer@example.test') ON CONFLICT (id) DO UPDATE SET email=EXCLUDED.email;"
Run-Sql-Command "INSERT INTO auth.users (id, email) VALUES ('$otherId', 'hammer-other@example.test') ON CONFLICT (id) DO UPDATE SET email=EXCLUDED.email;"
Run-Sql-Command "UPDATE public.user_profiles SET role='owner' WHERE id='$ownerId';"
Run-Sql-Command "UPDATE public.user_profiles SET role='public' WHERE id='$viewerId';"
Run-Sql-Command "UPDATE public.user_profiles SET role='public' WHERE id='$otherId';"
Run-Sql-Command "DELETE FROM public.nutrition_logs WHERE food_name_snapshot LIKE 'Hammer % Food';"
Run-Sql-Command "INSERT INTO public.nutrition_logs (user_id, date, food_name_snapshot, calories, visibility) VALUES ('$ownerId', CURRENT_DATE, 'Hammer Owner Private Food', 100, 'private'), ('$ownerId', CURRENT_DATE, 'Hammer Owner Public Food', 200, 'public'), ('$otherId', CURRENT_DATE, 'Hammer Other Private Food', 300, 'private');"

Write-Output "--- verify anon sees public rows but not private rows ---"
$anonPublic = Run-Role-Sql "anon" $viewerId "SELECT count(*) FROM public.nutrition_logs WHERE food_name_snapshot='Hammer Owner Public Food';"
$anonPrivate = Run-Role-Sql "anon" $viewerId "SELECT count(*) FROM public.nutrition_logs WHERE food_name_snapshot='Hammer Owner Private Food';"
Write-Output "anon public count: $anonPublic"
Write-Output "anon private count: $anonPrivate"
if ([int]$anonPublic -lt 1) { throw "Anon should see public nutrition rows." }
if ([int]$anonPrivate -ne 0) { throw "Anon should not see private nutrition rows." }

Write-Output "--- verify owner/admin sees private rows across users ---"
$ownerPrivate = Run-Role-Sql "authenticated" $ownerId "SELECT count(*) FROM public.nutrition_logs WHERE food_name_snapshot IN ('Hammer Owner Private Food', 'Hammer Other Private Food');"
Write-Output "owner/admin private count: $ownerPrivate"
if ([int]$ownerPrivate -ne 2) { throw "Owner/admin should see private rows across users." }

Write-Output "--- verify auth.uid() resolves correctly under role simulation ---"
$resolvedUid = Run-Role-Sql "authenticated" $viewerId "SELECT auth.uid();"
Write-Output "resolved auth.uid(): $resolvedUid"
if ($resolvedUid.Trim() -ne $viewerId) {
  throw "auth.uid() resolved incorrectly. Expected $viewerId but got $resolvedUid"
}

Write-Output "--- verify regular authenticated users see own private but not others' private ---"
$viewerOwnInsert = Run-Role-Sql "authenticated" $viewerId "INSERT INTO public.measurements (user_id, measured_at, metric_key, value, unit, visibility) VALUES ('$viewerId', NOW(), 'bodyweight', 201, 'lb', 'private'); SELECT count(*) FROM public.measurements WHERE user_id='$viewerId' AND metric_key='bodyweight';"
Write-Output "viewer own insert/count: $viewerOwnInsert"
if ([int]$viewerOwnInsert -lt 1) { throw "Authenticated user should be able to insert own private measurement." }
$viewerOtherPrivate = Run-Role-Sql "authenticated" $viewerId "SELECT count(*) FROM public.nutrition_logs WHERE food_name_snapshot='Hammer Other Private Food';"
Write-Output "viewer other private count: $viewerOtherPrivate"
if ([int]$viewerOtherPrivate -ne 0) { throw "Authenticated user should not see another user's private row." }

Write-Output "--- verify non-owner authenticated user cannot write another user's governed row ---"
Run-Role-Sql-Expect-Fail "authenticated" $viewerId "INSERT INTO public.measurements (user_id, measured_at, metric_key, value, unit, visibility) VALUES ('$otherId', NOW(), 'bodyweight', 202, 'lb', 'private');" "row-level security|permission denied|violates row-level security"

Write-Output "--- verify owner/admin role changes create audit rows ---"
Run-Sql-Command "UPDATE public.user_profiles SET role='editor' WHERE id='$otherId';"
$auditRoleChangeCount = Run-Sql "SELECT count(*) FROM public.audit_log WHERE table_name='user_profiles' AND action='user_role_changed' AND record_id='$otherId';"
Write-Output "role change audit count: $auditRoleChangeCount"
if ([int]$auditRoleChangeCount -lt 1) {
  throw "Expected audit row for user role change."
}

Write-Output "--- verify self-promotion is denied and persisted writes cannot escalate ---"
Run-Role-Sql-Expect-Fail "authenticated" $viewerId "UPDATE public.user_profiles SET role='owner' WHERE id='$viewerId';" "role changes require owner/admin|row-level security|permission denied"
$viewerRole = Run-Sql "SELECT role FROM public.user_profiles WHERE id='$viewerId';"
Write-Output "viewer role after self-promotion attempt: $viewerRole"
if ($viewerRole.Trim() -ne "public") { throw "Authenticated user self-promoted to $viewerRole." }

Write-Output "--- verify INSERT self-promotion is denied ---"
Run-Role-Sql-Expect-Fail "authenticated" $viewerId "DELETE FROM public.user_profiles WHERE id='$viewerId'; INSERT INTO public.user_profiles (id, email, role) VALUES ('$viewerId', 'hammer-viewer-reinsert@example.test', 'owner');" "role|row-level security|permission denied|violates row-level security"
$viewerRoleAfterInsertAttempt = Run-Sql "SELECT role FROM public.user_profiles WHERE id='$viewerId';"
Write-Output "viewer role after insert self-promotion attempt: $viewerRoleAfterInsertAttempt"
if ($viewerRoleAfterInsertAttempt.Trim() -ne "public") { throw "Authenticated user self-promoted via INSERT to $viewerRoleAfterInsertAttempt." }

Write-Output "--- verify direct authenticated audit_log inserts are denied ---"
Run-Role-Sql-Expect-Fail "authenticated" $viewerId "INSERT INTO public.audit_log (table_name, record_id, action, changed_by) VALUES ('hammer', gen_random_uuid(), 'spoofed_audit', '$viewerId');" "permission denied|row-level security|violates row-level security"

Write-Output "--- verify non-admin authenticated users cannot mutate global reference tables ---"
Run-Sql-Command "INSERT INTO public.supplements (slug, name) VALUES ('hammer-creatine', 'Hammer Creatine') ON CONFLICT DO NOTHING;"
Run-Role-Sql-Expect-Fail "authenticated" $viewerId "INSERT INTO public.exercises (slug, name) VALUES ('hammer-attack', 'Hammer Attack');" "row-level security|permission denied"
$supplementUpdateAttempt = Run-Role-Sql "authenticated" $viewerId "UPDATE public.supplements SET name='hijacked' WHERE slug='hammer-creatine' RETURNING id;"
if ($null -ne $supplementUpdateAttempt -and $supplementUpdateAttempt.ToString().Trim() -ne "") {
  throw "Non-admin user updated supplements row: $supplementUpdateAttempt"
}
Run-Role-Sql-Expect-Fail "authenticated" $viewerId "INSERT INTO public.nutrient_definitions (nutrient_key, display_name, unit, category) VALUES ('hammer_attack_nutrient', 'Attack', 'g', 'macro');" "row-level security|permission denied"

Write-Output "--- verify visibility transitions are audited and affect anon visibility ---"
$visibilityLogId = Run-Sql "SELECT id FROM public.nutrition_logs WHERE food_name_snapshot='Hammer Owner Private Food' LIMIT 1;"
Run-Sql-Command "UPDATE public.nutrition_logs SET visibility='public' WHERE id='$visibilityLogId';"
$anonAfterPromotion = Run-Role-Sql "anon" $viewerId "SELECT count(*) FROM public.nutrition_logs WHERE id='$visibilityLogId';"
Write-Output "anon visibility after promotion: $anonAfterPromotion"
if ([int]$anonAfterPromotion -lt 1) { throw "Anon should see row after visibility promotion to public." }
$promotionAuditCount = Run-Sql "SELECT count(*) FROM public.audit_log WHERE table_name='nutrition_logs' AND action='visibility_changed' AND record_id='$visibilityLogId' AND old_values->>'visibility'='private' AND new_values->>'visibility'='public';"
Write-Output "promotion audit rows: $promotionAuditCount"
if ([int]$promotionAuditCount -lt 1) { throw "Expected visibility promotion audit row." }

Run-Sql-Command "UPDATE public.nutrition_logs SET visibility='private' WHERE id='$visibilityLogId';"
$anonAfterDemotion = Run-Role-Sql "anon" $viewerId "SELECT count(*) FROM public.nutrition_logs WHERE id='$visibilityLogId';"
Write-Output "anon visibility after demotion: $anonAfterDemotion"
if ([int]$anonAfterDemotion -ne 0) { throw "Anon should not see row after visibility demotion to private." }
$demotionAuditCount = Run-Sql "SELECT count(*) FROM public.audit_log WHERE table_name='nutrition_logs' AND action='visibility_changed' AND record_id='$visibilityLogId' AND old_values->>'visibility'='public' AND new_values->>'visibility'='private';"
Write-Output "demotion audit rows: $demotionAuditCount"
if ([int]$demotionAuditCount -lt 1) { throw "Expected visibility demotion audit row." }

Write-Output "--- verify child visibility inherits from parent nutrition log ---"
Run-Sql-Command "INSERT INTO public.nutrient_definitions (nutrient_key, display_name, unit, category) VALUES ('hammer_protein', 'Hammer Protein', 'g', 'macro') ON CONFLICT (nutrient_key) DO NOTHING;"
Run-Sql-Command "INSERT INTO public.nutrition_log_nutrients (nutrition_log_id, nutrient_key, value) SELECT id, 'hammer_protein', 10 FROM public.nutrition_logs WHERE food_name_snapshot='Hammer Owner Public Food';"
Run-Sql-Command "INSERT INTO public.nutrition_log_nutrients (nutrition_log_id, nutrient_key, value) SELECT id, 'hammer_protein', 20 FROM public.nutrition_logs WHERE food_name_snapshot='Hammer Owner Private Food';"
$anonChildRows = Run-Role-Sql "anon" $viewerId "SELECT count(*) FROM public.nutrition_log_nutrients n JOIN public.nutrition_logs l ON l.id = n.nutrition_log_id WHERE l.food_name_snapshot LIKE 'Hammer Owner % Food';"
Write-Output "anon child visible count: $anonChildRows"
if ([int]$anonChildRows -ne 1) { throw "Anon should see only public child nutrient rows." }

Write-Output "--- verify supplement dedup index exists and is user-scoped ---"
$idx = Run-Sql "SELECT count(*) FROM pg_indexes WHERE schemaname='public' AND indexname='idx_supplement_logs_dedup' AND indexdef LIKE '%user_id%';"
if ([int]$idx -ne 1) {
  throw "User-scoped supplement dedup index missing."
}
Run-Sql-Command "INSERT INTO public.supplements (slug, name) VALUES ('hammer-creatine', 'Hammer Creatine') ON CONFLICT DO NOTHING;"
Run-Sql-Command "DELETE FROM public.supplement_logs WHERE supplement_id = (SELECT id FROM public.supplements WHERE slug='hammer-creatine');"
Run-Sql-Command "INSERT INTO public.supplement_logs (user_id, supplement_id, date) SELECT '$viewerId', id, CURRENT_DATE FROM public.supplements WHERE slug='hammer-creatine';"
Run-Sql-Command "INSERT INTO public.supplement_logs (user_id, supplement_id, date) SELECT '$otherId', id, CURRENT_DATE FROM public.supplements WHERE slug='hammer-creatine';"
$duplicateOutput = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "INSERT INTO public.supplement_logs (user_id, supplement_id, date) SELECT '$viewerId', id, CURRENT_DATE FROM public.supplements WHERE slug='hammer-creatine';" 2>&1
$duplicateExitCode = $LASTEXITCODE
Write-Output $duplicateOutput
if ($duplicateExitCode -eq 0) {
  throw "Supplement dedup index did not reject duplicate same-user NULL time_taken rows."
}
if (($duplicateOutput | Out-String) -notmatch "duplicate key value violates unique constraint") {
  throw "Supplement dedup failed for an unexpected reason."
}

Write-Output "--- verify audit_log immutability policies and triggers ---"
$auditMutablePolicies = Run-Sql "SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='audit_log' AND cmd IN ('UPDATE','DELETE');"
if ([int]$auditMutablePolicies -ne 0) {
  throw "audit_log should not expose UPDATE/DELETE policies."
}
Run-Sql-Command "INSERT INTO public.audit_log (table_name, record_id, action) VALUES ('hammer', gen_random_uuid(), 'insert');"
$updateAuditOutput = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "UPDATE public.audit_log SET action='tampered' WHERE table_name='hammer';" 2>&1
$updateAuditExit = $LASTEXITCODE
Write-Output $updateAuditOutput
if ($updateAuditExit -eq 0) { throw "audit_log UPDATE should be blocked by immutability trigger." }
if (($updateAuditOutput | Out-String) -notmatch "append-only") { throw "audit_log UPDATE failed for unexpected reason." }

$deleteAuditOutput = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "DELETE FROM public.audit_log WHERE table_name='hammer';" 2>&1
$deleteAuditExit = $LASTEXITCODE
Write-Output $deleteAuditOutput
if ($deleteAuditExit -eq 0) { throw "audit_log DELETE should be blocked by immutability trigger." }
if (($deleteAuditOutput | Out-String) -notmatch "append-only") { throw "audit_log DELETE failed for unexpected reason." }

$truncateAuditOutput = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "TRUNCATE public.audit_log;" 2>&1
$truncateAuditExit = $LASTEXITCODE
Write-Output $truncateAuditOutput
if ($truncateAuditExit -eq 0) { throw "audit_log TRUNCATE should be blocked by immutability trigger." }
if (($truncateAuditOutput | Out-String) -notmatch "append-only") { throw "audit_log TRUNCATE failed for unexpected reason." }

Write-Output "--- verify realtime publication does not expose sensitive tables ---"
$publishedTables = Run-Sql "SELECT COALESCE(string_agg(tablename, ','), '') FROM pg_publication_tables WHERE pubname='supabase_realtime';"
Write-Output "Realtime published tables: $publishedTables"
if ($publishedTables -match "audit_log|nutrition_import") {
  throw "Sensitive tables exposed via realtime publication: $publishedTables"
}

Write-Output "--- verify auth user deletion preserves audit history with null changed_by ---"
$deleteAuditedUserOutput = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "DELETE FROM auth.users WHERE id='$otherId';" 2>&1
$deleteAuditedUserExit = $LASTEXITCODE
Write-Output $deleteAuditedUserOutput
if ($deleteAuditedUserExit -ne 0) { throw "Deleting an audited auth user failed unexpectedly." }
$deletedUserProfileCount = Run-Sql "SELECT count(*) FROM public.user_profiles WHERE id='$otherId';"
$auditRowsForDeletedUser = Run-Sql "SELECT count(*) FROM public.audit_log WHERE table_name='user_profiles' AND action='user_role_changed' AND record_id='$otherId';"
$auditRowsNullChangedBy = Run-Sql "SELECT count(*) FROM public.audit_log WHERE table_name='user_profiles' AND action='user_role_changed' AND record_id='$otherId' AND changed_by IS NULL;"
Write-Output "deleted user profile count: $deletedUserProfileCount"
Write-Output "audit rows retained for deleted user: $auditRowsForDeletedUser"
Write-Output "audit rows with null changed_by: $auditRowsNullChangedBy"
if ([int]$deletedUserProfileCount -ne 0) { throw "Deleted auth user still has user_profile row." }
if ([int]$auditRowsForDeletedUser -lt 1) { throw "Audit history was not retained for deleted user." }
if ([int]$auditRowsNullChangedBy -lt 1) { throw "Expected deleted user's audit changed_by to be nulled by FK action." }
Write-Output "--- verify updated_at trigger exists and fires ---"
$trg = Run-Sql "SELECT count(*) FROM pg_trigger WHERE tgname='trg_exercises_set_updated_at';"
if ([int]$trg -ne 1) {
  throw "updated_at trigger missing for exercises."
}
Run-Sql-Command "INSERT INTO public.exercises (slug, name, notes) VALUES ('hammer-bench', 'Hammer Bench', 'before') ON CONFLICT (slug) DO UPDATE SET notes='before';"
Start-Sleep -Seconds 1
Run-Sql-Command "UPDATE public.exercises SET notes='after' WHERE slug='hammer-bench';"
$updated = Run-Sql "SELECT updated_at > created_at FROM public.exercises WHERE slug='hammer-bench';"
if ($updated.Trim() -ne "t") {
  throw "updated_at trigger did not advance updated_at after update."
}

Write-Output "=== Hammer smoke tests passed ==="



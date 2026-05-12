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
$fnCount = Run-Sql "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND proname IN ('set_updated_at','current_user_role','is_owner_or_admin','can_view_visibility','handle_new_auth_user');"
Write-Output "Helper functions: $fnCount"
if ([int]$fnCount -ne 5) {
  throw "Missing expected helper functions."
}

Write-Output "--- verify policy coverage ---"
$policyCount = Run-Sql "SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename IN ('audit_log','dataset_exports','datasets','exercises','confounder_logs','experiments','measurements','nutrition_import_batches','nutrition_import_rows','nutrient_definitions','nutrition_log_nutrients','nutrition_logs','supplement_logs','supplements','user_profiles','exercise_sets','workout_sessions');"
Write-Output "Policies: $policyCount"
if ([int]$policyCount -lt 50) {
  throw "Expected broad RLS policy coverage."
}

Write-Output "--- verify supplement dedup index exists ---"
$idx = Run-Sql "SELECT count(*) FROM pg_indexes WHERE schemaname='public' AND indexname='idx_supplement_logs_dedup';"
if ([int]$idx -ne 1) {
  throw "Supplement dedup index missing."
}

Write-Output "--- verify supplement dedup rejects duplicate NULL time_taken rows ---"
Run-Sql-Command "INSERT INTO public.supplements (slug, name) VALUES ('hammer-creatine', 'Hammer Creatine') ON CONFLICT DO NOTHING;"
Run-Sql-Command "DELETE FROM public.supplement_logs WHERE supplement_id = (SELECT id FROM public.supplements WHERE slug='hammer-creatine');"
Run-Sql-Command "INSERT INTO public.supplement_logs (supplement_id, date) SELECT id, CURRENT_DATE FROM public.supplements WHERE slug='hammer-creatine';"
$duplicateOutput = docker exec $container psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "INSERT INTO public.supplement_logs (supplement_id, date) SELECT id, CURRENT_DATE FROM public.supplements WHERE slug='hammer-creatine';" 2>&1
$duplicateExitCode = $LASTEXITCODE
Write-Output $duplicateOutput
if ($duplicateExitCode -eq 0) {
  throw "Supplement dedup index did not reject duplicate NULL time_taken rows."
}
if (($duplicateOutput | Out-String) -notmatch "duplicate key value violates unique constraint") {
  throw "Supplement dedup failed for an unexpected reason."
}

Write-Output "--- verify audit_log immutability policies ---"
$auditMutablePolicies = Run-Sql "SELECT count(*) FROM pg_policies WHERE schemaname='public' AND tablename='audit_log' AND cmd IN ('UPDATE','DELETE');"
if ([int]$auditMutablePolicies -ne 0) {
  throw "audit_log should not expose UPDATE/DELETE policies."
}

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


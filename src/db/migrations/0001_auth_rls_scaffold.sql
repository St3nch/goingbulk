-- GoingBulk manual migration
-- Applies after 0000_nervous_ozymandias.sql
--
-- Contents:
--   A. set_updated_at trigger function + per-table triggers
--   B. supplement_logs dedup expression index
--   C. auth.users FK + bootstrap trigger
--   D. RLS helper functions
--   E. RLS policies for all MVP tables
--
-- Review carefully before applying.
-- Apply with: psql $DATABASE_URL -f this_file.sql
-- Or paste into Supabase SQL editor (local or remote).

-- =====================================================
-- A. updated_at trigger function and per-table triggers
-- =====================================================

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$func$;

CREATE TRIGGER trg_user_profiles_set_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_nutrition_import_batches_set_updated_at
  BEFORE UPDATE ON public.nutrition_import_batches
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_nutrition_logs_set_updated_at
  BEFORE UPDATE ON public.nutrition_logs
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_nutrient_definitions_set_updated_at
  BEFORE UPDATE ON public.nutrient_definitions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_measurements_set_updated_at
  BEFORE UPDATE ON public.measurements
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_exercises_set_updated_at
  BEFORE UPDATE ON public.exercises
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_workout_sessions_set_updated_at
  BEFORE UPDATE ON public.workout_sessions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_exercise_sets_set_updated_at
  BEFORE UPDATE ON public.exercise_sets
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_supplements_set_updated_at
  BEFORE UPDATE ON public.supplements
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_supplement_logs_set_updated_at
  BEFORE UPDATE ON public.supplement_logs
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_experiments_set_updated_at
  BEFORE UPDATE ON public.experiments
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_datasets_set_updated_at
  BEFORE UPDATE ON public.datasets
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- No updated_at triggers for:
--   audit_log          (append-only)
--   nutrition_import_rows (append-only)
--   confounder_logs    (write-once)
--   dataset_exports    (append-only)
--   nutrition_log_nutrients (append-only)

-- =====================================================
-- B. Supplement dedup expression index
-- Replaces broken Drizzle unique index.
-- Standard Postgres unique indexes treat NULL as distinct,
-- so (date, supplement_id, NULL) is never deduplicated.
-- COALESCE maps NULL time_taken to '' to allow dedup.
-- =====================================================

CREATE UNIQUE INDEX IF NOT EXISTS idx_supplement_logs_dedup
  ON public.supplement_logs(date, supplement_id, COALESCE(time_taken, ''));

-- =====================================================
-- C. auth.users FK + bootstrap trigger
-- =====================================================

-- Link user_profiles.id to Supabase auth.users.
-- ON DELETE CASCADE: deleting auth user removes their profile.
ALTER TABLE public.user_profiles
  ADD CONSTRAINT fk_user_profiles_auth
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Auto-create a user_profiles row when a new auth user signs up.
-- Assigns role 'public' by default.
-- Owner must be manually promoted:
--   UPDATE public.user_profiles SET role = 'owner' WHERE email = 'you@example.com';
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $func$
BEGIN
  INSERT INTO public.user_profiles (id, email, role)
  VALUES (NEW.id, NEW.email, 'public')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$func$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- =====================================================
-- D. RLS helper functions
-- All SECURITY DEFINER with SET search_path = public
-- to prevent path injection.
-- =====================================================

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS public.user_role_enum
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $func$
  SELECT role FROM public.user_profiles WHERE id = auth.uid();
$func$;

CREATE OR REPLACE FUNCTION public.is_owner_or_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $func$
  SELECT COALESCE(
    (SELECT role IN ('owner', 'admin')
     FROM public.user_profiles
     WHERE id = auth.uid()),
    false
  );
$func$;

CREATE OR REPLACE FUNCTION public.can_view_visibility(record_visibility public.visibility_enum)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $func$
  SELECT CASE
    WHEN record_visibility = 'public' THEN true
    WHEN record_visibility = 'professional' THEN
      COALESCE(public.current_user_role() IN ('owner', 'admin', 'professional_viewer'), false)
    WHEN record_visibility = 'internal' THEN
      COALESCE(public.current_user_role() IN ('owner', 'admin', 'editor'), false)
    WHEN record_visibility = 'private' THEN
      COALESCE(public.current_user_role() IN ('owner', 'admin'), false)
    ELSE false
  END;
$func$;

-- =====================================================
-- E. RLS policies
-- =====================================================

-- -------------------------------------------------
-- user_profiles
-- Owner/admin can read all. Users can read/update own.
-- Insert allowed for auth bootstrap (SECURITY DEFINER
-- handle_new_auth_user) and self/admin.
-- -------------------------------------------------
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_profiles_select"
  ON public.user_profiles FOR SELECT
  USING (id = auth.uid() OR public.is_owner_or_admin());

CREATE POLICY "user_profiles_insert"
  ON public.user_profiles FOR INSERT
  WITH CHECK (id = auth.uid() OR public.is_owner_or_admin());

CREATE POLICY "user_profiles_update"
  ON public.user_profiles FOR UPDATE
  USING (id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (id = auth.uid() OR public.is_owner_or_admin());

CREATE POLICY "user_profiles_delete"
  ON public.user_profiles FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- nutrition_import_batches  (admin-only)
-- -------------------------------------------------
ALTER TABLE public.nutrition_import_batches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "import_batches_admin_all"
  ON public.nutrition_import_batches FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

-- -------------------------------------------------
-- nutrition_import_rows  (admin-only)
-- -------------------------------------------------
ALTER TABLE public.nutrition_import_rows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "import_rows_admin_all"
  ON public.nutrition_import_rows FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

-- -------------------------------------------------
-- nutrition_logs  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nutrition_logs_select"
  ON public.nutrition_logs FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "nutrition_logs_insert"
  ON public.nutrition_logs FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "nutrition_logs_update"
  ON public.nutrition_logs FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "nutrition_logs_delete"
  ON public.nutrition_logs FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- nutrient_definitions  (public read, admin write)
-- -------------------------------------------------
ALTER TABLE public.nutrient_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nutrient_definitions_select"
  ON public.nutrient_definitions FOR SELECT
  USING (true);

CREATE POLICY "nutrient_definitions_insert"
  ON public.nutrient_definitions FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "nutrient_definitions_update"
  ON public.nutrient_definitions FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "nutrient_definitions_delete"
  ON public.nutrient_definitions FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- nutrition_log_nutrients  (inherits from nutrition_logs)
-- -------------------------------------------------
ALTER TABLE public.nutrition_log_nutrients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nutrition_log_nutrients_select"
  ON public.nutrition_log_nutrients FOR SELECT
  USING (
    public.can_view_visibility(
      (SELECT visibility FROM public.nutrition_logs WHERE id = nutrition_log_id)
    )
  );

CREATE POLICY "nutrition_log_nutrients_insert"
  ON public.nutrition_log_nutrients FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "nutrition_log_nutrients_update"
  ON public.nutrition_log_nutrients FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "nutrition_log_nutrients_delete"
  ON public.nutrition_log_nutrients FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- measurements  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "measurements_select"
  ON public.measurements FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "measurements_insert"
  ON public.measurements FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "measurements_update"
  ON public.measurements FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "measurements_delete"
  ON public.measurements FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- exercises  (public read, admin write)
-- -------------------------------------------------
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "exercises_select"
  ON public.exercises FOR SELECT
  USING (true);

CREATE POLICY "exercises_insert"
  ON public.exercises FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "exercises_update"
  ON public.exercises FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "exercises_delete"
  ON public.exercises FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- workout_sessions  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "workout_sessions_select"
  ON public.workout_sessions FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "workout_sessions_insert"
  ON public.workout_sessions FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "workout_sessions_update"
  ON public.workout_sessions FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "workout_sessions_delete"
  ON public.workout_sessions FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- exercise_sets  (inherits visibility from workout_sessions)
-- -------------------------------------------------
ALTER TABLE public.exercise_sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "exercise_sets_select"
  ON public.exercise_sets FOR SELECT
  USING (
    public.can_view_visibility(
      (SELECT visibility FROM public.workout_sessions WHERE id = workout_session_id)
    )
  );

CREATE POLICY "exercise_sets_insert"
  ON public.exercise_sets FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "exercise_sets_update"
  ON public.exercise_sets FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "exercise_sets_delete"
  ON public.exercise_sets FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- supplements  (public read, admin write)
-- -------------------------------------------------
ALTER TABLE public.supplements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "supplements_select"
  ON public.supplements FOR SELECT
  USING (true);

CREATE POLICY "supplements_insert"
  ON public.supplements FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "supplements_update"
  ON public.supplements FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "supplements_delete"
  ON public.supplements FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- supplement_logs  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.supplement_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "supplement_logs_select"
  ON public.supplement_logs FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "supplement_logs_insert"
  ON public.supplement_logs FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "supplement_logs_update"
  ON public.supplement_logs FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "supplement_logs_delete"
  ON public.supplement_logs FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- experiments  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.experiments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "experiments_select"
  ON public.experiments FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "experiments_insert"
  ON public.experiments FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "experiments_update"
  ON public.experiments FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "experiments_delete"
  ON public.experiments FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- confounder_logs  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.confounder_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "confounder_logs_select"
  ON public.confounder_logs FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "confounder_logs_insert"
  ON public.confounder_logs FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "confounder_logs_update"
  ON public.confounder_logs FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "confounder_logs_delete"
  ON public.confounder_logs FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- datasets  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.datasets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "datasets_select"
  ON public.datasets FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "datasets_insert"
  ON public.datasets FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "datasets_update"
  ON public.datasets FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "datasets_delete"
  ON public.datasets FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- dataset_exports  (visibility-based)
-- -------------------------------------------------
ALTER TABLE public.dataset_exports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "dataset_exports_select"
  ON public.dataset_exports FOR SELECT
  USING (public.can_view_visibility(visibility));

CREATE POLICY "dataset_exports_insert"
  ON public.dataset_exports FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "dataset_exports_update"
  ON public.dataset_exports FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "dataset_exports_delete"
  ON public.dataset_exports FOR DELETE
  USING (public.is_owner_or_admin());

-- -------------------------------------------------
-- audit_log  (admin-only; no UPDATE or DELETE policy)
-- Audit records must never be modified or removed.
-- -------------------------------------------------
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_log_select"
  ON public.audit_log FOR SELECT
  USING (public.is_owner_or_admin());

CREATE POLICY "audit_log_insert"
  ON public.audit_log FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

-- No UPDATE policy on audit_log.
-- No DELETE policy on audit_log.

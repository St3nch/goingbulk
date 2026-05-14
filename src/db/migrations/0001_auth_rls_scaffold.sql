-- GoingBulk manual migration
-- Applies after 0000_wakeful_cammi.sql.
--
-- Purpose:
--   A. updated_at trigger function + per-table triggers
--   B. supplement_logs per-user dedup expression index
--   C. auth.users FK + bootstrap trigger
--   D. RLS helper functions
--   E. audit_log immutability trigger
--   F. denied-by-default API role grants
--   G. ownership-aware RLS policies for all MVP tables

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

-- =====================================================
-- B. Supplement dedup expression index
-- =====================================================

CREATE UNIQUE INDEX IF NOT EXISTS idx_supplement_logs_dedup
  ON public.supplement_logs(user_id, date, supplement_id, COALESCE(time_taken, ''));

-- =====================================================
-- C. auth.users FK + bootstrap trigger
-- =====================================================

ALTER TABLE public.user_profiles
  ADD CONSTRAINT fk_user_profiles_auth
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

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

CREATE OR REPLACE FUNCTION public.can_view_owned_visibility(
  record_user_id uuid,
  record_visibility public.visibility_enum
)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $func$
  SELECT CASE
    WHEN record_user_id = auth.uid() THEN true
    WHEN public.is_owner_or_admin() THEN true
    WHEN record_visibility = 'public' THEN true
    WHEN record_visibility = 'professional' THEN
      COALESCE(public.current_user_role() = 'professional_viewer', false)
    ELSE false
  END;
$func$;

CREATE OR REPLACE FUNCTION public.can_view_owned_dataset(
  record_owner_id uuid,
  record_visibility public.visibility_enum
)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $func$
  SELECT public.can_view_owned_visibility(record_owner_id, record_visibility);
$func$;

-- =====================================================
-- E. hardening triggers
-- =====================================================

CREATE OR REPLACE FUNCTION public.prevent_user_role_self_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $func$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role
     AND NEW.id = auth.uid()
     AND NOT public.is_owner_or_admin() THEN
    RAISE EXCEPTION 'role changes require owner/admin';
  END IF;
  RETURN NEW;
END;
$func$;

CREATE TRIGGER trg_user_profiles_prevent_role_self_change
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_user_role_self_change();

CREATE OR REPLACE FUNCTION public.audit_log_immutable()
RETURNS trigger
LANGUAGE plpgsql
AS $func$
BEGIN
  RAISE EXCEPTION 'audit_log is append-only; operation % is not allowed', TG_OP;
END;
$func$;

CREATE TRIGGER trg_audit_log_no_update
  BEFORE UPDATE ON public.audit_log
  FOR EACH ROW EXECUTE FUNCTION public.audit_log_immutable();

CREATE TRIGGER trg_audit_log_no_delete
  BEFORE DELETE ON public.audit_log
  FOR EACH ROW EXECUTE FUNCTION public.audit_log_immutable();

CREATE TRIGGER trg_audit_log_no_truncate
  BEFORE TRUNCATE ON public.audit_log
  FOR EACH STATEMENT EXECUTE FUNCTION public.audit_log_immutable();

-- =====================================================
-- F. API role table grants
-- =====================================================

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;
REVOKE UPDATE, DELETE, TRUNCATE ON public.audit_log FROM PUBLIC, anon, authenticated;

REVOKE EXECUTE ON FUNCTION public.current_user_role() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_owner_or_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.can_view_visibility(public.visibility_enum) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.can_view_owned_visibility(uuid, public.visibility_enum) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.can_view_owned_dataset(uuid, public.visibility_enum) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.handle_new_auth_user() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.prevent_user_role_self_change() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.audit_log_immutable() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.set_updated_at() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.current_user_role() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_owner_or_admin() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.can_view_visibility(public.visibility_enum) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.can_view_owned_visibility(uuid, public.visibility_enum) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.can_view_owned_dataset(uuid, public.visibility_enum) TO anon, authenticated;

GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT ON TABLE public.nutrient_definitions TO anon, authenticated;
GRANT SELECT ON TABLE public.exercises TO anon, authenticated;
GRANT SELECT ON TABLE public.supplements TO anon, authenticated;

GRANT SELECT ON TABLE public.nutrition_logs TO anon, authenticated;
GRANT SELECT ON TABLE public.measurements TO anon, authenticated;
GRANT SELECT ON TABLE public.workout_sessions TO anon, authenticated;
GRANT SELECT ON TABLE public.supplement_logs TO anon, authenticated;
GRANT SELECT ON TABLE public.experiments TO anon, authenticated;
GRANT SELECT ON TABLE public.confounder_logs TO anon, authenticated;
GRANT SELECT ON TABLE public.datasets TO anon, authenticated;
GRANT SELECT ON TABLE public.dataset_exports TO anon, authenticated;
GRANT SELECT ON TABLE public.nutrition_log_nutrients TO anon, authenticated;
GRANT SELECT ON TABLE public.exercise_sets TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.nutrition_logs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.measurements TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.workout_sessions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.supplement_logs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.experiments TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.confounder_logs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.datasets TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.dataset_exports TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.nutrition_log_nutrients TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.exercise_sets TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.nutrient_definitions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.exercises TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.supplements TO authenticated;

GRANT INSERT ON TABLE public.audit_log TO authenticated;

-- Intentionally no anon/authenticated grants for import operational tables.
REVOKE ALL ON TABLE public.nutrition_import_batches FROM anon, authenticated;
REVOKE ALL ON TABLE public.nutrition_import_rows FROM anon, authenticated;

-- =====================================================
-- G. RLS policies
-- =====================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_profiles_select_self_admin"
  ON public.user_profiles FOR SELECT
  USING (id = auth.uid() OR public.is_owner_or_admin());

CREATE POLICY "user_profiles_insert_self_admin"
  ON public.user_profiles FOR INSERT
  WITH CHECK (id = auth.uid() OR public.is_owner_or_admin());

CREATE POLICY "user_profiles_update_self"
  ON public.user_profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "user_profiles_update_admin"
  ON public.user_profiles FOR UPDATE
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

CREATE POLICY "user_profiles_delete_admin"
  ON public.user_profiles FOR DELETE
  USING (public.is_owner_or_admin());

ALTER TABLE public.nutrition_import_batches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "import_batches_admin_all"
  ON public.nutrition_import_batches FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

ALTER TABLE public.nutrition_import_rows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "import_rows_admin_all"
  ON public.nutrition_import_rows FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "nutrition_logs_select"
  ON public.nutrition_logs FOR SELECT
  USING (public.can_view_owned_visibility(user_id, visibility));
CREATE POLICY "nutrition_logs_insert"
  ON public.nutrition_logs FOR INSERT
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "nutrition_logs_update"
  ON public.nutrition_logs FOR UPDATE
  USING (user_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "nutrition_logs_delete"
  ON public.nutrition_logs FOR DELETE
  USING (user_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.nutrient_definitions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "nutrient_definitions_select"
  ON public.nutrient_definitions FOR SELECT
  USING (true);
CREATE POLICY "nutrient_definitions_write_admin"
  ON public.nutrient_definitions FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

ALTER TABLE public.nutrition_log_nutrients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "nutrition_log_nutrients_select"
  ON public.nutrition_log_nutrients FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.nutrition_logs nl
      WHERE nl.id = nutrition_log_id
        AND public.can_view_owned_visibility(nl.user_id, nl.visibility)
    )
  );
CREATE POLICY "nutrition_log_nutrients_write_owner_admin"
  ON public.nutrition_log_nutrients FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.nutrition_logs nl
      WHERE nl.id = nutrition_log_id
        AND (nl.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.nutrition_logs nl
      WHERE nl.id = nutrition_log_id
        AND (nl.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  );

ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "measurements_select"
  ON public.measurements FOR SELECT
  USING (public.can_view_owned_visibility(user_id, visibility));
CREATE POLICY "measurements_insert"
  ON public.measurements FOR INSERT
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "measurements_update"
  ON public.measurements FOR UPDATE
  USING (user_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "measurements_delete"
  ON public.measurements FOR DELETE
  USING (user_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY "exercises_select"
  ON public.exercises FOR SELECT
  USING (true);
CREATE POLICY "exercises_write_admin"
  ON public.exercises FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "workout_sessions_select"
  ON public.workout_sessions FOR SELECT
  USING (public.can_view_owned_visibility(user_id, visibility));
CREATE POLICY "workout_sessions_insert"
  ON public.workout_sessions FOR INSERT
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "workout_sessions_update"
  ON public.workout_sessions FOR UPDATE
  USING (user_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "workout_sessions_delete"
  ON public.workout_sessions FOR DELETE
  USING (user_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.exercise_sets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "exercise_sets_select"
  ON public.exercise_sets FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.workout_sessions ws
      WHERE ws.id = workout_session_id
        AND public.can_view_owned_visibility(ws.user_id, ws.visibility)
    )
  );
CREATE POLICY "exercise_sets_write_owner_admin"
  ON public.exercise_sets FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.workout_sessions ws
      WHERE ws.id = workout_session_id
        AND (ws.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.workout_sessions ws
      WHERE ws.id = workout_session_id
        AND (ws.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  );

ALTER TABLE public.supplements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "supplements_select"
  ON public.supplements FOR SELECT
  USING (true);
CREATE POLICY "supplements_write_admin"
  ON public.supplements FOR ALL
  USING (public.is_owner_or_admin())
  WITH CHECK (public.is_owner_or_admin());

ALTER TABLE public.supplement_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "supplement_logs_select"
  ON public.supplement_logs FOR SELECT
  USING (public.can_view_owned_visibility(user_id, visibility));
CREATE POLICY "supplement_logs_insert"
  ON public.supplement_logs FOR INSERT
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "supplement_logs_update"
  ON public.supplement_logs FOR UPDATE
  USING (user_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "supplement_logs_delete"
  ON public.supplement_logs FOR DELETE
  USING (user_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.experiments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "experiments_select"
  ON public.experiments FOR SELECT
  USING (public.can_view_owned_visibility(user_id, visibility));
CREATE POLICY "experiments_insert"
  ON public.experiments FOR INSERT
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "experiments_update"
  ON public.experiments FOR UPDATE
  USING (user_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "experiments_delete"
  ON public.experiments FOR DELETE
  USING (user_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.confounder_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "confounder_logs_select"
  ON public.confounder_logs FOR SELECT
  USING (public.can_view_owned_visibility(user_id, visibility));
CREATE POLICY "confounder_logs_insert"
  ON public.confounder_logs FOR INSERT
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "confounder_logs_update"
  ON public.confounder_logs FOR UPDATE
  USING (user_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "confounder_logs_delete"
  ON public.confounder_logs FOR DELETE
  USING (user_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.datasets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "datasets_select"
  ON public.datasets FOR SELECT
  USING (public.can_view_owned_dataset(owner_id, visibility));
CREATE POLICY "datasets_insert"
  ON public.datasets FOR INSERT
  WITH CHECK (owner_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "datasets_update"
  ON public.datasets FOR UPDATE
  USING (owner_id = auth.uid() OR public.is_owner_or_admin())
  WITH CHECK (owner_id = auth.uid() OR public.is_owner_or_admin());
CREATE POLICY "datasets_delete"
  ON public.datasets FOR DELETE
  USING (owner_id = auth.uid() OR public.is_owner_or_admin());

ALTER TABLE public.dataset_exports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dataset_exports_select"
  ON public.dataset_exports FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.datasets d
      WHERE d.id = dataset_id
        AND public.can_view_owned_dataset(d.owner_id, d.visibility)
    )
  );
CREATE POLICY "dataset_exports_write_owner_admin"
  ON public.dataset_exports FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.datasets d
      WHERE d.id = dataset_id
        AND (d.owner_id = auth.uid() OR public.is_owner_or_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.datasets d
      WHERE d.id = dataset_id
        AND (d.owner_id = auth.uid() OR public.is_owner_or_admin())
    )
  );

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "audit_log_select_admin"
  ON public.audit_log FOR SELECT
  USING (public.is_owner_or_admin());
CREATE POLICY "audit_log_insert_admin"
  ON public.audit_log FOR INSERT
  WITH CHECK (public.is_owner_or_admin());

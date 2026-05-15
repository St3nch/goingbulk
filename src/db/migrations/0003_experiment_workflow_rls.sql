-- GoingBulk manual migration
-- Applies after 0002_easy_thena.sql.
--
-- Purpose:
--   A. RLS enable (fail-closed: done first so tables are never exposed without policies)
--   B. updated_at triggers for experiment workflow child tables
--   C. API grants for experiment workflow child tables
--      Posture: REVOKE ALL then explicit GRANT only what is needed.
--      Authenticated users get full DML; anon gets SELECT only.
--      Child-table RLS policies (section D) further restrict what rows
--      each role can actually see or write.
--   D. Parent-experiment-inherited RLS policies

-- =====================================================
-- A. Enable RLS first (fail-closed ordering)
--    Tables have no policies yet at this point; all access is denied
--    until section D adds the explicit policies below.
-- =====================================================

ALTER TABLE public.experiment_interventions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experiment_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experiment_evidence_links ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- B. updated_at triggers
-- =====================================================

DROP TRIGGER IF EXISTS trg_experiment_interventions_set_updated_at ON public.experiment_interventions;
CREATE TRIGGER trg_experiment_interventions_set_updated_at
  BEFORE UPDATE ON public.experiment_interventions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_experiment_outcomes_set_updated_at ON public.experiment_outcomes;
CREATE TRIGGER trg_experiment_outcomes_set_updated_at
  BEFORE UPDATE ON public.experiment_outcomes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_experiment_evidence_links_set_updated_at ON public.experiment_evidence_links;
CREATE TRIGGER trg_experiment_evidence_links_set_updated_at
  BEFORE UPDATE ON public.experiment_evidence_links
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =====================================================
-- C. API role grants
-- =====================================================

REVOKE ALL ON TABLE public.experiment_interventions FROM anon, authenticated;
REVOKE ALL ON TABLE public.experiment_outcomes FROM anon, authenticated;
REVOKE ALL ON TABLE public.experiment_evidence_links FROM anon, authenticated;

GRANT SELECT ON TABLE public.experiment_interventions TO anon, authenticated;
GRANT SELECT ON TABLE public.experiment_outcomes TO anon, authenticated;
GRANT SELECT ON TABLE public.experiment_evidence_links TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.experiment_interventions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.experiment_outcomes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.experiment_evidence_links TO authenticated;

-- =====================================================
-- D. RLS policies
--    Child tables inherit ownership and visibility from the parent
--    experiments row. No user_id or visibility column on child tables.
--    Note: the parent-subquery RLS pattern used here is correct for
--    current MVP volumes. Revisit with denormalized user_id/visibility
--    columns on child tables if query volume grows significantly.
-- =====================================================

-- experiment_interventions

DROP POLICY IF EXISTS "experiment_interventions_select" ON public.experiment_interventions;
CREATE POLICY "experiment_interventions_select"
  ON public.experiment_interventions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND public.can_view_owned_visibility(e.user_id, e.visibility)
    )
  );

DROP POLICY IF EXISTS "experiment_interventions_write_owner_admin" ON public.experiment_interventions;
CREATE POLICY "experiment_interventions_write_owner_admin"
  ON public.experiment_interventions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND (e.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND (e.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  );

-- experiment_outcomes

DROP POLICY IF EXISTS "experiment_outcomes_select" ON public.experiment_outcomes;
CREATE POLICY "experiment_outcomes_select"
  ON public.experiment_outcomes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND public.can_view_owned_visibility(e.user_id, e.visibility)
    )
  );

DROP POLICY IF EXISTS "experiment_outcomes_write_owner_admin" ON public.experiment_outcomes;
CREATE POLICY "experiment_outcomes_write_owner_admin"
  ON public.experiment_outcomes FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND (e.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND (e.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  );

-- experiment_evidence_links

DROP POLICY IF EXISTS "experiment_evidence_links_select" ON public.experiment_evidence_links;
CREATE POLICY "experiment_evidence_links_select"
  ON public.experiment_evidence_links FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND public.can_view_owned_visibility(e.user_id, e.visibility)
    )
  );

DROP POLICY IF EXISTS "experiment_evidence_links_write_owner_admin" ON public.experiment_evidence_links;
CREATE POLICY "experiment_evidence_links_write_owner_admin"
  ON public.experiment_evidence_links FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND (e.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.experiments e
      WHERE e.id = experiment_id
        AND (e.user_id = auth.uid() OR public.is_owner_or_admin())
    )
  );

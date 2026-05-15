import { sql } from "drizzle-orm";
import { check, date, index, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";

import { confidenceEnum, experimentStatusEnum, visibilityEnum } from "./enums";
import { supplements } from "./supplements";
import { userProfiles } from "./user-profiles";

export const experiments = pgTable(
  "experiments",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id")
      .notNull()
      .references(() => userProfiles.id, { onDelete: "cascade" }),
    title: text("title").notNull(),
    slug: text("slug").notNull().unique(),
    experimentType: text("experiment_type").notNull().default("baseline"),
    status: experimentStatusEnum("status").notNull().default("planned"),
    question: text("question"),
    hypothesis: text("hypothesis"),
    protocolSummary: text("protocol_summary"),
    baselineStart: date("baseline_start"),
    baselineEnd: date("baseline_end"),
    interventionStart: date("intervention_start"),
    interventionEnd: date("intervention_end"),
    followupStart: date("followup_start"),
    followupEnd: date("followup_end"),
    primaryMetrics: text("primary_metrics").array(),
    secondaryMetrics: text("secondary_metrics").array(),
    confidenceLevel: confidenceEnum("confidence_level").default("medium"),
    verdict: text("verdict"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("idx_experiments_user_id").on(table.userId),
    index("idx_experiments_status").on(table.status),
    index("idx_experiments_visibility").on(table.visibility),
  ],
);

export const experimentInterventions = pgTable(
  "experiment_interventions",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    experimentId: uuid("experiment_id")
      .notNull()
      .references(() => experiments.id, { onDelete: "cascade" }),
    interventionType: text("intervention_type").notNull(),
    supplementId: uuid("supplement_id").references(() => supplements.id, {
      onDelete: "set null",
    }),
    title: text("title").notNull(),
    description: text("description"),
    dose: text("dose"),
    unit: text("unit"),
    timing: text("timing"),
    frequency: text("frequency"),
    startDate: date("start_date"),
    endDate: date("end_date"),
    protocolNotes: text("protocol_notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check(
      "experiment_interventions_type_check",
      sql`${table.interventionType} IN ('supplement', 'nutrition', 'training', 'sleep', 'recovery', 'behavior', 'device', 'other')`,
    ),
    index("idx_experiment_interventions_experiment_id").on(table.experimentId),
    index("idx_experiment_interventions_type").on(table.interventionType),
  ],
);

export const experimentOutcomes = pgTable(
  "experiment_outcomes",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    experimentId: uuid("experiment_id")
      .notNull()
      .references(() => experiments.id, { onDelete: "cascade" }),
    outcomeType: text("outcome_type").notNull().default("primary"),
    metricKey: text("metric_key").notNull(),
    expectedDirection: text("expected_direction"),
    observedDirection: text("observed_direction"),
    baselineValue: text("baseline_value"),
    targetValue: text("target_value"),
    observedValue: text("observed_value"),
    unit: text("unit"),
    confidenceLevel: confidenceEnum("confidence_level").default("medium"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check(
      "experiment_outcomes_type_check",
      sql`${table.outcomeType} IN ('primary', 'secondary', 'safety', 'exploratory')`,
    ),
    check(
      "experiment_outcomes_expected_direction_check",
      sql`${table.expectedDirection} IS NULL OR ${table.expectedDirection} IN ('increase', 'decrease', 'no_change', 'stabilize', 'unknown')`,
    ),
    check(
      "experiment_outcomes_observed_direction_check",
      sql`${table.observedDirection} IS NULL OR ${table.observedDirection} IN ('increase', 'decrease', 'no_change', 'stabilize', 'unknown')`,
    ),
    index("idx_experiment_outcomes_experiment_id").on(table.experimentId),
    index("idx_experiment_outcomes_metric_key").on(table.metricKey),
  ],
);

export const experimentEvidenceLinks = pgTable(
  "experiment_evidence_links",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    experimentId: uuid("experiment_id")
      .notNull()
      .references(() => experiments.id, { onDelete: "cascade" }),
    sourceType: text("source_type").notNull(),
    evidenceType: text("evidence_type"),
    title: text("title").notNull(),
    url: text("url"),
    doi: text("doi"),
    pmid: text("pmid"),
    citationText: text("citation_text"),
    summary: text("summary"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check(
      "experiment_evidence_links_source_type_check",
      sql`${table.sourceType} IN ('pubmed', 'doi', 'website', 'book', 'video', 'manual_note', 'product_label', 'coach_advice', 'other')`,
    ),
    check(
      "experiment_evidence_links_evidence_type_check",
      sql`${table.evidenceType} IS NULL OR ${table.evidenceType} IN ('meta_analysis', 'systematic_review', 'randomized_controlled_trial', 'controlled_trial', 'observational_human', 'animal_study', 'mechanistic', 'expert_opinion', 'marketing_claim', 'personal_observation', 'unknown')`,
    ),
    index("idx_experiment_evidence_links_experiment_id").on(table.experimentId),
    index("idx_experiment_evidence_links_source_type").on(table.sourceType),
  ],
);

export const confounderLogs = pgTable(
  "confounder_logs",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id")
      .notNull()
      .references(() => userProfiles.id, { onDelete: "cascade" }),
    date: date("date").notNull(),
    confounderType: text("confounder_type").notNull(),
    severity: text("severity"),
    impactAreas: text("impact_areas").array(),
    notes: text("notes"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check(
      "confounder_logs_type_check",
      sql`${table.confounderType} IN ('poor_sleep', 'high_stress', 'illness', 'injury', 'travel', 'missed_workout', 'missed_supplement', 'alcohol', 'new_program', 'calorie_change', 'medication_change')`,
    ),
    check(
      "confounder_logs_severity_check",
      sql`${table.severity} IS NULL OR ${table.severity} IN ('minor', 'moderate', 'major')`,
    ),
    index("idx_confounder_logs_user_id").on(table.userId),
    index("idx_confounder_logs_date").on(table.date),
  ],
);

export type Experiment = typeof experiments.$inferSelect;
export type NewExperiment = typeof experiments.$inferInsert;
export type ExperimentIntervention = typeof experimentInterventions.$inferSelect;
export type NewExperimentIntervention = typeof experimentInterventions.$inferInsert;
export type ExperimentOutcome = typeof experimentOutcomes.$inferSelect;
export type NewExperimentOutcome = typeof experimentOutcomes.$inferInsert;
export type ExperimentEvidenceLink = typeof experimentEvidenceLinks.$inferSelect;
export type NewExperimentEvidenceLink = typeof experimentEvidenceLinks.$inferInsert;
export type ConfounderLog = typeof confounderLogs.$inferSelect;
export type NewConfounderLog = typeof confounderLogs.$inferInsert;

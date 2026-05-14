import { check, index, pgTable, text, timestamp, uuid, date } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

import { confidenceEnum, experimentStatusEnum, visibilityEnum } from "./enums";
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
export type ConfounderLog = typeof confounderLogs.$inferSelect;
export type NewConfounderLog = typeof confounderLogs.$inferInsert;

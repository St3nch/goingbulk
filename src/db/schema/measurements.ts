import { check, index, numeric, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

import { confidenceEnum, logSourceEnum, visibilityEnum } from "./enums";

export const measurements = pgTable(
  "measurements",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    measuredAt: timestamp("measured_at", { withTimezone: true }).notNull(),
    metricKey: text("metric_key").notNull(),
    value: numeric("value", { precision: 10, scale: 3 }).notNull(),
    unit: text("unit").notNull(),
    source: logSourceEnum("source").notNull().default("manual"),
    device: text("device"),
    method: text("method"),
    confidenceLevel: confidenceEnum("confidence_level").notNull().default("high"),
    conditions: text("conditions"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check(
      "measurements_metric_key_check",
      sql`${table.metricKey} IN ('bodyweight', 'waist', 'chest', 'hips', 'neck', 'bicep_left', 'bicep_right', 'thigh_left', 'thigh_right', 'body_fat_estimate', 'blood_pressure_systolic', 'blood_pressure_diastolic', 'resting_heart_rate')`,
    ),
    index("idx_measurements_metric_date").on(table.metricKey, table.measuredAt),
    index("idx_measurements_visibility").on(table.visibility),
  ],
);

export type Measurement = typeof measurements.$inferSelect;
export type NewMeasurement = typeof measurements.$inferInsert;

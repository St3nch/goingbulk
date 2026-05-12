import { date, index, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";

import { adherenceStatusEnum, confidenceEnum, visibilityEnum } from "./enums";

export const supplements = pgTable(
  "supplements",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull().unique(),
    category: text("category"),
    defaultDose: text("default_dose"),
    defaultUnit: text("default_unit"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [index("idx_supplements_slug").on(table.slug)],
);

export const supplementLogs = pgTable(
  "supplement_logs",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    supplementId: uuid("supplement_id")
      .notNull()
      .references(() => supplements.id, { onDelete: "restrict" }),
    date: date("date").notNull(),
    timeTaken: text("time_taken"),
    dose: text("dose"),
    unit: text("unit"),
    adherenceStatus: adherenceStatusEnum("adherence_status").notNull().default("pending"),
    confidenceLevel: confidenceEnum("confidence_level").notNull().default("high"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("idx_supplement_logs_date").on(table.date),
    index("idx_supplement_logs_supplement_date").on(table.supplementId, table.date),
    // Dedup requires a raw SQL expression index because Postgres unique indexes
    // allow multiple NULL time_taken values.
    // Required migration:
    // CREATE UNIQUE INDEX idx_supplement_logs_dedup
    // ON supplement_logs(date, supplement_id, COALESCE(time_taken, ''));
  ],
);

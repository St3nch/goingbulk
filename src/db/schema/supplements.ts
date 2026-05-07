import { index, pgTable, text, timestamp, uniqueIndex, uuid, date } from "drizzle-orm/pg-core";

import { adherenceStatusEnum, confidenceEnum, logSourceEnum, visibilityEnum } from "./enums";

export const supplements = pgTable("supplements", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull().unique(),
  slug: text("slug").notNull().unique(),
  category: text("category"),
  activeIngredient: text("active_ingredient"),
  defaultDose: text("default_dose"),
  defaultUnit: text("default_unit"),
  notes: text("notes"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export const supplementLogs = pgTable(
  "supplement_logs",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    date: date("date").notNull(),
    supplementId: uuid("supplement_id")
      .notNull()
      .references(() => supplements.id, { onDelete: "restrict" }),
    dose: text("dose"),
    unit: text("unit"),
    timeTaken: text("time_taken"),
    adherenceStatus: adherenceStatusEnum("adherence_status").notNull().default("pending"),
    source: logSourceEnum("source").notNull().default("manual"),
    confidenceLevel: confidenceEnum("confidence_level").notNull().default("high"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("idx_supplement_logs_date").on(table.date),
    index("idx_supplement_logs_supplement_date").on(table.supplementId, table.date),
    uniqueIndex("idx_supplement_logs_dedup").on(table.date, table.supplementId, table.timeTaken),
  ],
);

export type Supplement = typeof supplements.$inferSelect;
export type NewSupplement = typeof supplements.$inferInsert;
export type SupplementLog = typeof supplementLogs.$inferSelect;
export type NewSupplementLog = typeof supplementLogs.$inferInsert;

import { check, index, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

import { confidenceEnum, visibilityEnum } from "./enums";
import { userProfiles } from "./user-profiles";

export const datasets = pgTable(
  "datasets",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    slug: text("slug").notNull().unique(),
    title: text("title").notNull(),
    description: text("description"),
    sourceSummary: text("source_summary"),
    methodologySummary: text("methodology_summary"),
    limitations: text("limitations"),
    confidenceLevel: confidenceEnum("confidence_level").notNull().default("medium"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    dateRangeStart: timestamp("date_range_start", { withTimezone: true }).notNull(),
    dateRangeEnd: timestamp("date_range_end", { withTimezone: true }).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check("datasets_date_range_check", sql`${table.dateRangeEnd} >= ${table.dateRangeStart}`),
    index("idx_datasets_visibility").on(table.visibility),
  ],
);

export const datasetExports = pgTable(
  "dataset_exports",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    datasetId: uuid("dataset_id")
      .notNull()
      .references(() => datasets.id, { onDelete: "cascade" }),
    format: text("format").notNull(),
    fileUrl: text("file_url").notNull(),
    rowCount: text("row_count"),
    fileSizeBytes: text("file_size_bytes"),
    generatedBy: uuid("generated_by").references(() => userProfiles.id, {
      onDelete: "set null",
    }),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [index("idx_dataset_exports_dataset").on(table.datasetId)],
);

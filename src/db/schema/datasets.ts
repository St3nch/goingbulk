import { check, index, integer, pgTable, text, timestamp, uuid, date } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

import { visibilityEnum } from "./enums";
import { userProfiles } from "./user-profiles";

export const datasets = pgTable(
  "datasets",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    name: text("name").notNull(),
    slug: text("slug").notNull().unique(),
    description: text("description"),
    dateRangeStart: date("date_range_start").notNull(),
    dateRangeEnd: date("date_range_end").notNull(),
    sourceSummary: text("source_summary"),
    methodologySummary: text("methodology_summary"),
    limitations: text("limitations"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [index("idx_datasets_visibility").on(table.visibility)],
);

export const datasetExports = pgTable(
  "dataset_exports",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    datasetId: uuid("dataset_id")
      .notNull()
      .references(() => datasets.id, { onDelete: "cascade" }),
    format: text("format").notNull().default("csv"),
    fileUrl: text("file_url").notNull(),
    fileSize: integer("file_size"),
    rowCount: integer("row_count"),
    generatedBy: uuid("generated_by").references(() => userProfiles.id),
    generatedAt: timestamp("generated_at", { withTimezone: true }).notNull().defaultNow(),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    notes: text("notes"),
  },
  (table) => [
    check("dataset_exports_format_check", sql`${table.format} IN ('csv', 'json')`),
    index("idx_dataset_exports_dataset").on(table.datasetId),
    index("idx_dataset_exports_visibility").on(table.visibility),
  ],
);

export type Dataset = typeof datasets.$inferSelect;
export type NewDataset = typeof datasets.$inferInsert;
export type DatasetExport = typeof datasetExports.$inferSelect;
export type NewDatasetExport = typeof datasetExports.$inferInsert;

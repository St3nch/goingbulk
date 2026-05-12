import {
  index,
  integer,
  jsonb,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
  date,
} from "drizzle-orm/pg-core";

import { importRowStatusEnum, importStatusEnum, logSourceEnum } from "./enums";
import { userProfiles } from "./user-profiles";

export const nutritionImportBatches = pgTable(
  "nutrition_import_batches",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    source: logSourceEnum("source").notNull().default("cronometer_export"),
    fileName: text("file_name").notNull(),
    fileHash: text("file_hash").notNull(),
    rowCount: integer("row_count"),
    dateRangeStart: date("date_range_start"),
    dateRangeEnd: date("date_range_end"),
    status: importStatusEnum("status").notNull().default("uploaded"),
    approvedAt: timestamp("approved_at", { withTimezone: true }),
    uploadedBy: uuid("uploaded_by")
      .notNull()
      .references(() => userProfiles.id, { onDelete: "restrict" }),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("idx_nutrition_import_batches_file_hash").on(table.fileHash),
    index("idx_nutrition_import_batches_status").on(table.status),
    index("idx_nutrition_import_batches_dates").on(table.dateRangeStart, table.dateRangeEnd),
  ],
);

export const nutritionImportRows = pgTable(
  "nutrition_import_rows",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    batchId: uuid("batch_id")
      .notNull()
      .references(() => nutritionImportBatches.id, { onDelete: "cascade" }),
    rowNumber: integer("row_number").notNull(),
    rowHash: text("row_hash").notNull(),
    rawDate: text("raw_date"),
    rawMeal: text("raw_meal"),
    rawFoodName: text("raw_food_name"),
    rawAmount: text("raw_amount"),
    rawCalories: text("raw_calories"),
    rawProtein: text("raw_protein"),
    rawCarbs: text("raw_carbs"),
    rawFat: text("raw_fat"),
    rawFiber: text("raw_fiber"),
    rawSodium: text("raw_sodium"),
    rawSugar: text("raw_sugar"),
    rawPayload: jsonb("raw_payload").$type<Record<string, unknown>>(),
    status: importRowStatusEnum("status").notNull().default("pending"),
    errorMessage: text("error_message"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("idx_nutrition_import_rows_batch_row_number").on(table.batchId, table.rowNumber),
    uniqueIndex("idx_nutrition_import_rows_batch_row_hash").on(table.batchId, table.rowHash),
    index("idx_nutrition_import_rows_batch").on(table.batchId),
    index("idx_nutrition_import_rows_hash").on(table.rowHash),
  ],
);

export type NutritionImportBatch = typeof nutritionImportBatches.$inferSelect;
export type NewNutritionImportBatch = typeof nutritionImportBatches.$inferInsert;
export type NutritionImportRow = typeof nutritionImportRows.$inferSelect;
export type NewNutritionImportRow = typeof nutritionImportRows.$inferInsert;

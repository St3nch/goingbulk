import {
  index,
  integer,
  numeric,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
  date,
} from "drizzle-orm/pg-core";

import { confidenceEnum, logSourceEnum, visibilityEnum } from "./enums";
import { nutritionImportBatches, nutritionImportRows } from "./nutrition-imports";

export const nutritionLogs = pgTable(
  "nutrition_logs",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    date: date("date").notNull(),
    mealName: text("meal_name"),
    foodNameSnapshot: text("food_name_snapshot").notNull(),
    grams: numeric("grams", { precision: 8, scale: 2 }),
    calories: numeric("calories", { precision: 8, scale: 2 }).notNull(),
    proteinG: numeric("protein_g", { precision: 8, scale: 2 }),
    carbsG: numeric("carbs_g", { precision: 8, scale: 2 }),
    fatG: numeric("fat_g", { precision: 8, scale: 2 }),
    fiberG: numeric("fiber_g", { precision: 8, scale: 2 }),
    sugarG: numeric("sugar_g", { precision: 8, scale: 2 }),
    sodiumMg: numeric("sodium_mg", { precision: 8, scale: 2 }),
    source: logSourceEnum("source").notNull().default("cronometer_export"),
    sourceBatchId: uuid("source_batch_id").references(() => nutritionImportBatches.id, {
      onDelete: "set null",
    }),
    sourceRowId: uuid("source_row_id").references(() => nutritionImportRows.id, {
      onDelete: "set null",
    }),
    confidenceLevel: confidenceEnum("confidence_level").notNull().default("medium"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    index("idx_nutrition_logs_date").on(table.date),
    index("idx_nutrition_logs_visibility").on(table.visibility),
    index("idx_nutrition_logs_source_batch").on(table.sourceBatchId),
    index("idx_nutrition_logs_source_row").on(table.sourceRowId),
  ],
);

export const nutrientDefinitions = pgTable(
  "nutrient_definitions",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    nutrientKey: text("nutrient_key").notNull().unique(),
    displayName: text("display_name").notNull(),
    unit: text("unit").notNull(),
    category: text("category").notNull(),
    sortOrder: integer("sort_order"),
    cronometerColumn: text("cronometer_column"),
    dailyTarget: numeric("daily_target", { precision: 10, scale: 3 }),
    dailyTargetUnit: text("daily_target_unit"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("idx_nutrient_definitions_key").on(table.nutrientKey),
    index("idx_nutrient_definitions_cronometer_column").on(table.cronometerColumn),
  ],
);

export const nutritionLogNutrients = pgTable(
  "nutrition_log_nutrients",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    nutritionLogId: uuid("nutrition_log_id")
      .notNull()
      .references(() => nutritionLogs.id, { onDelete: "cascade" }),
    nutrientKey: text("nutrient_key")
      .notNull()
      .references(() => nutrientDefinitions.nutrientKey),
    value: numeric("value", { precision: 12, scale: 4 }).notNull(),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex("idx_nutrition_log_nutrients_log_key").on(table.nutritionLogId, table.nutrientKey),
    index("idx_nutrition_log_nutrients_log_id").on(table.nutritionLogId),
    index("idx_nutrition_log_nutrients_key").on(table.nutrientKey),
    index("idx_nutrition_log_nutrients_key_value").on(table.nutrientKey, table.value),
  ],
);

export type NutritionLog = typeof nutritionLogs.$inferSelect;
export type NewNutritionLog = typeof nutritionLogs.$inferInsert;
export type NutrientDefinition = typeof nutrientDefinitions.$inferSelect;
export type NewNutrientDefinition = typeof nutrientDefinitions.$inferInsert;
export type NutritionLogNutrient = typeof nutritionLogNutrients.$inferSelect;
export type NewNutritionLogNutrient = typeof nutritionLogNutrients.$inferInsert;

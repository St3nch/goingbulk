import { pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";

export const exercises = pgTable("exercises", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull().unique(),
  slug: text("slug").notNull().unique(),
  primaryMuscleGroup: text("primary_muscle_group"),
  secondaryMuscleGroups: text("secondary_muscle_groups").array(),
  equipment: text("equipment"),
  movementPattern: text("movement_pattern"),
  notes: text("notes"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Exercise = typeof exercises.$inferSelect;
export type NewExercise = typeof exercises.$inferInsert;

import { check, index, integer, pgTable, real, text, timestamp, uuid } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

import { setTypeEnum, visibilityEnum, workoutStatusEnum } from "./enums";
import { exercises } from "./exercises";

export const workoutSessions = pgTable(
  "workout_sessions",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    date: timestamp("date", { withTimezone: true }).notNull(),
    workoutName: text("workout_name"),
    status: workoutStatusEnum("status").notNull().default("planned"),
    startedAt: timestamp("started_at", { withTimezone: true }),
    endedAt: timestamp("ended_at", { withTimezone: true }),
    durationMinutes: integer("duration_minutes"),
    notes: text("notes"),
    visibility: visibilityEnum("visibility").notNull().default("private"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check(
      "workout_sessions_time_check",
      sql`${table.endedAt} IS NULL OR ${table.startedAt} IS NULL OR ${table.endedAt} >= ${table.startedAt}`,
    ),
    check(
      "workout_sessions_duration_check",
      sql`${table.durationMinutes} IS NULL OR ${table.durationMinutes} >= 0`,
    ),
    index("idx_workout_sessions_date").on(table.date),
    index("idx_workout_sessions_visibility").on(table.visibility),
  ],
);

export const exerciseSets = pgTable(
  "exercise_sets",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    workoutSessionId: uuid("workout_session_id")
      .notNull()
      .references(() => workoutSessions.id, { onDelete: "cascade" }),
    exerciseId: uuid("exercise_id")
      .notNull()
      .references(() => exercises.id, { onDelete: "restrict" }),
    setNumber: integer("set_number").notNull(),
    setType: setTypeEnum("set_type").notNull().default("working"),
    actualReps: integer("actual_reps"),
    actualLoad: real("actual_load"),
    loadUnit: text("load_unit"),
    rpe: real("rpe"),
    restSeconds: integer("rest_seconds"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    check("exercise_sets_set_number_check", sql`${table.setNumber} > 0`),
    check(
      "exercise_sets_actual_reps_check",
      sql`${table.actualReps} IS NULL OR ${table.actualReps} >= 0`,
    ),
    check(
      "exercise_sets_actual_load_check",
      sql`${table.actualLoad} IS NULL OR ${table.actualLoad} >= 0`,
    ),
    check(
      "exercise_sets_rest_seconds_check",
      sql`${table.restSeconds} IS NULL OR ${table.restSeconds} >= 0`,
    ),
    check(
      "exercise_sets_rpe_check",
      sql`${table.rpe} IS NULL OR (${table.rpe} >= 1 AND ${table.rpe} <= 10)`,
    ),
    index("idx_exercise_sets_session_set_number").on(table.workoutSessionId, table.setNumber),
    index("idx_exercise_sets_exercise").on(table.exerciseId),
  ],
);

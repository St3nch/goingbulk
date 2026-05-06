import { pgEnum } from "drizzle-orm/pg-core";

export const visibilityEnum = pgEnum("visibility_enum", [
  "private",
  "internal",
  "professional",
  "public",
]);

export const confidenceEnum = pgEnum("confidence_enum", ["low", "medium", "high", "experimental"]);

export const userRoleEnum = pgEnum("user_role_enum", [
  "owner",
  "admin",
  "editor",
  "professional_viewer",
  "public",
]);

export const importStatusEnum = pgEnum("import_status_enum", [
  "uploaded",
  "previewed",
  "approved",
  "rejected",
  "failed",
]);

export const importRowStatusEnum = pgEnum("import_row_status_enum", [
  "pending",
  "validated",
  "normalized",
  "skipped",
  "error",
]);

export const logSourceEnum = pgEnum("log_source_enum", [
  "manual",
  "cronometer_export",
  "device_import",
  "lab_report",
  "estimated",
]);

export const workoutStatusEnum = pgEnum("workout_status_enum", [
  "planned",
  "in_progress",
  "completed",
  "cancelled",
]);

export const setTypeEnum = pgEnum("set_type_enum", [
  "warmup",
  "working",
  "backoff",
  "drop",
  "failure",
  "amrap",
]);

export const adherenceStatusEnum = pgEnum("adherence_status_enum", [
  "pending",
  "taken",
  "missed",
  "skipped",
]);

export const experimentStatusEnum = pgEnum("experiment_status_enum", [
  "planned",
  "baseline",
  "active",
  "followup",
  "completed",
  "abandoned",
]);

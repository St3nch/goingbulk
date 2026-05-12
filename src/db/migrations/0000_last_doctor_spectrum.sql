CREATE TYPE "public"."adherence_status_enum" AS ENUM('pending', 'taken', 'missed', 'skipped');--> statement-breakpoint
CREATE TYPE "public"."confidence_enum" AS ENUM('low', 'medium', 'high', 'experimental');--> statement-breakpoint
CREATE TYPE "public"."experiment_status_enum" AS ENUM('planned', 'baseline', 'active', 'followup', 'completed', 'abandoned');--> statement-breakpoint
CREATE TYPE "public"."import_row_status_enum" AS ENUM('pending', 'validated', 'normalized', 'skipped', 'error');--> statement-breakpoint
CREATE TYPE "public"."import_status_enum" AS ENUM('uploaded', 'previewed', 'approved', 'rejected', 'failed');--> statement-breakpoint
CREATE TYPE "public"."log_source_enum" AS ENUM('manual', 'cronometer_export', 'device_import', 'lab_report', 'estimated');--> statement-breakpoint
CREATE TYPE "public"."set_type_enum" AS ENUM('warmup', 'working', 'backoff', 'drop', 'failure', 'amrap');--> statement-breakpoint
CREATE TYPE "public"."user_role_enum" AS ENUM('owner', 'admin', 'editor', 'professional_viewer', 'public');--> statement-breakpoint
CREATE TYPE "public"."visibility_enum" AS ENUM('private', 'internal', 'professional', 'public');--> statement-breakpoint
CREATE TYPE "public"."workout_status_enum" AS ENUM('planned', 'in_progress', 'completed', 'cancelled');--> statement-breakpoint
CREATE TABLE "audit_log" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"table_name" text NOT NULL,
	"record_id" uuid NOT NULL,
	"action" text NOT NULL,
	"old_values" jsonb,
	"new_values" jsonb,
	"changed_by" uuid,
	"changed_at" timestamp with time zone DEFAULT now() NOT NULL,
	"ip_address" "inet",
	"user_agent" text
);
--> statement-breakpoint
CREATE TABLE "dataset_exports" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"dataset_id" uuid NOT NULL,
	"format" text NOT NULL,
	"file_url" text NOT NULL,
	"row_count" integer,
	"file_size_bytes" integer,
	"generated_by" uuid,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "datasets" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"source_summary" text,
	"methodology_summary" text,
	"limitations" text,
	"confidence_level" "confidence_enum" DEFAULT 'medium' NOT NULL,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"date_range_start" date NOT NULL,
	"date_range_end" date NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "datasets_slug_unique" UNIQUE("slug"),
	CONSTRAINT "datasets_date_range_check" CHECK ("datasets"."date_range_end" >= "datasets"."date_range_start")
);
--> statement-breakpoint
CREATE TABLE "exercises" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"primary_muscle_group" text,
	"secondary_muscle_groups" text[],
	"equipment" text,
	"movement_pattern" text,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "exercises_name_unique" UNIQUE("name"),
	CONSTRAINT "exercises_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "confounder_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"date" date NOT NULL,
	"confounder_type" text NOT NULL,
	"severity" text,
	"impact_areas" text[],
	"notes" text,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "confounder_logs_type_check" CHECK ("confounder_logs"."confounder_type" IN ('poor_sleep', 'high_stress', 'illness', 'injury', 'travel', 'missed_workout', 'missed_supplement', 'alcohol', 'new_program', 'calorie_change', 'medication_change')),
	CONSTRAINT "confounder_logs_severity_check" CHECK ("confounder_logs"."severity" IS NULL OR "confounder_logs"."severity" IN ('minor', 'moderate', 'major'))
);
--> statement-breakpoint
CREATE TABLE "experiments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"title" text NOT NULL,
	"slug" text NOT NULL,
	"experiment_type" text DEFAULT 'baseline' NOT NULL,
	"status" "experiment_status_enum" DEFAULT 'planned' NOT NULL,
	"question" text,
	"hypothesis" text,
	"protocol_summary" text,
	"baseline_start" date,
	"baseline_end" date,
	"intervention_start" date,
	"intervention_end" date,
	"followup_start" date,
	"followup_end" date,
	"primary_metrics" text[],
	"secondary_metrics" text[],
	"confidence_level" "confidence_enum" DEFAULT 'medium',
	"verdict" text,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "experiments_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "measurements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"measured_at" timestamp with time zone NOT NULL,
	"metric_key" text NOT NULL,
	"value" numeric(10, 3) NOT NULL,
	"unit" text NOT NULL,
	"source" "log_source_enum" DEFAULT 'manual' NOT NULL,
	"device" text,
	"method" text,
	"confidence_level" "confidence_enum" DEFAULT 'high' NOT NULL,
	"conditions" text,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "measurements_metric_key_check" CHECK ("measurements"."metric_key" IN ('bodyweight', 'waist', 'chest', 'hips', 'neck', 'bicep_left', 'bicep_right', 'thigh_left', 'thigh_right', 'body_fat_estimate', 'blood_pressure_systolic', 'blood_pressure_diastolic', 'resting_heart_rate'))
);
--> statement-breakpoint
CREATE TABLE "nutrition_import_batches" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"source" "log_source_enum" DEFAULT 'cronometer_export' NOT NULL,
	"file_name" text NOT NULL,
	"file_hash" text NOT NULL,
	"row_count" integer,
	"date_range_start" date,
	"date_range_end" date,
	"status" "import_status_enum" DEFAULT 'uploaded' NOT NULL,
	"approved_at" timestamp with time zone,
	"uploaded_by" uuid NOT NULL,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "nutrition_import_rows" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"batch_id" uuid NOT NULL,
	"row_number" integer NOT NULL,
	"row_hash" text NOT NULL,
	"raw_date" text,
	"raw_meal" text,
	"raw_food_name" text,
	"raw_amount" text,
	"raw_calories" text,
	"raw_protein" text,
	"raw_carbs" text,
	"raw_fat" text,
	"raw_fiber" text,
	"raw_sodium" text,
	"raw_sugar" text,
	"raw_payload" jsonb,
	"status" "import_row_status_enum" DEFAULT 'pending' NOT NULL,
	"error_message" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "nutrient_definitions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"nutrient_key" text NOT NULL,
	"display_name" text NOT NULL,
	"unit" text NOT NULL,
	"category" text NOT NULL,
	"sort_order" integer,
	"cronometer_column" text,
	"daily_target" numeric(10, 3),
	"daily_target_unit" text,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "nutrient_definitions_nutrient_key_unique" UNIQUE("nutrient_key")
);
--> statement-breakpoint
CREATE TABLE "nutrition_log_nutrients" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"nutrition_log_id" uuid NOT NULL,
	"nutrient_key" text NOT NULL,
	"value" numeric(12, 4) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "nutrition_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"date" date NOT NULL,
	"meal_name" text,
	"food_name_snapshot" text NOT NULL,
	"grams" numeric(8, 2),
	"calories" numeric(8, 2) NOT NULL,
	"protein_g" numeric(8, 2),
	"carbs_g" numeric(8, 2),
	"fat_g" numeric(8, 2),
	"fiber_g" numeric(8, 2),
	"sugar_g" numeric(8, 2),
	"sodium_mg" numeric(8, 2),
	"source" "log_source_enum" DEFAULT 'cronometer_export' NOT NULL,
	"source_batch_id" uuid,
	"source_row_id" uuid,
	"confidence_level" "confidence_enum" DEFAULT 'medium' NOT NULL,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplement_logs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"supplement_id" uuid NOT NULL,
	"date" date NOT NULL,
	"time_taken" text,
	"dose" text,
	"unit" text,
	"adherence_status" "adherence_status_enum" DEFAULT 'pending' NOT NULL,
	"confidence_level" "confidence_enum" DEFAULT 'high' NOT NULL,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"name" text NOT NULL,
	"category" text,
	"default_dose" text,
	"default_unit" text,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "supplements_slug_unique" UNIQUE("slug"),
	CONSTRAINT "supplements_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "user_profiles" (
	"id" uuid PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"display_name" text,
	"role" "user_role_enum" DEFAULT 'public' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_profiles_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "exercise_sets" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"workout_session_id" uuid NOT NULL,
	"exercise_id" uuid NOT NULL,
	"set_number" integer NOT NULL,
	"set_type" "set_type_enum" DEFAULT 'working' NOT NULL,
	"actual_reps" integer,
	"actual_load" numeric(8, 2),
	"load_unit" text,
	"rpe" numeric(3, 1),
	"rest_seconds" integer,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "exercise_sets_set_number_check" CHECK ("exercise_sets"."set_number" > 0),
	CONSTRAINT "exercise_sets_actual_reps_check" CHECK ("exercise_sets"."actual_reps" IS NULL OR "exercise_sets"."actual_reps" >= 0),
	CONSTRAINT "exercise_sets_actual_load_check" CHECK ("exercise_sets"."actual_load" IS NULL OR "exercise_sets"."actual_load" >= 0),
	CONSTRAINT "exercise_sets_rest_seconds_check" CHECK ("exercise_sets"."rest_seconds" IS NULL OR "exercise_sets"."rest_seconds" >= 0),
	CONSTRAINT "exercise_sets_rpe_check" CHECK ("exercise_sets"."rpe" IS NULL OR ("exercise_sets"."rpe" >= 1 AND "exercise_sets"."rpe" <= 10))
);
--> statement-breakpoint
CREATE TABLE "workout_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"date" date NOT NULL,
	"workout_name" text,
	"status" "workout_status_enum" DEFAULT 'planned' NOT NULL,
	"started_at" timestamp with time zone,
	"ended_at" timestamp with time zone,
	"duration_minutes" integer,
	"notes" text,
	"visibility" "visibility_enum" DEFAULT 'private' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "workout_sessions_time_check" CHECK ("workout_sessions"."ended_at" IS NULL OR "workout_sessions"."started_at" IS NULL OR "workout_sessions"."ended_at" >= "workout_sessions"."started_at"),
	CONSTRAINT "workout_sessions_duration_check" CHECK ("workout_sessions"."duration_minutes" IS NULL OR "workout_sessions"."duration_minutes" >= 0)
);
--> statement-breakpoint
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_changed_by_user_profiles_id_fk" FOREIGN KEY ("changed_by") REFERENCES "public"."user_profiles"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "dataset_exports" ADD CONSTRAINT "dataset_exports_dataset_id_datasets_id_fk" FOREIGN KEY ("dataset_id") REFERENCES "public"."datasets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "dataset_exports" ADD CONSTRAINT "dataset_exports_generated_by_user_profiles_id_fk" FOREIGN KEY ("generated_by") REFERENCES "public"."user_profiles"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "nutrition_import_batches" ADD CONSTRAINT "nutrition_import_batches_uploaded_by_user_profiles_id_fk" FOREIGN KEY ("uploaded_by") REFERENCES "public"."user_profiles"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "nutrition_import_rows" ADD CONSTRAINT "nutrition_import_rows_batch_id_nutrition_import_batches_id_fk" FOREIGN KEY ("batch_id") REFERENCES "public"."nutrition_import_batches"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "nutrition_log_nutrients" ADD CONSTRAINT "nutrition_log_nutrients_nutrition_log_id_nutrition_logs_id_fk" FOREIGN KEY ("nutrition_log_id") REFERENCES "public"."nutrition_logs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "nutrition_log_nutrients" ADD CONSTRAINT "nutrition_log_nutrients_nutrient_key_nutrient_definitions_nutrient_key_fk" FOREIGN KEY ("nutrient_key") REFERENCES "public"."nutrient_definitions"("nutrient_key") ON DELETE restrict ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "nutrition_logs" ADD CONSTRAINT "nutrition_logs_source_batch_id_nutrition_import_batches_id_fk" FOREIGN KEY ("source_batch_id") REFERENCES "public"."nutrition_import_batches"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "nutrition_logs" ADD CONSTRAINT "nutrition_logs_source_row_id_nutrition_import_rows_id_fk" FOREIGN KEY ("source_row_id") REFERENCES "public"."nutrition_import_rows"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplement_logs" ADD CONSTRAINT "supplement_logs_supplement_id_supplements_id_fk" FOREIGN KEY ("supplement_id") REFERENCES "public"."supplements"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "exercise_sets" ADD CONSTRAINT "exercise_sets_workout_session_id_workout_sessions_id_fk" FOREIGN KEY ("workout_session_id") REFERENCES "public"."workout_sessions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "exercise_sets" ADD CONSTRAINT "exercise_sets_exercise_id_exercises_id_fk" FOREIGN KEY ("exercise_id") REFERENCES "public"."exercises"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_audit_log_table_record" ON "audit_log" USING btree ("table_name","record_id");--> statement-breakpoint
CREATE INDEX "idx_audit_log_changed_at" ON "audit_log" USING btree ("changed_at");--> statement-breakpoint
CREATE INDEX "idx_dataset_exports_dataset" ON "dataset_exports" USING btree ("dataset_id");--> statement-breakpoint
CREATE INDEX "idx_datasets_visibility" ON "datasets" USING btree ("visibility");--> statement-breakpoint
CREATE INDEX "idx_confounder_logs_date" ON "confounder_logs" USING btree ("date");--> statement-breakpoint
CREATE INDEX "idx_experiments_status" ON "experiments" USING btree ("status");--> statement-breakpoint
CREATE INDEX "idx_experiments_visibility" ON "experiments" USING btree ("visibility");--> statement-breakpoint
CREATE INDEX "idx_measurements_metric_date" ON "measurements" USING btree ("metric_key","measured_at");--> statement-breakpoint
CREATE INDEX "idx_measurements_visibility" ON "measurements" USING btree ("visibility");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_nutrition_import_batches_file_hash" ON "nutrition_import_batches" USING btree ("file_hash");--> statement-breakpoint
CREATE INDEX "idx_nutrition_import_batches_status" ON "nutrition_import_batches" USING btree ("status");--> statement-breakpoint
CREATE INDEX "idx_nutrition_import_batches_dates" ON "nutrition_import_batches" USING btree ("date_range_start","date_range_end");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_nutrition_import_rows_batch_row_number" ON "nutrition_import_rows" USING btree ("batch_id","row_number");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_nutrition_import_rows_batch_row_hash" ON "nutrition_import_rows" USING btree ("batch_id","row_hash");--> statement-breakpoint
CREATE INDEX "idx_nutrition_import_rows_batch" ON "nutrition_import_rows" USING btree ("batch_id");--> statement-breakpoint
CREATE INDEX "idx_nutrition_import_rows_hash" ON "nutrition_import_rows" USING btree ("row_hash");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_nutrient_definitions_key" ON "nutrient_definitions" USING btree ("nutrient_key");--> statement-breakpoint
CREATE INDEX "idx_nutrient_definitions_cronometer_column" ON "nutrient_definitions" USING btree ("cronometer_column");--> statement-breakpoint
CREATE UNIQUE INDEX "idx_nutrition_log_nutrients_log_key" ON "nutrition_log_nutrients" USING btree ("nutrition_log_id","nutrient_key");--> statement-breakpoint
CREATE INDEX "idx_nutrition_log_nutrients_log_id" ON "nutrition_log_nutrients" USING btree ("nutrition_log_id");--> statement-breakpoint
CREATE INDEX "idx_nutrition_log_nutrients_key" ON "nutrition_log_nutrients" USING btree ("nutrient_key");--> statement-breakpoint
CREATE INDEX "idx_nutrition_log_nutrients_key_value" ON "nutrition_log_nutrients" USING btree ("nutrient_key","value");--> statement-breakpoint
CREATE INDEX "idx_nutrition_logs_date" ON "nutrition_logs" USING btree ("date");--> statement-breakpoint
CREATE INDEX "idx_nutrition_logs_visibility" ON "nutrition_logs" USING btree ("visibility");--> statement-breakpoint
CREATE INDEX "idx_nutrition_logs_source_batch" ON "nutrition_logs" USING btree ("source_batch_id");--> statement-breakpoint
CREATE INDEX "idx_nutrition_logs_source_row" ON "nutrition_logs" USING btree ("source_row_id");--> statement-breakpoint
CREATE INDEX "idx_supplement_logs_date" ON "supplement_logs" USING btree ("date");--> statement-breakpoint
CREATE INDEX "idx_supplement_logs_supplement_date" ON "supplement_logs" USING btree ("supplement_id","date");--> statement-breakpoint
CREATE INDEX "idx_supplements_slug" ON "supplements" USING btree ("slug");--> statement-breakpoint
CREATE INDEX "idx_exercise_sets_session_set_number" ON "exercise_sets" USING btree ("workout_session_id","set_number");--> statement-breakpoint
CREATE INDEX "idx_exercise_sets_exercise" ON "exercise_sets" USING btree ("exercise_id");--> statement-breakpoint
CREATE INDEX "idx_workout_sessions_date" ON "workout_sessions" USING btree ("date");--> statement-breakpoint
CREATE INDEX "idx_workout_sessions_visibility" ON "workout_sessions" USING btree ("visibility");
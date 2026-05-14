CREATE TABLE "experiment_evidence_links" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"experiment_id" uuid NOT NULL,
	"source_type" text NOT NULL,
	"evidence_type" text,
	"title" text NOT NULL,
	"url" text,
	"doi" text,
	"pmid" text,
	"citation_text" text,
	"summary" text,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "experiment_evidence_links_source_type_check" CHECK ("experiment_evidence_links"."source_type" IN ('pubmed', 'doi', 'website', 'book', 'video', 'manual_note', 'product_label', 'coach_advice', 'other')),
	CONSTRAINT "experiment_evidence_links_evidence_type_check" CHECK ("experiment_evidence_links"."evidence_type" IS NULL OR "experiment_evidence_links"."evidence_type" IN ('meta_analysis', 'systematic_review', 'randomized_controlled_trial', 'controlled_trial', 'observational_human', 'animal_study', 'mechanistic', 'expert_opinion', 'marketing_claim', 'personal_observation', 'unknown'))
);
--> statement-breakpoint
CREATE TABLE "experiment_interventions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"experiment_id" uuid NOT NULL,
	"intervention_type" text NOT NULL,
	"supplement_id" uuid,
	"title" text NOT NULL,
	"description" text,
	"dose" text,
	"unit" text,
	"timing" text,
	"frequency" text,
	"start_date" date,
	"end_date" date,
	"protocol_notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "experiment_interventions_type_check" CHECK ("experiment_interventions"."intervention_type" IN ('supplement', 'nutrition', 'training', 'sleep', 'recovery', 'behavior', 'device', 'other'))
);
--> statement-breakpoint
CREATE TABLE "experiment_outcomes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"experiment_id" uuid NOT NULL,
	"outcome_type" text DEFAULT 'primary' NOT NULL,
	"metric_key" text NOT NULL,
	"expected_direction" text,
	"observed_direction" text,
	"baseline_value" text,
	"target_value" text,
	"observed_value" text,
	"unit" text,
	"confidence_level" "confidence_enum" DEFAULT 'medium',
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "experiment_outcomes_type_check" CHECK ("experiment_outcomes"."outcome_type" IN ('primary', 'secondary', 'safety', 'exploratory')),
	CONSTRAINT "experiment_outcomes_expected_direction_check" CHECK ("experiment_outcomes"."expected_direction" IS NULL OR "experiment_outcomes"."expected_direction" IN ('increase', 'decrease', 'no_change', 'stabilize', 'unknown')),
	CONSTRAINT "experiment_outcomes_observed_direction_check" CHECK ("experiment_outcomes"."observed_direction" IS NULL OR "experiment_outcomes"."observed_direction" IN ('increase', 'decrease', 'no_change', 'stabilize', 'unknown'))
);
--> statement-breakpoint
ALTER TABLE "experiment_evidence_links" ADD CONSTRAINT "experiment_evidence_links_experiment_id_experiments_id_fk" FOREIGN KEY ("experiment_id") REFERENCES "public"."experiments"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "experiment_interventions" ADD CONSTRAINT "experiment_interventions_experiment_id_experiments_id_fk" FOREIGN KEY ("experiment_id") REFERENCES "public"."experiments"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "experiment_interventions" ADD CONSTRAINT "experiment_interventions_supplement_id_supplements_id_fk" FOREIGN KEY ("supplement_id") REFERENCES "public"."supplements"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "experiment_outcomes" ADD CONSTRAINT "experiment_outcomes_experiment_id_experiments_id_fk" FOREIGN KEY ("experiment_id") REFERENCES "public"."experiments"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_experiment_evidence_links_experiment_id" ON "experiment_evidence_links" USING btree ("experiment_id");--> statement-breakpoint
CREATE INDEX "idx_experiment_evidence_links_source_type" ON "experiment_evidence_links" USING btree ("source_type");--> statement-breakpoint
CREATE INDEX "idx_experiment_interventions_experiment_id" ON "experiment_interventions" USING btree ("experiment_id");--> statement-breakpoint
CREATE INDEX "idx_experiment_interventions_type" ON "experiment_interventions" USING btree ("intervention_type");--> statement-breakpoint
CREATE INDEX "idx_experiment_outcomes_experiment_id" ON "experiment_outcomes" USING btree ("experiment_id");--> statement-breakpoint
CREATE INDEX "idx_experiment_outcomes_metric_key" ON "experiment_outcomes" USING btree ("metric_key");
import { inet, index, jsonb, pgTable, text, timestamp, uuid } from "drizzle-orm/pg-core";

import { userProfiles } from "./user-profiles";

export const auditLog = pgTable(
  "audit_log",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tableName: text("table_name").notNull(),
    recordId: uuid("record_id").notNull(),
    action: text("action").notNull(),
    oldValues: jsonb("old_values").$type<Record<string, unknown>>(),
    newValues: jsonb("new_values").$type<Record<string, unknown>>(),
    changedBy: uuid("changed_by").references(() => userProfiles.id),
    changedAt: timestamp("changed_at", { withTimezone: true }).notNull().defaultNow(),
    ipAddress: inet("ip_address"),
    userAgent: text("user_agent"),
  },
  (table) => [
    index("idx_audit_log_table_record").on(table.tableName, table.recordId),
    index("idx_audit_log_changed_at").on(table.changedAt),
  ],
);

export type AuditLog = typeof auditLog.$inferSelect;
export type NewAuditLog = typeof auditLog.$inferInsert;

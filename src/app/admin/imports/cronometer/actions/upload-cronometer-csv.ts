"use server";

import { createHash } from "crypto";

import { getDb } from "@/db/client";
import { nutritionImportBatches, nutritionImportRows } from "@/db/schema/nutrition-imports";
import { getCurrentUser } from "@/lib/auth/get-current-user";
import { parseCronometerCsv, type CronometerPreviewRow } from "@/lib/cronometer-preview";

const MAX_FILE_BYTES = 10 * 1024 * 1024; // 10 MB

export type UploadResult =
  | {
      ok: true;
      batchId: string;
      fileName: string;
      totalRows: number;
      previewRows: CronometerPreviewRow[];
      detectedColumns: string[];
    }
  | { ok: false; error: string };

function computeHash(input: Buffer | string): string {
  return createHash("sha256").update(input).digest("hex");
}

/**
 * Normalize a single hash-key field:
 * - trim leading/trailing whitespace
 * - collapse internal whitespace runs to a single space
 * - lowercase
 * - strip trailing zeros from decimals ("1.500" → "1.5", "2.0" → "2")
 *
 * Applied consistently so hashes are stable across minor export formatting
 * differences (extra spaces, mixed case, decimal padding).
 */
function normalizeHashField(raw: string): string {
  const trimmed = raw.trim().replace(/\s+/g, " ").toLowerCase();
  // Only touch strings that look like a bare decimal number.
  return trimmed.replace(/^(\d+)\.?(\d*?)0+$/, (_, int, frac) => (frac ? `${int}.${frac}` : int));
}

function computeRowHash(record: Record<string, string>): string {
  const fields = [
    record["Date"] ?? record["Day"] ?? "",
    record["Meal"] ?? record["Group"] ?? "",
    record["Food Name"] ?? record["Food"] ?? "",
    record["Amount"] ?? record["Serving"] ?? "",
    record["Energy (kcal)"] ?? record["Calories"] ?? "",
  ].map(normalizeHashField);
  return computeHash(fields.join("|"));
}

function parseDateRange(rawDates: string[]): { start: string | null; end: string | null } {
  const valid = rawDates
    .map((d) => d.trim())
    .filter((d) => /^\d{4}-\d{2}-\d{2}$/.test(d))
    .sort();
  if (valid.length === 0) return { start: null, end: null };
  return { start: valid[0]!, end: valid[valid.length - 1]! };
}

export async function uploadCronometerCsv(
  _prevState: UploadResult | null,
  formData: FormData,
): Promise<UploadResult> {
  // 1. Require authenticated user — ownership comes from session only.
  const user = await getCurrentUser();

  // 2. Extract and validate the uploaded file.
  const file = formData.get("file");
  if (!(file instanceof File)) {
    return { ok: false, error: "No file provided." };
  }
  if (file.size === 0) {
    return { ok: false, error: "Uploaded file is empty." };
  }
  if (file.size > MAX_FILE_BYTES) {
    return {
      ok: false,
      error: `File exceeds 10 MB limit (got ${(file.size / 1024 / 1024).toFixed(1)} MB).`,
    };
  }

  // 3. Read raw bytes and compute file hash.
  const rawBytes = Buffer.from(await file.arrayBuffer());
  const fileHash = computeHash(rawBytes);

  // 4. Parse CSV.
  let csvText: string;
  try {
    csvText = rawBytes.toString("utf-8");
  } catch {
    return { ok: false, error: "Could not decode file as UTF-8 text." };
  }

  let parsed;
  try {
    parsed = parseCronometerCsv(csvText);
  } catch {
    return {
      ok: false,
      error: "Failed to parse CSV. Ensure the file is a valid Cronometer export.",
    };
  }

  if (parsed.totalRows === 0) {
    return { ok: false, error: "CSV contains no data rows." };
  }

  // 5. Compute date range from raw date values.
  const rawDates = parsed.records.map((r) => r["Date"] ?? r["Day"] ?? "");
  const { start: dateRangeStart, end: dateRangeEnd } = parseDateRange(rawDates);

  const db = getDb();

  // 6. Insert import batch and rows atomically.
  // Either the entire raw import persists, or nothing does.
  let batchId: string;
  try {
    batchId = await db.transaction(async (tx) => {
      const [batch] = await tx
        .insert(nutritionImportBatches)
        .values({
          source: "cronometer_export",
          fileName: file.name,
          fileHash,
          rowCount: parsed.totalRows,
          dateRangeStart: dateRangeStart ?? undefined,
          dateRangeEnd: dateRangeEnd ?? undefined,
          status: "uploaded",
          uploadedBy: user.id,
        })
        .returning({ id: nutritionImportBatches.id });

      if (!batch) {
        throw new Error("Failed to create import batch record.");
      }

      const CHUNK = 200;
      for (let i = 0; i < parsed.records.length; i += CHUNK) {
        const chunk = parsed.records.slice(i, i + CHUNK);
        await tx.insert(nutritionImportRows).values(
          chunk.map((record, offset) => ({
            batchId: batch.id,
            rowNumber: i + offset + 1,
            rowHash: computeRowHash(record),
            rawDate: record["Date"] ?? record["Day"] ?? null,
            rawMeal: record["Meal"] ?? record["Group"] ?? null,
            rawFoodName: record["Food Name"] ?? record["Food"] ?? null,
            rawAmount: record["Amount"] ?? record["Serving"] ?? null,
            rawCalories: record["Energy (kcal)"] ?? record["Calories"] ?? null,
            rawProtein: record["Protein (g)"] ?? record["Protein"] ?? null,
            rawCarbs: record["Carbs (g)"] ?? record["Carbohydrates (g)"] ?? record["Carbs"] ?? null,
            rawFat: record["Fat (g)"] ?? record["Fat"] ?? null,
            rawFiber: record["Fiber (g)"] ?? record["Fiber"] ?? null,
            rawSodium: record["Sodium (mg)"] ?? record["Sodium"] ?? null,
            rawSugar: record["Sugar (g)"] ?? record["Sugar"] ?? null,
            rawPayload: record as Record<string, unknown>,
            status: "pending" as const,
          })),
        );
      }

      return batch.id;
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("idx_nutrition_import_batches_file_hash") || msg.includes("unique")) {
      return { ok: false, error: "This file has already been uploaded (duplicate file hash)." };
    }
    return { ok: false, error: "Database error persisting import batch." };
  }

  // 8. Return the persisted preview — first 20 rows for display.
  return {
    ok: true,
    batchId,
    fileName: file.name,
    totalRows: parsed.totalRows,
    previewRows: parsed.previewRows,
    detectedColumns: parsed.detectedColumns,
  };
}

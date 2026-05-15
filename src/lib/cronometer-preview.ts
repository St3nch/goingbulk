import { parse } from "csv-parse/sync";

export type CronometerPreviewRow = {
  date: string;
  meal: string;
  food: string;
  amount: string;
  calories: string;
  protein: string;
  carbs: string;
  fat: string;
};

export type CronometerPreviewResult = {
  totalRows: number;
  previewRows: CronometerPreviewRow[];
  detectedColumns: string[];
};

function getValue(record: Record<string, string>, keys: string[]): string {
  for (const key of keys) {
    if (record[key] !== undefined) {
      return String(record[key]).trim();
    }
  }

  return "";
}

export function parseCronometerCsv(csvText: string): CronometerPreviewResult {
  const records = parse(csvText, {
    columns: true,
    skip_empty_lines: true,
    bom: true,
  }) as Record<string, string>[];

  const previewRows: CronometerPreviewRow[] = records.slice(0, 20).map((record) => ({
    date: getValue(record, ["Date", "Day"]),
    meal: getValue(record, ["Meal", "Group"]),
    food: getValue(record, ["Food Name", "Food"]),
    amount: getValue(record, ["Amount", "Serving"]),
    calories: getValue(record, ["Energy (kcal)", "Calories"]),
    protein: getValue(record, ["Protein (g)", "Protein"]),
    carbs: getValue(record, ["Carbs (g)", "Carbohydrates (g)", "Carbs"]),
    fat: getValue(record, ["Fat (g)", "Fat"]),
  }));

  return {
    totalRows: records.length,
    previewRows,
    detectedColumns: records.length > 0 ? Object.keys(records[0]) : [],
  };
}

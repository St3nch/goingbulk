"use client";

import { useState } from "react";

import { type CronometerPreviewResult, parseCronometerCsv } from "@/lib/cronometer-preview";

export default function CronometerImportPage() {
  const [fileName, setFileName] = useState<string | null>(null);
  const [preview, setPreview] = useState<CronometerPreviewResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleFileChange(event: React.ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];

    if (!file) {
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const text = await file.text();
      const parsed = parseCronometerCsv(text);

      setFileName(file.name);
      setPreview(parsed);
    } catch (err) {
      console.error(err);
      setError("Failed to parse Cronometer CSV preview.");
      setPreview(null);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="mx-auto flex max-w-7xl flex-col gap-6 p-8">
      <div>
        <h1 className="text-3xl font-bold">Cronometer Import Preview</h1>
        <p className="mt-2 text-sm text-zinc-600">
          Upload a Cronometer CSV export to preview parsed nutrition rows before
          normalization/import.
        </p>
      </div>

      <section className="rounded-lg border border-zinc-200 p-6">
        <label className="flex flex-col gap-3">
          <span className="text-sm font-medium">Cronometer CSV Export</span>
          <input
            accept=".csv,text/csv"
            className="block w-full rounded border border-zinc-300 p-2 text-sm"
            onChange={handleFileChange}
            type="file"
          />
        </label>
      </section>

      {loading ? (
        <div className="rounded-lg border border-zinc-200 p-4 text-sm">Parsing CSV preview...</div>
      ) : null}

      {error ? (
        <div className="rounded-lg border border-red-300 bg-red-50 p-4 text-sm text-red-700">
          {error}
        </div>
      ) : null}

      {preview ? (
        <section className="flex flex-col gap-4 rounded-lg border border-zinc-200 p-6">
          <div className="flex flex-col gap-1">
            <h2 className="text-xl font-semibold">Preview Summary</h2>
            <p className="text-sm text-zinc-600">
              File: {fileName} · Parsed rows: {preview.totalRows}
            </p>
          </div>

          <div>
            <h3 className="mb-2 text-sm font-semibold">Detected Columns</h3>
            <div className="flex flex-wrap gap-2">
              {preview.detectedColumns.map((column) => (
                <span className="rounded bg-zinc-100 px-2 py-1 text-xs text-zinc-700" key={column}>
                  {column}
                </span>
              ))}
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full border-collapse text-sm">
              <thead>
                <tr className="border-b border-zinc-200 text-left">
                  <th className="px-3 py-2">Date</th>
                  <th className="px-3 py-2">Meal</th>
                  <th className="px-3 py-2">Food</th>
                  <th className="px-3 py-2">Amount</th>
                  <th className="px-3 py-2">Calories</th>
                  <th className="px-3 py-2">Protein</th>
                  <th className="px-3 py-2">Carbs</th>
                  <th className="px-3 py-2">Fat</th>
                </tr>
              </thead>
              <tbody>
                {preview.previewRows.map((row, index) => (
                  <tr className="border-b border-zinc-100" key={`${row.food}-${index}`}>
                    <td className="px-3 py-2">{row.date}</td>
                    <td className="px-3 py-2">{row.meal}</td>
                    <td className="px-3 py-2">{row.food}</td>
                    <td className="px-3 py-2">{row.amount}</td>
                    <td className="px-3 py-2">{row.calories}</td>
                    <td className="px-3 py-2">{row.protein}</td>
                    <td className="px-3 py-2">{row.carbs}</td>
                    <td className="px-3 py-2">{row.fat}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="rounded border border-amber-300 bg-amber-50 p-4 text-sm text-amber-900">
            MVP status: preview-only flow. No database writes, normalization, or approval workflow
            yet.
          </div>
        </section>
      ) : null}
    </main>
  );
}

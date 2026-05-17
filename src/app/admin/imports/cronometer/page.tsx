"use client";

import { useActionState } from "react";

import { uploadCronometerCsv, type UploadResult } from "./actions/upload-cronometer-csv";

export default function CronometerImportPage() {
  const [result, formAction, isPending] = useActionState<UploadResult | null, FormData>(
    uploadCronometerCsv,
    null,
  );

  return (
    <main className="mx-auto flex max-w-7xl flex-col gap-6 p-8">
      <div>
        <h1 className="text-3xl font-bold">Cronometer Import</h1>
        <p className="mt-2 text-sm text-zinc-600">
          Upload a Cronometer CSV export. Rows are persisted as a raw import batch under your
          authenticated ownership. Normalization and approval come later.
        </p>
      </div>

      <section className="rounded-lg border border-zinc-200 p-6">
        <form action={formAction} className="flex flex-col gap-4">
          <label className="flex flex-col gap-2">
            <span className="text-sm font-medium">Cronometer CSV Export</span>
            <input
              accept=".csv,text/csv"
              className="block w-full rounded border border-zinc-300 p-2 text-sm"
              name="file"
              required
              type="file"
            />
          </label>

          <button
            className="self-start rounded-md border border-zinc-300 bg-white px-4 py-2 text-sm font-medium hover:bg-zinc-50 disabled:opacity-50"
            disabled={isPending}
            type="submit"
          >
            {isPending ? "Uploading\u2026" : "Upload and Persist"}
          </button>
        </form>
      </section>

      {isPending ? (
        <div className="rounded-lg border border-zinc-200 p-4 text-sm text-zinc-600">
          Parsing and persisting rows\u2026
        </div>
      ) : null}

      {result && !result.ok ? (
        <div className="rounded-lg border border-red-300 bg-red-50 p-4 text-sm text-red-700">
          {result.error}
        </div>
      ) : null}

      {result?.ok ? (
        <section className="flex flex-col gap-4 rounded-lg border border-zinc-200 p-6">
          <div className="flex flex-col gap-1">
            <h2 className="text-xl font-semibold">Persisted Import Batch</h2>
            <p className="text-sm text-zinc-600">
              File: {result.fileName} &middot; Rows persisted: {result.totalRows} &middot; Batch ID:{" "}
              <span className="font-mono text-xs">{result.batchId}</span>
            </p>
          </div>

          <div>
            <h3 className="mb-2 text-sm font-semibold">Detected Columns</h3>
            <div className="flex flex-wrap gap-2">
              {result.detectedColumns.map((column) => (
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
                {result.previewRows.map((row, index) => (
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
            {result.totalRows > 20 ? (
              <p className="mt-2 text-xs text-zinc-500">
                Showing first 20 of {result.totalRows} persisted rows.
              </p>
            ) : null}
          </div>

          <div className="rounded border border-amber-300 bg-amber-50 p-4 text-sm text-amber-900">
            MVP status: raw rows persisted under authenticated ownership. Normalization and approval
            workflow are not yet implemented.
          </div>
        </section>
      ) : null}
    </main>
  );
}

import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

import { requireServerEnv } from "@/env";
import * as schema from "./schema";

export type DbClient = ReturnType<typeof createDbClient>;

let cachedDb: DbClient | null = null;

function createDbClient() {
  const queryClient = postgres(requireServerEnv("DATABASE_URL"), {
    max: 1,
    prepare: false,
  });

  return drizzle(queryClient, { schema });
}

export function getDb() {
  cachedDb ??= createDbClient();
  return cachedDb;
}

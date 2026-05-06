import { z } from "zod";

const serverEnvSchema = z.object({
  DATABASE_URL: z.string().min(1).optional(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1).optional(),
});

const publicEnvSchema = z.object({
  NEXT_PUBLIC_SITE_URL: z.string().url().default("http://localhost:3000"),
  NEXT_PUBLIC_SUPABASE_URL: z.string().url().optional(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1).optional(),
});

export const serverEnv = serverEnvSchema.parse({
  DATABASE_URL: process.env.DATABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
});

export const publicEnv = publicEnvSchema.parse({
  NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
});

export function requireServerEnv<Key extends keyof typeof serverEnv>(
  key: Key,
): NonNullable<(typeof serverEnv)[Key]> {
  const value = serverEnv[key];

  if (!value) {
    throw new Error(`${key} is required for this server-side operation.`);
  }

  return value;
}

export function requirePublicEnv<Key extends keyof typeof publicEnv>(
  key: Key,
): NonNullable<(typeof publicEnv)[Key]> {
  const value = publicEnv[key];

  if (!value) {
    throw new Error(`${key} is required for this Supabase operation.`);
  }

  return value;
}

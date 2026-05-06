import "server-only";

import { createClient } from "@supabase/supabase-js";

import { requirePublicEnv, requireServerEnv } from "@/env";

export function createAdminSupabaseClient() {
  return createClient(
    requirePublicEnv("NEXT_PUBLIC_SUPABASE_URL"),
    requireServerEnv("SUPABASE_SERVICE_ROLE_KEY"),
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  );
}

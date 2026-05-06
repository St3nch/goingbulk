import { createClient } from "@supabase/supabase-js";

import { requirePublicEnv } from "@/env";

export function createBrowserSupabaseClient() {
  return createClient(
    requirePublicEnv("NEXT_PUBLIC_SUPABASE_URL"),
    requirePublicEnv("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
  );
}

import { redirect } from "next/navigation";

import { publicEnv } from "@/env";
import { createClient } from "@/lib/supabase/server";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ redirectTo?: string }>;
}) {
  const params = await searchParams;
  const redirectTo = params.redirectTo ?? "/admin";

  async function signIn() {
    "use server";

    const supabase = await createClient();

    const origin = publicEnv.NEXT_PUBLIC_SITE_URL;

    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: "github",
      options: {
        redirectTo: `${origin}/auth/callback?next=${encodeURIComponent(redirectTo)}`,
      },
    });

    if (error) {
      throw error;
    }

    if (data.url) {
      redirect(data.url);
    }
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-md flex-col items-center justify-center gap-6 p-6 text-center">
      <div className="space-y-2">
        <h1 className="text-3xl font-semibold">GoingBulk Admin Login</h1>
        <p className="text-sm text-muted-foreground">
          Authenticated ownership is required for governed admin workflows.
        </p>
      </div>

      <form action={signIn}>
        <button type="submit" className="rounded-md border px-4 py-2 text-sm font-medium">
          Continue with GitHub
        </button>
      </form>
    </main>
  );
}

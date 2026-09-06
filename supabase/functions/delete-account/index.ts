// G-71 — Account deletion.
// The client can't call the admin API, so deletion runs here with the service
// role. The caller is identified from their own JWT (they can only delete
// themselves). Deleting the auth user cascades to profiles and everything
// under it; gifts GIVEN by the user are anonymized (giver_id → null) via the
// FK, preserving recipients' history.
//
// Future: when avatar/media storage (V2) exists, enumerate and delete the
// user's Storage/R2 objects here before deleting the auth user (no FK cascade
// reaches Storage).

import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "missing auth" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const url = Deno.env.get("SUPABASE_URL")!;

  // Identify the caller from their own token.
  const asUser = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error: authError } = await asUser.auth.getUser();
  if (authError || user == null) {
    return new Response(JSON.stringify({ error: "unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Delete with the service role (cascades handle related rows).
  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
  if (deleteError) {
    return new Response(JSON.stringify({ error: deleteError.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ deleted: true }), {
    headers: { "Content-Type": "application/json" },
  });
});

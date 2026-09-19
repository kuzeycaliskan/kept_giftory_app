// G-71 — Account deletion.
// The client can't call the admin API, so deletion runs here with the service
// role. The caller is identified from their own JWT (they can only delete
// themselves). Deleting the auth user cascades to profiles and everything
// under it; gifts GIVEN by the user are anonymized (giver_id → null) via the
// FK, preserving recipients' history.
//
// Storage has no FK cascade: the user's objects (avatars, ephemeral posts —
// both laid out as '<uid>/<file>') are removed explicitly BEFORE the auth
// user, and a storage failure aborts the deletion so nothing personal is
// left behind unnoticed (the client simply retries).

import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";

/** Buckets whose objects live under '<uid>/...'. Keep in sync with MediaStore users. */
const USER_MEDIA_BUCKETS = ["avatars", "posts", "gift-media"] as const;

/** Removes every object in `<uid>/` of a bucket. Storage `list` caps at
 * one page, so loop until the folder reads empty — each pass shrinks it, no
 * offset bookkeeping. Returns an error message or null. */
async function removeUserFolder(
  admin: SupabaseClient,
  bucket: string,
  uid: string,
): Promise<string | null> {
  const PAGE = 1000;
  for (let pass = 0; pass < 100; pass++) {
    const { data: files, error: listError } = await admin.storage
      .from(bucket)
      .list(uid, { limit: PAGE });
    if (listError) return `list ${bucket}: ${listError.message}`;
    if (!files || files.length === 0) return null;
    const { error: removeError } = await admin.storage
      .from(bucket)
      .remove(files.map((f) => `${uid}/${f.name}`));
    if (removeError) return `remove ${bucket}: ${removeError.message}`;
    if (files.length < PAGE) return null;
  }
  return `remove ${bucket}: folder did not drain`;
}

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

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  for (const bucket of USER_MEDIA_BUCKETS) {
    const storageError = await removeUserFolder(admin, bucket, user.id);
    if (storageError) {
      return new Response(JSON.stringify({ error: storageError }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }
  }

  // Delete with the service role (cascades handle related rows).
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

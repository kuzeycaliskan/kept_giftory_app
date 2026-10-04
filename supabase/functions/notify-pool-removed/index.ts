// Notices to a pool's people, by kind: 'removed' (the wishlist owner took
// the item away), 'released' (the organizer closed the pool), 'logged'
// (the organizer logged the group gift). Called from DB triggers/RPCs
// through pg_net with { kind, user_ids, item_title, actor }.
// Auth: X-Cron-Secret (CRON_SECRET). Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import {
  poolLoggedPush,
  poolReleasedPush,
  poolRemovedPush,
} from "../_shared/messages.ts";

interface Target {
  user_id: string;
  token: string;
  platform: string | null;
  enabled: boolean;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const body = await req.json().catch(() => ({}));
  const ids = Array.isArray(body?.user_ids)
    ? (body.user_ids as unknown[]).filter((u) => typeof u === "string")
    : [];
  const title = typeof body?.item_title === "string" ? body.item_title : null;
  const actor = typeof body?.actor === "string" ? body.actor : null;
  const kind = typeof body?.kind === "string" ? body.kind : "removed";
  if (ids.length === 0) return Response.json({ sent: 0 });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("push_targets_for_users", {
    p_ids: ids,
  });
  if (error) return new Response(error.message, { status: 500 });
  const targets = ((data ?? []) as Target[]).filter((t) => t.enabled);
  if (targets.length === 0) return Response.json({ sent: 0 });

  const { accessToken, projectId } = await fcmSender();
  const copy = kind === "logged"
    ? poolLoggedPush(actor, title)
    : kind === "released"
    ? poolReleasedPush(actor, title)
    : poolRemovedPush(title);
  let sent = 0;
  for (const t of targets) {
    const result = await sendPush(accessToken, projectId, {
      token: t.token,
      title: copy.title,
      body: copy.body,
      route: "/gifts",
    });
    if (result === "sent") sent++;
    if (result === "stale") await deleteStaleToken(supabase, t.token);
  }
  return Response.json({ sent });
});

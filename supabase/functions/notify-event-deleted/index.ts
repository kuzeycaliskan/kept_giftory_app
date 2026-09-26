// The organizer deleted an open event: tell the joined members, and say
// so when under-funded group-gift records went with it. Called by the
// gift_events_delete_cleanup trigger (pg_net) with
// { event_id, honoree, member_ids, removed_items } — the members' rows are
// already gone, hence the ids in the payload.
// Auth: X-Cron-Secret (CRON_SECRET). Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { eventDeletedPush } from "../_shared/messages.ts";

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
  const memberIds = Array.isArray(body?.member_ids)
    ? (body.member_ids as unknown[]).filter((m) => typeof m === "string")
    : [];
  const honoree = typeof body?.honoree === "string" ? body.honoree : null;
  const removed = Array.isArray(body?.removed_items)
    ? body.removed_items.length
    : 0;
  if (memberIds.length === 0) return Response.json({ sent: 0 });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("push_targets_for_users", {
    p_ids: memberIds,
  });
  if (error) return new Response(error.message, { status: 500 });
  const targets = ((data ?? []) as Target[]).filter((t) => t.enabled);
  if (targets.length === 0) return Response.json({ sent: 0 });

  const { accessToken, projectId } = await fcmSender();
  const copy = eventDeletedPush(honoree, removed);
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

// G-306/G-307 — the reveal tick. Hourly via pg_cron → pg_net, and pinged
// by reveal_gift_event() right after an organizer's early reveal.
// event_reveal_targets() flips due events, opens their linked surprises and
// returns every revealed-but-unannounced event with the honoree's devices;
// each is marked announced whether or not a push went out (no devices /
// opted out ≠ retry forever).
// Auth: X-Cron-Secret (CRON_SECRET). `?dry=1` lists without sending.
// Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { eventRevealPush } from "../_shared/messages.ts";

interface Target {
  event_id: string;
  honoree_id: string;
  token: string | null;
  platform: string | null;
  member_count: number;
  enabled: boolean;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const dry = new URL(req.url).searchParams.get("dry") === "1";
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("event_reveal_targets");
  if (error) return new Response(error.message, { status: 500 });
  const targets = (data ?? []) as Target[];
  const eventIds = [...new Set(targets.map((t) => t.event_id))];
  if (dry) return Response.json({ dry: true, due: eventIds.length, targets });
  if (eventIds.length === 0) return Response.json({ sent: 0, due: 0 });

  let sent = 0;
  const sendable = targets.filter((t) => t.enabled && t.token);
  if (sendable.length > 0) {
    const { accessToken, projectId } = await fcmSender();
    for (const t of sendable) {
      const copy = eventRevealPush(t.member_count);
      const result = await sendPush(accessToken, projectId, {
        token: t.token!,
        title: copy.title,
        body: copy.body,
        route: `/events/${t.event_id}`,
      });
      if (result === "sent") sent++;
      if (result === "stale") await deleteStaleToken(supabase, t.token!);
    }
  }

  const { error: markError } = await supabase.rpc(
    "mark_event_reveal_notified",
    { p_ids: eventIds },
  );
  if (markError) return new Response(markError.message, { status: 500 });

  return Response.json({ sent, due: eventIds.length });
});

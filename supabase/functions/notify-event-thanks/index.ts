// G-307 — the honoree's thank-you, pushed to every joined member. Called
// by the gift_events_thanks_notify trigger (pg_net) with { event_id }.
// Targets (opt-out and blocks applied) come from event_thanks_targets().
// Auth: X-Cron-Secret (CRON_SECRET). Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { eventThanksPush } from "../_shared/messages.ts";

interface Target {
  token: string;
  platform: string | null;
  member_id: string;
  honoree_label: string;
  note: string;
  enabled: boolean;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const body = await req.json().catch(() => ({}));
  const eventId = body?.event_id;
  if (typeof eventId !== "string") {
    return new Response("bad_request", { status: 400 });
  }
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("event_thanks_targets", {
    p_event: eventId,
  });
  if (error) return new Response(error.message, { status: 500 });
  const targets = ((data ?? []) as Target[]).filter((t) => t.enabled);
  if (targets.length === 0) return Response.json({ sent: 0 });

  const { accessToken, projectId } = await fcmSender();
  let sent = 0;
  for (const t of targets) {
    const copy = eventThanksPush(t.honoree_label, t.note);
    const result = await sendPush(accessToken, projectId, {
      token: t.token,
      title: copy.title,
      body: copy.body,
      route: `/events/${eventId}`,
    });
    if (result === "sent") sent++;
    if (result === "stale") await deleteStaleToken(supabase, t.token);
  }
  return Response.json({ sent });
});

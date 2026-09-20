// Push for a newly logged (non-surprise) member gift. Called by the DB
// trigger (pg_net) with { gift_id }. Auth: X-Cron-Secret. Deploy with
// --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { giftLoggedPush } from "../_shared/messages.ts";

interface Target {
  token: string;
  platform: string;
  recipient_id: string;
  giver_label: string;
  item_label: string;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const { gift_id } = await req.json().catch(() => ({}));
  if (typeof gift_id !== "string") {
    return new Response("bad request", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("gift_push_targets", {
    p_gift_id: gift_id,
  });
  if (error) return new Response(error.message, { status: 500 });
  const targets = (data ?? []) as Target[];
  if (targets.length === 0) return Response.json({ sent: 0 });

  const { accessToken, projectId } = await fcmSender();
  let sent = 0;
  for (const t of targets) {
    const copy = giftLoggedPush(t.giver_label, t.item_label);
    const result = await sendPush(accessToken, projectId, {
      token: t.token,
      title: copy.title,
      body: copy.body,
      route: `/gifts/${gift_id}?side=giver`,
    });
    if (result === "sent") sent++;
    if (result === "stale") await deleteStaleToken(supabase, t.token);
  }
  return Response.json({ sent, targets: targets.length });
});

// G-210 — "Your surprise opened" push. Hourly via pg_cron → pg_net.
// Due gifts come from surprise_reveal_targets(); every due gift is marked
// announced (reveal_notified_at) whether or not a push went out, so a
// recipient without devices or opted out is not retried forever.
// Auth: X-Cron-Secret (CRON_SECRET). `?dry=1` lists without sending.
// Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { surprisePush } from "../_shared/messages.ts";

interface Target {
  gift_id: string;
  token: string | null;
  platform: string | null;
  recipient_id: string;
  giver_label: string | null;
  item_label: string;
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
  const { data, error } = await supabase.rpc("surprise_reveal_targets");
  if (error) return new Response(error.message, { status: 500 });
  const targets = (data ?? []) as Target[];
  const giftIds = [...new Set(targets.map((t) => t.gift_id))];
  if (dry) return Response.json({ dry: true, due: giftIds.length, targets });
  if (giftIds.length === 0) return Response.json({ sent: 0, due: 0 });

  let sent = 0;
  const sendable = targets.filter((t) => t.enabled && t.token);
  if (sendable.length > 0) {
    const { accessToken, projectId } = await fcmSender();
    for (const t of sendable) {
      const copy = surprisePush(t.giver_label, t.item_label);
      const result = await sendPush(accessToken, projectId, {
        token: t.token!,
        title: copy.title,
        body: copy.body,
        route: `/gifts/${t.gift_id}?side=giver`,
      });
      if (result === "sent") sent++;
      if (result === "stale") await deleteStaleToken(supabase, t.token!);
    }
  }

  const { error: markError } = await supabase
    .from("gifts")
    .update({ reveal_notified_at: new Date().toISOString() })
    .in("id", giftIds);
  if (markError) return new Response(markError.message, { status: 500 });

  return Response.json({ sent, due: giftIds.length });
});

// G-308 — a recipient shared the unboxing of a gift: tell the giver and
// any group-gift contributors. Called by the posts_notify_unboxing trigger
// (pg_net) with { post_id }. Auth: X-Cron-Secret. Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { type Notice, recordNotices } from "../_shared/inbox.ts";
import { giftUnboxedPush } from "../_shared/messages.ts";

interface Target {
  token: string | null;
  platform: string | null;
  user_id: string;
  author_id: string;
  recipient_label: string;
  item_label: string;
  enabled: boolean;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const { post_id } = await req.json().catch(() => ({}));
  if (typeof post_id !== "string") {
    return new Response("bad request", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("unboxing_targets", {
    p_post: post_id,
  });
  if (error) return new Response(error.message, { status: 500 });
  const all = (data ?? []) as Target[];
  if (all.length === 0) return Response.json({ sent: 0 });

  // The moment itself is the destination: it lives 24h in the viewer.
  const routeFor = (t: Target) => `/stories/${t.author_id}`;
  await recordNotices(
    supabase,
    all.map((t): Notice => {
      const copy = giftUnboxedPush(t.recipient_label, t.item_label);
      return {
        user_id: t.user_id,
        kind: "gift:unboxed",
        title: copy.title,
        body: copy.body,
        route: routeFor(t),
      };
    }),
  );
  const targets = all.filter(
    (t): t is Target & { token: string } => t.enabled && t.token !== null,
  );
  if (targets.length === 0) return Response.json({ sent: 0 });
  const { accessToken, projectId } = await fcmSender();
  let sent = 0;
  for (const t of targets) {
    const copy = giftUnboxedPush(t.recipient_label, t.item_label);
    const result = await sendPush(accessToken, projectId, {
      token: t.token,
      title: copy.title,
      body: copy.body,
      route: routeFor(t),
    });
    if (result === "sent") sent++;
    if (result === "stale") await deleteStaleToken(supabase, t.token);
  }
  return Response.json({ sent, targets: all.length });
});

// G-210 — Push for a new comment. Called by the DB trigger (pg_net) with
// { kind: 'gift' | 'post', comment_id }. Targets and spoiler/opt-out/block
// rules live in SQL (comment_push_targets); this just sends.
// Auth: X-Cron-Secret (CRON_SECRET). Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { commentPush } from "../_shared/messages.ts";

interface Target {
  token: string;
  platform: string;
  notified_user: string;
  commenter_label: string;
  item_label: string;
  snippet: string;
  route: string;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const { kind, comment_id } = await req.json().catch(() => ({}));
  if ((kind !== "gift" && kind !== "post") || typeof comment_id !== "string") {
    return new Response("bad request", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase.rpc("comment_push_targets", {
    p_kind: kind,
    p_comment_id: comment_id,
  });
  if (error) return new Response(error.message, { status: 500 });
  const targets = (data ?? []) as Target[];
  if (targets.length === 0) return Response.json({ sent: 0 });

  const { accessToken, projectId } = await fcmSender();
  let sent = 0;
  for (const t of targets) {
    const copy = commentPush(t.commenter_label, t.item_label, t.snippet, kind);
    const result = await sendPush(accessToken, projectId, {
      token: t.token,
      title: copy.title,
      body: copy.body,
      route: t.route,
    });
    if (result === "sent") sent++;
    if (result === "stale") await deleteStaleToken(supabase, t.token);
  }
  return Response.json({ sent, targets: targets.length });
});

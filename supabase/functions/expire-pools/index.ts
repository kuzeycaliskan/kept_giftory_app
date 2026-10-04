// G-309 — pools that did not reach their price within 24h are removed by
// expire_pools() (hourly via pg_cron → pg_net); this tells the organizer
// and the pledgers. Auth: X-Cron-Secret (CRON_SECRET). `?dry=1` lists
// without touching anything. Deploy with --no-verify-jwt.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";
import { poolExpiredPush, poolReminderPush } from "../_shared/messages.ts";

interface Expired {
  claim_id: string;
  item_title: string | null;
  user_ids: string[];
}

interface Reminder {
  claim_id: string;
  item_title: string | null;
  organizer_id: string;
  total: number | string;
  target: number | string;
}

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
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  if (new URL(req.url).searchParams.get("dry") === "1") {
    const { count, error } = await supabase
      .from("wishlist_claims")
      .select("id", { count: "exact", head: true })
      .eq("kind", "shared")
      .is("gift_id", null)
      .lte("expires_at", new Date().toISOString());
    if (error) return new Response(error.message, { status: 500 });
    return Response.json({ dry: true, due: count ?? 0 });
  }

  const { data, error } = await supabase.rpc("expire_pools");
  if (error) return new Response(error.message, { status: 500 });
  const expired = (data ?? []) as Expired[];

  const { data: remData, error: remError } = await supabase.rpc(
    "pool_reminder_targets",
  );
  if (remError) return new Response(remError.message, { status: 500 });
  const reminders = (remData ?? []) as Reminder[];

  if (expired.length === 0 && reminders.length === 0) {
    return Response.json({ expired: 0, reminded: 0, sent: 0 });
  }

  const ids = [
    ...new Set([
      ...expired.flatMap((e) => e.user_ids),
      ...reminders.map((r) => r.organizer_id),
    ]),
  ];
  const { data: targetsData, error: targetsError } = await supabase.rpc(
    "push_targets_for_users",
    { p_ids: ids },
  );
  if (targetsError) {
    return new Response(targetsError.message, { status: 500 });
  }
  const targets = ((targetsData ?? []) as Target[]).filter((t) => t.enabled);
  let sent = 0;
  if (targets.length > 0) {
    const { accessToken, projectId } = await fcmSender();
    for (const t of targets) {
      const mine = expired.filter((e) => e.user_ids.includes(t.user_id));
      const copies = mine.length > 0
        ? [poolExpiredPush(mine[0]?.item_title ?? null, mine.length)]
        : [];
      for (const r of reminders.filter((r) => r.organizer_id === t.user_id)) {
        copies.push(
          poolReminderPush(r.item_title, Number(r.total), Number(r.target)),
        );
      }
      for (const copy of copies) {
        const result = await sendPush(accessToken, projectId, {
          token: t.token,
          title: copy.title,
          body: copy.body,
          route: "/gifts",
        });
        if (result === "sent") sent++;
        if (result === "stale") await deleteStaleToken(supabase, t.token);
      }
    }
  }
  if (reminders.length > 0) {
    // Marked whether or not a device took it: one reminder per pool.
    const { error: markError } = await supabase.rpc("mark_pools_reminded", {
      p_ids: reminders.map((r) => r.claim_id),
    });
    if (markError) return new Response(markError.message, { status: 500 });
  }
  return Response.json({
    expired: expired.length,
    reminded: reminders.length,
    sent,
  });
});

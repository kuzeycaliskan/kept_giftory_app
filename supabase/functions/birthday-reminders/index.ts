// G-62 — Birthday reminder dispatch.
// Runs daily via pg_cron → pg_net → this function. For every user whose
// birthday is REMINDER_DAYS away (Europe/Istanbul; Feb-29 celebrated on
// Mar 1 in non-leap years, mirroring the app's birthday_math), notify each
// accepted friend — unless that friend already logged a gift for them this
// cycle, or was already notified for this birthday (idempotency log).
//
// Auth: requires the X-Cron-Secret header (CRON_SECRET env). Secrets:
//   CRON_SECRET, FCM_SERVICE_ACCOUNT (Firebase service-account JSON).
// `?dry=1` computes and returns the plan without sending or logging.
// `?days=N&kind=event` (V3): the 14-day "open a gift event" nudge on the
// same pipeline — separate idempotency key (log.kind), own copy and route.

import { createClient } from "npm:@supabase/supabase-js@2";
import { deleteStaleToken, fcmSender, sendPush } from "../_shared/fcm.ts";

const REMINDER_DAYS = Number(Deno.env.get("REMINDER_DAYS") ?? "5");
const TZ = "Europe/Istanbul";

interface Target {
  token: string;
  platform: string;
  notified_user: string;
  birthday_user: string;
  birthday_label: string;
  birthday_on: string;
}

function istanbulToday(): Date {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
  return new Date(`${parts}T00:00:00Z`);
}

function isLeap(year: number): boolean {
  return (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const params = new URL(req.url).searchParams;
  const dry = params.get("dry") === "1";
  const kind = params.get("kind") === "event" ? "event" : "reminder";
  const daysAhead = Number(params.get("days") ?? REMINDER_DAYS);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Target celebrated date = today + REMINDER_DAYS in Istanbul.
  const today = istanbulToday();
  const target = new Date(today);
  target.setUTCDate(target.getUTCDate() + daysAhead);
  const mm = String(target.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(target.getUTCDate()).padStart(2, "0");
  const targetMmdd = `${mm}-${dd}`;
  // Feb-29 birthdays are celebrated Mar 1 in non-leap years.
  const alsoFeb29 = targetMmdd === "03-01" && !isLeap(target.getUTCFullYear());
  const birthdayOn = `${target.getUTCFullYear()}-${targetMmdd}`;

  // One SQL pass: birthday people → their accepted friends → friends' tokens,
  // minus already-notified and already-gifted-this-cycle.
  const { data, error } = await supabase.rpc("birthday_reminder_targets", {
    p_mmdd: targetMmdd,
    p_include_feb29: alsoFeb29,
    p_birthday_on: birthdayOn,
  });
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }
  const targets = (data ?? []) as Target[];

  if (dry) {
    return new Response(
      JSON.stringify({
        dry: true,
        kind,
        birthdayOn,
        count: targets.length,
        targets,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  }
  if (targets.length === 0) {
    return new Response(JSON.stringify({ sent: 0, birthdayOn }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const { accessToken, projectId } = await fcmSender();

  let sent = 0;
  const seenPairs = new Set<string>();
  for (const t of targets) {
    // Idempotency: one log row per (friend, birthday person, date); insert
    // once per pair even when the friend has several devices.
    const pairKey = `${t.notified_user}:${t.birthday_user}`;
    if (!seenPairs.has(pairKey)) {
      const { error: logError } = await supabase
        .from("birthday_reminder_log")
        .insert({
          notified_user: t.notified_user,
          birthday_user: t.birthday_user,
          birthday_on: birthdayOn,
          kind,
        });
      if (logError) continue; // already sent in a previous run
      seenPairs.add(pairKey);
    }

    const result = await sendPush(
      accessToken,
      projectId,
      kind === "event"
        ? {
          token: t.token,
          title: "🎁 Kept",
          body: `${t.birthday_label} doğum gününe ${daysAhead} gün kaldı — ` +
            "arkadaşlarla hediye event'i aç.",
          route: `/events/for/${t.birthday_user}` +
            `?name=${encodeURIComponent(t.birthday_label)}`,
        }
        : {
          token: t.token,
          title: "🎁 Kept",
          body: `${t.birthday_label} doğum gününe ${daysAhead} gün kaldı! ` +
            "Hediye fikirlerine göz at.",
          route: `/users/${t.birthday_user}` +
            `?name=${encodeURIComponent(t.birthday_label)}`,
        },
    );
    if (result === "sent") {
      sent++;
    } else if (result === "stale") {
      // UNREGISTERED: stale token — clean it up.
      await deleteStaleToken(supabase, t.token);
    }
  }

  return new Response(JSON.stringify({ sent, birthdayOn }), {
    headers: { "Content-Type": "application/json" },
  });
});

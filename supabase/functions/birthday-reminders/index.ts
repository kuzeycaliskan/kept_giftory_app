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

import { createClient } from "npm:@supabase/supabase-js@2";

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

async function fcmAccessToken(sa: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replaceAll("+", "-")
      .replaceAll("/", "_")
      .replace(/=+$/, "");
  const unsigned = `${enc(header)}.${enc(claims)}`;

  const pem = sa.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll("\n", "");
  const keyData = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replace(/=+$/, "");

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${sigB64}`,
    }),
  });
  if (!res.ok) throw new Error(`oauth ${res.status}: ${await res.text()}`);
  return (await res.json()).access_token as string;
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

  // Target celebrated date = today + REMINDER_DAYS in Istanbul.
  const today = istanbulToday();
  const target = new Date(today);
  target.setUTCDate(target.getUTCDate() + REMINDER_DAYS);
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
      JSON.stringify({ dry: true, birthdayOn, count: targets.length, targets }),
      { headers: { "Content-Type": "application/json" } },
    );
  }
  if (targets.length === 0) {
    return new Response(JSON.stringify({ sent: 0, birthdayOn }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const sa = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT")!);
  const accessToken = await fcmAccessToken(sa);
  const fcmUrl =
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;

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
        });
      if (logError) continue; // already sent in a previous run
      seenPairs.add(pairKey);
    }

    const res = await fetch(fcmUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: t.token,
          notification: {
            title: "🎁 Kept",
            body:
              `${t.birthday_label} doğum gününe ${REMINDER_DAYS} gün kaldı! ` +
              "Hediye fikirlerine göz at.",
          },
          data: {
            route: `/users/${t.birthday_user}` +
              `?name=${encodeURIComponent(t.birthday_label)}`,
          },
        },
      }),
    });
    if (res.ok) {
      sent++;
    } else if (res.status === 404 || res.status === 410) {
      // UNREGISTERED: stale token — clean it up.
      await supabase.from("device_tokens").delete().eq("token", t.token);
    }
  }

  return new Response(JSON.stringify({ sent, birthdayOn }), {
    headers: { "Content-Type": "application/json" },
  });
});

// Shared FCM v1 sender for Edge Functions: service-account OAuth token +
// one send helper that reports stale tokens so callers can prune them.

import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

export interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

export async function fcmAccessToken(sa: ServiceAccount): Promise<string> {
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

export interface PushMessage {
  token: string;
  title: string;
  body: string;
  /** In-app route the tap opens (client reads data.route). */
  route: string;
}

export type SendResult = "sent" | "stale" | "failed";

/** Sends one message; "stale" = FCM says the token is gone (404/410). */
export async function sendPush(
  accessToken: string,
  projectId: string,
  message: PushMessage,
): Promise<SendResult> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: message.token,
          notification: { title: message.title, body: message.body },
          data: { route: message.route },
        },
      }),
    },
  );
  if (res.ok) return "sent";
  if (res.status === 404 || res.status === 410) return "stale";
  return "failed";
}

export async function deleteStaleToken(
  supabase: SupabaseClient,
  token: string,
): Promise<void> {
  await supabase.from("device_tokens").delete().eq("token", token);
}

/** Bootstraps sender + project id from the FCM_SERVICE_ACCOUNT secret. */
export async function fcmSender(): Promise<
  { accessToken: string; projectId: string }
> {
  const sa = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT")!) as ServiceAccount;
  return { accessToken: await fcmAccessToken(sa), projectId: sa.project_id };
}

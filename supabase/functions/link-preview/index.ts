// G-211: fetch OG metadata for a product URL, server-side.
//
// Security model (design doc: pbi/v2.md G-211):
//  * JWT required — anonymous callers are rejected.
//  * SSRF guards: http/https only, no IP-literal or localhost/private hosts,
//    capped redirects (re-validated per hop), 5s timeout, 1MB read cap,
//    text/html only.
//  * Rate limit: 10 requests/user/minute (link_preview_requests table).
//  * Images are downloaded by the server (never hotlinked by clients — no IP
//    leak to third parties) into the public `link-previews` bucket, 300KB cap.
//  * Cache: one row per url_hash; repeat requests return the cached preview.

import { createClient } from "npm:@supabase/supabase-js@2";
import {
  guardedFetch,
  isRefreshDue,
  previewRow,
  readCapped,
  sniffImage,
  validateTargetUrl,
} from "./guards.ts";
import { extractMeta } from "./extract.ts";

const MAX_HTML_BYTES = 1_000_000;
const MAX_IMAGE_BYTES = 300_000;
const RATE_LIMIT_PER_MINUTE = 10;

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin = createClient(supabaseUrl, serviceKey);

// ── Handler ─────────────────────────────────────────────────────────────────

async function sha256Hex(s: string): Promise<string> {
  const d = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(s),
  );
  return [...new Uint8Array(d)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  // Caller must be a signed-in user (verified against auth, not just parsed).
  const jwt = req.headers.get("Authorization")?.replace("Bearer ", "") ?? "";
  const { data: userData, error: userError } = await admin.auth.getUser(jwt);
  if (userError || !userData.user) return json(401, { error: "unauthorized" });
  const userId = userData.user.id;

  const body = await req.json().catch(() => ({}));
  const rawUrl = body?.url;
  // Client-extracted metadata fallback (G-211): bot-walled shops (Akamai on
  // Trendyol/Hepsiburada) block ALL server-side fetching, so the app pulls
  // the page in a hidden WebView and sends the OG fields here. The server
  // still validates the URL, rate-limits, and downloads the image itself.
  // Trust note: meta is user-supplied content (same trust level as free
  // text); worst case is a cosmetic wrong title in the shared cache.
  const clientMeta = body?.meta;
  // A periodic refresh ask (see isRefreshDue): the server decides whether
  // the slot is open and claims it before trying, so concurrent viewers of
  // the same product cost one attempt per period.
  const refresh = body?.refresh === true;
  if (typeof rawUrl !== "string") return json(400, { error: "bad_request" });

  const url = validateTargetUrl(rawUrl.trim());
  if (!url) return json(422, { error: "invalid_url" });

  // Normalize: strip fragment; keep query (product ids often live there).
  url.hash = "";
  const normalized = url.toString();
  const urlHash = await sha256Hex(normalized);

  // Cache hit → no rate-limit charge, no refetch — unless the row is still
  // missing its image or price: a user pasting that link again is the one
  // moment we try once more (rate-limited like any fetch; a miss keeps the
  // row as it was). Nothing retries in the background.
  const { data: cached } = await admin
    .from("link_previews")
    .select("id, title, image_path, price, site, price_checked_at")
    .eq("url_hash", urlHash)
    .maybeSingle();
  if (cached) {
    const incomplete = cached.image_path === null || cached.price === null;
    const due = isRefreshDue(cached.price, cached.price_checked_at);
    // Posting meta: accepted for an incomplete row, or as the second half
    // of a refresh this server already opened. Plain lookups: refetch only
    // an incomplete row (a fresh paste) or a refresh whose slot is due.
    const proceed = clientMeta
      ? incomplete || refresh
      : incomplete || (refresh && due);
    if (!proceed) return json(200, { preview: cached, cached: true });
    if (refresh && !clientMeta) {
      // Claim the slot now: a failed attempt still waits a full period.
      await admin
        .from("link_previews")
        .update({ price_checked_at: new Date().toISOString() })
        .eq("id", cached.id);
    }
  }

  // Rate limit: N fetches per user per minute.
  const minuteAgo = new Date(Date.now() - 60_000).toISOString();
  const { count } = await admin
    .from("link_preview_requests")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("requested_at", minuteAgo);
  if ((count ?? 0) >= RATE_LIMIT_PER_MINUTE) {
    return json(429, { error: "rate_limited" });
  }
  await admin.from("link_preview_requests").insert({ user_id: userId });
  // Opportunistic prune (cheap, keeps the table tiny).
  await admin
    .from("link_preview_requests")
    .delete()
    .lt("requested_at", minuteAgo);

  // Metadata: client-supplied (bot-walled sites) or fetched+parsed here.
  let meta: { title?: string; image?: string; price?: string; site?: string };
  if (clientMeta && typeof clientMeta === "object") {
    const str = (v: unknown) =>
      typeof v === "string" && v.trim() ? v.trim() : undefined;
    meta = {
      title: str(clientMeta.title),
      image: str(clientMeta.image),
      price: str(clientMeta.price),
      site: str(clientMeta.site),
    };
  } else {
    const res = await guardedFetch(url);
    if (!res) return json(422, { error: "fetch_failed" });
    const contentType = res.headers.get("content-type") ?? "";
    if (!contentType.includes("text/html")) {
      return json(422, { error: "not_html" });
    }
    const bytes = await readCapped(res, MAX_HTML_BYTES);
    if (!bytes) return json(422, { error: "too_large" });
    meta = extractMeta(new TextDecoder().decode(bytes), url.hostname);
  }
  if (!meta.title) return json(422, { error: "no_metadata" });

  // Image: prefer client-supplied bytes (bot-walled CDNs), else download
  // here. Bytes are size-capped and magic-byte sniffed — declared types
  // are never trusted. A refresh is about the price: an image the row
  // already has is kept (a guessed hero image must never replace it).
  let imagePath: string | null = null;
  const keepImage = refresh && cached?.image_path != null;
  const b64 = keepImage ? undefined : clientMeta?.image_b64;
  if (typeof b64 === "string" && b64.length <= MAX_IMAGE_BYTES * 1.4) {
    try {
      const bytes = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
      const ext = bytes.length <= MAX_IMAGE_BYTES ? sniffImage(bytes) : null;
      if (ext) {
        const path = `${urlHash}.${ext}`;
        const { error: upErr } = await admin.storage
          .from("link-previews")
          .upload(path, bytes, {
            contentType: ext === "jpg" ? "image/jpeg" : `image/${ext}`,
            upsert: true,
          });
        if (!upErr) imagePath = path;
      }
    } catch (_) {
      // invalid base64 → treated as no image
    }
  }
  if (imagePath === null && !keepImage && meta.image) {
    const imgUrl = validateTargetUrl(new URL(meta.image, url).toString());
    if (imgUrl) {
      const imgRes = await guardedFetch(imgUrl);
      const imgType = imgRes?.headers.get("content-type") ?? "";
      if (imgRes && imgType.startsWith("image/")) {
        const imgBytes = await readCapped(imgRes, MAX_IMAGE_BYTES);
        if (imgBytes) {
          const ext = imgType.includes("png")
            ? "png"
            : imgType.includes("webp")
            ? "webp"
            : "jpg";
          const path = `${urlHash}.${ext}`;
          const { error: upErr } = await admin.storage
            .from("link-previews")
            .upload(path, imgBytes, { contentType: imgType, upsert: true });
          if (!upErr) imagePath = path;
        }
      }
    }
  }

  const { data: row, error: insErr } = await admin
    .from("link_previews")
    .upsert(
      previewRow({
        urlHash,
        url: normalized,
        hostname: url.hostname,
        meta: { title: meta.title, price: meta.price, site: meta.site },
        imagePath,
      }),
      { onConflict: "url_hash" },
    )
    .select("id, title, image_path, price, site, price_checked_at")
    .single();
  if (insErr) return json(500, { error: "store_failed" });

  return json(200, { preview: row, cached: false });
});

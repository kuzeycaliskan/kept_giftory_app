const FETCH_TIMEOUT_MS = 5000;
const MAX_REDIRECTS = 3;

// G-211 pure helpers: SSRF validation + OG parsing (unit-tested).

// ── SSRF guards ─────────────────────────────────────────────────────────────

function isPrivateHost(hostname: string): boolean {
  const h = hostname.toLowerCase();
  if (h === "localhost" || h.endsWith(".local") || h.endsWith(".internal")) {
    return true;
  }
  // IPv4 literal?
  const v4 = h.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/);
  if (v4) {
    const [a, b] = [Number(v4[1]), Number(v4[2])];
    if (a === 10 || a === 127 || a === 0) return true;
    if (a === 172 && b >= 16 && b <= 31) return true;
    if (a === 192 && b === 168) return true;
    if (a === 169 && b === 254) return true; // link-local / metadata
    return true; // ANY bare IP literal is rejected — hostnames only
  }
  // Any bare IP literal (incl. IPv6 in brackets) is rejected outright.
  if (v4 || h.startsWith("[") || /^[0-9a-f:]+$/.test(h)) return true;
  return false;
}

export function validateTargetUrl(raw: string): URL | null {
  let url: URL;
  try {
    url = new URL(raw);
  } catch {
    return null;
  }
  if (url.protocol !== "http:" && url.protocol !== "https:") return null;
  if (url.username || url.password) return null;
  if (url.port && url.port !== "80" && url.port !== "443") return null;
  if (isPrivateHost(url.hostname)) return null;
  return url;
}

/// Shops' share links (ty.gl, app.hb.biz) bounce through an Adjust
/// interstitial (`*.adj.st`) that tries the app first and only later moves
/// to the web page via JS — a plain fetch stops there with the title
/// "adjust deeplinking...". The web fallback rides along as a query
/// parameter; return it, or null when this is not such a link.
export function unwrapTrackingLink(url: URL): URL | null {
  const host = url.hostname.toLowerCase();
  const isAdjust = host === "adj.st" || host.endsWith(".adj.st") ||
    host === "app.adjust.com";
  if (!isAdjust) return null;
  for (
    const key of [
      "adjust_redirect",
      "adj_redirect",
      "adjust_fallback",
      "adj_fallback",
      "adjust_redirect_ios",
      "adj_redirect_ios",
      "adjust_redirect_android",
      "adj_redirect_android",
    ]
  ) {
    const raw = url.searchParams.get(key);
    if (!raw) continue;
    const target = validateTargetUrl(raw);
    if (target) return target;
  }
  return null;
}

/** Fetch with manual redirects so every hop is re-validated. */
export async function guardedFetch(url: URL): Promise<Response | null> {
  let current = url;
  for (let hop = 0; hop <= MAX_REDIRECTS; hop++) {
    const unwrapped = unwrapTrackingLink(current);
    if (unwrapped) {
      current = unwrapped;
      continue;
    }
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
    let res: Response;
    try {
      res = await fetch(current, {
        redirect: "manual",
        signal: controller.signal,
        headers: {
          // Some shops gate OG tags behind crawler-ish user agents.
          "User-Agent":
            "Mozilla/5.0 (compatible; KeptBot/1.0; +https://kuzeycaliskan.github.io/kept.html)",
          "Accept": "text/html,application/xhtml+xml",
        },
      });
    } catch {
      return null;
    } finally {
      clearTimeout(timer);
    }
    if (res.status >= 300 && res.status < 400) {
      const loc = res.headers.get("location");
      if (!loc) return null;
      const next = validateTargetUrl(new URL(loc, current).toString());
      if (!next) return null;
      current = next;
      continue;
    }
    return res.ok ? res : null;
  }
  return null;
}

export async function readCapped(
  res: Response,
  cap: number,
): Promise<Uint8Array | null> {
  const reader = res.body?.getReader();
  if (!reader) return null;
  const chunks: Uint8Array[] = [];
  let total = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.length;
    if (total > cap) {
      await reader.cancel();
      return null;
    }
    chunks.push(value);
  }
  const out = new Uint8Array(total);
  let off = 0;
  for (const c of chunks) {
    out.set(c, off);
    off += c.length;
  }
  return out;
}

// ── OG parsing ──────────────────────────────────────────────────────────────

export function parseMeta(html: string): {
  title?: string;
  image?: string;
  price?: string;
  site?: string;
} {
  const meta = (names: string[]): string | undefined => {
    for (const name of names) {
      // property= or name=, content before or after, quote style free.
      const re = new RegExp(
        `<meta[^>]+(?:property|name)=["']${name}["'][^>]*content=["']([^"']*)["']` +
          `|<meta[^>]+content=["']([^"']*)["'][^>]*(?:property|name)=["']${name}["']`,
        "i",
      );
      const m = html.match(re);
      const v = m?.[1] ?? m?.[2];
      if (v) return decodeEntities(v.trim());
    }
    return undefined;
  };
  const title = meta(["og:title", "twitter:title"]) ??
    html.match(/<title[^>]*>([^<]*)<\/title>/i)?.[1]?.trim();
  return {
    title: title ? decodeEntities(title) : undefined,
    image: meta(["og:image", "og:image:url", "twitter:image"]),
    price: meta([
      "og:price:amount",
      "product:price:amount",
      "twitter:data1",
    ]) ?? structuredPrice(html),
    site: meta(["og:site_name"]),
  };
}

/// Shops that skip the OG price still publish it for Google: JSON-LD
/// `offers.price` (Product schema) or an `itemprop="price"` meta. Returns a
/// display string ("₺1.299,00") or undefined.
export function structuredPrice(html: string): string | undefined {
  const itemprop = html.match(
    /<meta[^>]+itemprop=["']price["'][^>]*content=["']([^"']+)["']/i,
  )?.[1] ??
    html.match(
      /<meta[^>]+content=["']([^"']+)["'][^>]*itemprop=["']price["']/i,
    )?.[1];
  const currencyProp = html.match(
    /<meta[^>]+itemprop=["']priceCurrency["'][^>]*content=["']([A-Z]{3})["']/i,
  )?.[1];
  if (itemprop) return formatPrice(itemprop, currencyProp);

  const blocks = html.matchAll(
    /<script[^>]+type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi,
  );
  for (const block of blocks) {
    const json = block[1];
    // Regex, not JSON.parse: shop markup is often not strictly valid JSON.
    const price = json.match(/"(?:price|lowPrice)"\s*:\s*"?([0-9][0-9.,]*)"?/)
      ?.[1];
    if (!price) continue;
    const currency = json.match(/"priceCurrency"\s*:\s*"([A-Z]{3})"/)?.[1];
    return formatPrice(price, currency);
  }
  return undefined;
}

/// Structured prices are plain numbers ("1299" / "1299.90"); render them
/// the way the shops' own OG tags read so cards look alike.
export function formatPrice(
  raw: string,
  currency?: string,
): string | undefined {
  const normalized = raw.includes(",") && !raw.includes(".")
    ? raw.replace(",", ".")
    : raw.replace(/,/g, "");
  const value = Number(normalized);
  if (!Number.isFinite(value) || value <= 0) return undefined;
  try {
    return new Intl.NumberFormat("tr-TR", {
      style: "currency",
      currency: currency ?? "TRY",
    }).format(value);
  } catch {
    return undefined;
  }
}

function decodeEntities(s: string): string {
  return s
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;|&apos;/g, "'")
    .replace(/&nbsp;/g, " ");
}

/// Sniffs real image type from magic bytes — client-supplied bytes are
/// never trusted by declared content type. Returns extension or null.
export function sniffImage(bytes: Uint8Array): "jpg" | "png" | "webp" | null {
  if (bytes.length < 12) return null;
  if (bytes[0] === 0xff && bytes[1] === 0xd8) return "jpg";
  if (
    bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e &&
    bytes[3] === 0x47
  ) return "png";
  if (
    bytes[0] === 0x52 && bytes[1] === 0x49 && bytes[2] === 0x46 &&
    bytes[3] === 0x46 && bytes[8] === 0x57 && bytes[9] === 0x45 &&
    bytes[10] === 0x42 && bytes[11] === 0x50
  ) return "webp";
  return null;
}

/// The `link_previews` upsert payload. `image_path` is only sent when this
/// fetch produced an image: PostgREST updates just the columns present, so a
/// concurrent fetch that failed its image download cannot wipe an image a
/// sibling request stored a moment earlier (first-fetch race on a new URL).
export function previewRow(input: {
  urlHash: string;
  url: string;
  hostname: string;
  meta: { title: string; price?: string; site?: string };
  imagePath: string | null;
}): Record<string, string | null> {
  return {
    url_hash: input.urlHash,
    url: input.url,
    title: input.meta.title.slice(0, 300),
    ...(input.imagePath === null ? {} : { image_path: input.imagePath }),
    // Same rule as the image: a fetch that found no price never wipes one
    // a previous fetch stored.
    ...(input.meta.price === undefined
      ? {}
      : { price: input.meta.price.slice(0, 60) }),
    site: (input.meta.site ?? input.hostname).slice(0, 100),
  };
}

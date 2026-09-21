// Runs the on-device extractor (the JS string inside the Flutter
// WebviewOgFetcher) against saved shop markup, so a shop's DOM change or a
// selector slip shows up here instead of on a phone.
import { assertEquals } from "jsr:@std/assert@1";
import { DOMParser } from "jsr:@b-fuze/deno-dom@0.1.49";

const dartSource = await Deno.readTextFile(
  new URL(
    "../../../lib/features/link_preview/data/webview_og_fetcher.dart",
    import.meta.url,
  ),
);
const js = dartSource.match(/_extractJs = r'''\n([\s\S]*?)''';/)?.[1];
if (!js) throw new Error("extractor JS not found in webview_og_fetcher.dart");

function extract(html: string, hostname: string) {
  const doc = new DOMParser().parseFromString(html, "text/html");
  const g = globalThis as Record<string, unknown>;
  g.document = doc;
  g.location = { hostname };
  // deno-dom elements have no naturalWidth; the fallback image path stays off.
  const out = new Function(`return ${js}`)() as string;
  return JSON.parse(out) as {
    title: string | null;
    image: string | null;
    price: string | null;
    site: string | null;
  };
}

Deno.test("amazon mobile: price-to-pay assembled from parts, not the unit or list price", async () => {
  const html = await Deno.readTextFile(
    new URL("./fixtures/amazon_mobile_price.html", import.meta.url),
  );
  const m = extract(html, "www.amazon.com.tr");
  assertEquals(m.price, "1.904,06 TL");
  assertEquals(m.title?.startsWith("SONOFF Mini-ZB2GS-L"), true);
  assertEquals(m.image, null);
});

Deno.test("og tags still win when present", () => {
  const html = `<html><head><title>x</title>
    <meta property="og:title" content="Babolat Pure Drive">
    <meta property="product:price:amount" content="1.299,00 TL">
    <meta property="og:image" content="//cdn.example.com/x.jpg">
    <meta property="og:site_name" content="Trendyol"></head><body></body></html>`;
  const m = extract(html, "www.trendyol.com");
  assertEquals(m.title, "Babolat Pure Drive");
  assertEquals(m.price, "1.299,00 TL");
  assertEquals(m.image, "https://cdn.example.com/x.jpg");
  assertEquals(m.site, "Trendyol");
});

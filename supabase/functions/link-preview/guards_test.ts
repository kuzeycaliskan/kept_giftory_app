// deno test guards_test.ts — SSRF validation + OG parsing (G-211).
import { assertEquals, assertExists } from "jsr:@std/assert";
import {
  formatPrice,
  parseMeta,
  previewRow,
  sniffImage,
  structuredPrice,
  unwrapTrackingLink,
  validateTargetUrl,
} from "./guards.ts";

Deno.test("accepts normal product urls", () => {
  assertExists(validateTargetUrl("https://www.trendyol.com/x/y-p-123"));
  assertExists(validateTargetUrl("http://example.com/item?id=1"));
});

Deno.test("rejects non-http schemes", () => {
  assertEquals(validateTargetUrl("ftp://example.com"), null);
  assertEquals(validateTargetUrl("file:///etc/passwd"), null);
  assertEquals(validateTargetUrl("javascript:alert(1)"), null);
});

Deno.test("rejects localhost, private and metadata ranges", () => {
  for (
    const u of [
      "http://localhost/x",
      "http://127.0.0.1/x",
      "http://10.0.0.5/x",
      "http://172.16.1.1/x",
      "http://192.168.1.1/x",
      "http://169.254.169.254/latest/meta-data",
      "http://[::1]/x",
      "http://foo.internal/x",
    ]
  ) {
    assertEquals(validateTargetUrl(u), null, u);
  }
});

Deno.test("rejects credentials and odd ports", () => {
  assertEquals(validateTargetUrl("http://user:pw@example.com"), null);
  assertEquals(validateTargetUrl("http://example.com:8080/x"), null);
});

Deno.test("rejects bare ip literals even if public", () => {
  assertEquals(validateTargetUrl("http://8.8.8.8/x"), null);
});

Deno.test("unwraps an Adjust interstitial to the shop's web page", () => {
  const adj = new URL(
    "https://p8zh.adj.st/mk12x3o?adjust_t=x&adjust_deeplink=ty%3A%2F%2F%3FPage%3DProduct" +
      "&adjust_redirect=https%3A%2F%2Fwww.trendyol.com%2FMoliendo%2Fkahve-p-859268209%3FboutiqueId%3D61",
  );
  assertEquals(
    unwrapTrackingLink(adj)?.toString(),
    "https://www.trendyol.com/Moliendo/kahve-p-859268209?boutiqueId=61",
  );
  const fallbackOnly = new URL(
    "https://app.adjust.com/abc?adj_fallback=https%3A%2F%2Fshop.example.com%2Fx",
  );
  assertEquals(
    unwrapTrackingLink(fallbackOnly)?.toString(),
    "https://shop.example.com/x",
  );
  // A private fallback is refused like any other target.
  const evil = new URL(
    "https://p8zh.adj.st/x?adjust_redirect=http%3A%2F%2F127.0.0.1%2Fadmin",
  );
  assertEquals(unwrapTrackingLink(evil), null);
  assertEquals(unwrapTrackingLink(new URL("https://www.trendyol.com/x")), null);
});

Deno.test("parses og tags in either attribute order", () => {
  const html = `
    <meta property="og:title" content="Babolat Pure Drive" />
    <meta content="1.299,00 TL" property="product:price:amount" />
    <meta name="og:site_name" content="Trendyol">
    <meta property="og:image" content="https://cdn.example.com/x.jpg"/>`;
  const m = parseMeta(html);
  assertEquals(m.title, "Babolat Pure Drive");
  assertEquals(m.price, "1.299,00 TL");
  assertEquals(m.site, "Trendyol");
  assertEquals(m.image, "https://cdn.example.com/x.jpg");
});

Deno.test("reads the price from JSON-LD when og tags omit it", () => {
  const html = `
    <meta property="og:title" content="Roborock Qrevo" />
    <script type="application/ld+json">
      {"@type":"Product","name":"Roborock Qrevo",
       "offers":{"@type":"Offer","price":"34999.00","priceCurrency":"TRY"}}
    </script>`;
  assertEquals(parseMeta(html).price, "₺34.999,00");
});

Deno.test("reads an itemprop price and keeps the og price first", () => {
  const itemprop = `
    <meta itemprop="priceCurrency" content="TRY">
    <meta itemprop="price" content="1299.90">`;
  assertEquals(structuredPrice(itemprop), "₺1.299,90");
  const both = `
    <meta property="product:price:amount" content="1.299,00 TL" />
    <script type="application/ld+json">{"offers":{"price":"999"}}</script>`;
  assertEquals(parseMeta(both).price, "1.299,00 TL");
  assertEquals(structuredPrice("<html></html>"), undefined);
  assertEquals(formatPrice("0"), undefined);
  assertEquals(formatPrice("abc"), undefined);
});

Deno.test("falls back to <title> and decodes entities", () => {
  const m = parseMeta("<title>Raket &amp; Kılıf</title>");
  assertEquals(m.title, "Raket & Kılıf");
  assertEquals(m.image, undefined);
});

Deno.test("empty html yields nothing", () => {
  assertEquals(parseMeta("<html></html>").title, undefined);
});

Deno.test("sniffs image magic bytes, rejects fakes", () => {
  assertEquals(
    sniffImage(new Uint8Array([0xff, 0xd8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])),
    "jpg",
  );
  assertEquals(
    sniffImage(
      new Uint8Array([0x89, 0x50, 0x4e, 0x47, 0, 0, 0, 0, 0, 0, 0, 0]),
    ),
    "png",
  );
  const webp = new Uint8Array(12);
  webp.set([0x52, 0x49, 0x46, 0x46], 0);
  webp.set([0x57, 0x45, 0x42, 0x50], 8);
  assertEquals(sniffImage(webp), "webp");
  assertEquals(
    sniffImage(new TextEncoder().encode("<script>hi</script>")),
    null,
  );
  assertEquals(sniffImage(new Uint8Array(4)), null);
});

Deno.test("upsert row omits image_path when this fetch has no image", () => {
  const base = {
    urlHash: "h",
    url: "https://shop.test/x",
    hostname: "shop.test",
    meta: { title: "T" },
  };
  const withImage = previewRow({ ...base, imagePath: "h.jpg" });
  assertEquals(withImage.image_path, "h.jpg");
  const without = previewRow({ ...base, imagePath: null });
  assertEquals("image_path" in without, false);
  assertEquals(without.site, "shop.test");
  // No price found → the column is left alone, never nulled.
  assertEquals("price" in without, false);
  const priced = previewRow({
    ...base,
    meta: { title: "T", price: "₺1.299,00" },
    imagePath: null,
  });
  assertEquals(priced.price, "₺1.299,00");
});

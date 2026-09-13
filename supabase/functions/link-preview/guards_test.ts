// deno test guards_test.ts — SSRF validation + OG parsing (G-211).
import { assertEquals, assertExists } from "jsr:@std/assert";
import { parseMeta, validateTargetUrl } from "./guards.ts";

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

Deno.test("falls back to <title> and decodes entities", () => {
  const m = parseMeta("<title>Raket &amp; Kılıf</title>");
  assertEquals(m.title, "Raket & Kılıf");
  assertEquals(m.image, undefined);
});

Deno.test("empty html yields nothing", () => {
  assertEquals(parseMeta("<html></html>").title, undefined);
});

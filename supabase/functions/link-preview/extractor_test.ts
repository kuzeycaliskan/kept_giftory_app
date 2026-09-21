// extractor.js against saved shop markup: a shop's DOM change or a
// selector slip fails here, not on a phone. Fixtures are trimmed copies of
// real pages (title/head + the price block).
import { assertEquals } from "jsr:@std/assert@1";
import { extractMeta } from "./extract.ts";
import extractorSource from "./extractor_source.gen.ts";

async function fixture(name: string): Promise<string> {
  return await Deno.readTextFile(
    new URL(`./fixtures/${name}`, import.meta.url),
  );
}

Deno.test("trendyol: og tags carry everything, sprite ignored", async () => {
  const m = extractMeta(await fixture("trendyol_og.html"), "www.trendyol.com");
  assertEquals(
    m.title,
    "LEGO Editions Scuderia Ferrari HP Lewis Hamilton Kaskı 43022",
  );
  assertEquals(m.price, "4.098,70 TL");
  assertEquals(m.site, "Trendyol");
  assertEquals(m.image, "https://cdn.dsmcdn.com/ty1/product/x.jpg");
});

Deno.test("hepsiburada: protocol-relative og image, JSON-LD price", async () => {
  const m = extractMeta(
    await fixture("hepsiburada_og.html"),
    "www.hepsiburada.com",
  );
  assertEquals(m.title?.startsWith("Clinique Moisture Surge"), true);
  assertEquals(
    m.image,
    "https://productimages.hepsiburada.net/s/777/375-375/1.jpg",
  );
  assertEquals(m.price, "₺511,00");
  assertEquals(m.site, "www.hepsiburada.com");
});

Deno.test("amazon mobile: price-to-pay assembled from parts, not the unit or list price", async () => {
  const m = extractMeta(
    await fixture("amazon_mobile_price.html"),
    "www.amazon.com.tr",
  );
  assertEquals(m.price, "1.904,06 TL");
  assertEquals(m.title?.startsWith("SONOFF Mini-ZB2GS-L"), true);
  assertEquals(m.image, undefined);
  assertEquals(m.site, "www.amazon.com.tr");
});

Deno.test("itemprop price and entity-decoded <title> fallback", async () => {
  const m = extractMeta(await fixture("itemprop_price.html"), "shop.test");
  assertEquals(m.title, "Raket & Kılıf");
  assertEquals(m.price, "₺1.299,90");
});

Deno.test("empty page yields nothing", () => {
  const m = extractMeta("<html></html>", "shop.test");
  assertEquals(m.title, undefined);
  assertEquals(m.price, undefined);
  assertEquals(m.image, undefined);
});

Deno.test("the generated source module matches extractor.js byte for byte", async () => {
  const file = await Deno.readTextFile(
    new URL("./extractor.js", import.meta.url),
  );
  assertEquals(
    extractorSource,
    file,
    "run: deno run --allow-read --allow-write gen_extractor_source.ts",
  );
});

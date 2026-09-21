// Kept link-preview extractor — the ONE place that knows how a shop page
// exposes its title, image, price and site name. Runs unchanged in two
// hosts: the Edge Function (over deno-dom, for pages the server may fetch)
// and the app's hidden WebView (for bot-walled shops). It must stay plain
// ES5-ish script: no imports, no top-level await, returns a JSON string.
// Regression fixtures per shop live in fixtures/ and run in extractor_test.ts.
(function () {
  var m = function (p) {
    var e = document.querySelector(
      "meta[property='" + p + "'],meta[name='" + p + "']");
    return e ? e.getAttribute("content") : null;
  };
  var img = m("og:image") || m("og:image:url") || m("twitter:image");
  if (!img) {
    var l = document.querySelector("link[rel='image_src']");
    if (l) img = l.getAttribute("href");
  }
  if (!img) {
    // Fallback: largest rendered image on the page (product hero). Only
    // product-shaped images qualify — a tall sprite sheet of icons is
    // "large" too, and once won on Amazon.
    var best = null, bestArea = 40000; // require at least ~200x200
    document.querySelectorAll("img").forEach(function (e) {
      var w = e.naturalWidth || 0, h = e.naturalHeight || 0;
      var a = w * h, ratio = h > 0 ? w / h : 0;
      var shaped = w >= 200 && h >= 200 && ratio >= 0.5 && ratio <= 2;
      if (shaped && a > bestArea && e.src && e.src.indexOf("http") === 0) {
        best = e.src; bestArea = a;
      }
    });
    img = best;
  }
  if (img && img.indexOf("//") === 0) img = "https:" + img;
  // Price: og tags first; else what shops publish for Google (itemprop,
  // JSON-LD offers) rendered like an og price ("₺1.299,00").
  var fmt = function (raw, cur) {
    var n = Number(String(raw).indexOf(",") >= 0 && String(raw).indexOf(".") < 0
      ? String(raw).replace(",", ".") : String(raw).replace(/,/g, ""));
    if (!isFinite(n) || n <= 0) return null;
    try {
      return new Intl.NumberFormat("tr-TR",
        { style: "currency", currency: cur || "TRY" }).format(n);
    } catch (e) { return null; }
  };
  var price = m("product:price:amount") || m("og:price:amount") || null;
  if (!price) {
    // Amazon: no structured price. The price-to-pay block is the one that
    // is not a struck-through list price or a per-unit price; its
    // accessible text is often empty on mobile, so assemble the parts.
    var pay = document.querySelector(
      ".priceToPay," +
      "#corePriceDisplay_mobile_feature_div .a-price:not(.a-text-price)," +
      "#corePrice_mobile_feature_div .a-price:not(.a-text-price)," +
      "#corePriceDisplay_desktop_feature_div .a-price:not(.a-text-price)," +
      "#corePrice_feature_div .a-price:not(.a-text-price)");
    if (pay) {
      var off = pay.querySelector(".a-offscreen");
      var t = off ? (off.textContent || "").trim() : "";
      if (!t) {
        var whole = pay.querySelector(".a-price-whole");
        var frac = pay.querySelector(".a-price-fraction");
        // Amazon renders an empty symbol node before the number and the
        // real one after it — take the first non-empty.
        var sym = "";
        pay.querySelectorAll(".a-price-symbol").forEach(function (e) {
          if (!sym) sym = (e.textContent || "").trim();
        });
        var w = whole ? (whole.textContent || "").replace(/[^0-9.]/g, "") : "";
        if (w) {
          t = w + (frac ? "," + (frac.textContent || "").trim() : "") +
            " " + (sym || "TL");
        }
      }
      if (t) price = t.replace(/([0-9])(TL|TRY)$/, "$1 $2");
    }
  }
  if (!price) {
    var ip = document.querySelector("[itemprop='price']");
    var ipv = ip && (ip.getAttribute("content") || ip.textContent);
    var ipc = document.querySelector("[itemprop='priceCurrency']");
    if (ipv) price = fmt(ipv, ipc && ipc.getAttribute("content"));
  }
  if (!price) {
    var scripts = document.querySelectorAll(
      "script[type='application/ld+json']");
    for (var i = 0; i < scripts.length && !price; i++) {
      var t = scripts[i].textContent || "";
      var pm = t.match(/"(?:price|lowPrice)"\s*:\s*"?([0-9][0-9.,]*)"?/);
      if (!pm) continue;
      var cm = t.match(/"priceCurrency"\s*:\s*"([A-Z]{3})"/);
      price = fmt(pm[1], cm && cm[1]);
    }
  }
  return JSON.stringify({
    title: m("og:title") || m("twitter:title") || document.title || null,
    image: img || null,
    price: price,
    site: m("og:site_name") ||
      (typeof location !== "undefined" && location.hostname) || null,
  });
})()
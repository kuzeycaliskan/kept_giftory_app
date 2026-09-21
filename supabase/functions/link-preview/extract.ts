// Server-side host for extractor.js: parse the fetched HTML with deno-dom
// and run the same script the app runs in its WebView. The script arrives
// through extractor_source.gen.ts (regenerate with gen_extractor_source.ts).
import { DOMParser } from "jsr:@b-fuze/deno-dom@0.1.49";
import extractorSource from "./extractor_source.gen.ts";

export interface ExtractedMeta {
  title?: string;
  image?: string;
  price?: string;
  site?: string;
}

// Parenthesised and on its own line: the script opens with comment lines,
// which a bare `return` would swallow.
const run = new Function(`return (\n${extractorSource}\n);`) as () => string;

export function extractMeta(html: string, hostname: string): ExtractedMeta {
  const doc = new DOMParser().parseFromString(html, "text/html");
  const g = globalThis as Record<string, unknown>;
  g.document = doc;
  g.location = { hostname };
  let raw: Record<string, unknown>;
  try {
    raw = JSON.parse(run()) as Record<string, unknown>;
  } finally {
    delete g.document;
    delete g.location;
  }
  const str = (v: unknown) =>
    typeof v === "string" && v.trim() ? v.trim() : undefined;
  return {
    title: str(raw.title),
    image: str(raw.image),
    price: str(raw.price),
    site: str(raw.site),
  };
}

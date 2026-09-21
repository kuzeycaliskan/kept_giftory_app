// Regenerates extractor_source.gen.ts from extractor.js. The deploy bundler
// cannot import text files, so the script travels as a string module; the
// .js file stays the single source (the app bundles it as an asset) and
// extractor_test.ts fails when the two drift.
//   deno run --allow-read --allow-write gen_extractor_source.ts
const source = await Deno.readTextFile(
  new URL("./extractor.js", import.meta.url),
);
const out =
  `// GENERATED from extractor.js by gen_extractor_source.ts — do not edit.
export default ${JSON.stringify(source)};
`;
await Deno.writeTextFile(
  new URL("./extractor_source.gen.ts", import.meta.url),
  out,
);
console.log("extractor_source.gen.ts written");

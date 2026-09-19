// deno test messages_test.ts — push copy stays short and readable.
import { assertEquals } from "jsr:@std/assert";
import { commentPush, surprisePush } from "./messages.ts";

Deno.test("gift comment: commenter · item, clipped snippet", () => {
  const m = commentPush(
    "Zeynep",
    "LEGO Ferrari Kaskı",
    "Çok güzel olmuş!",
    "gift",
  );
  assertEquals(m.title, "Zeynep · LEGO Ferrari Kaskı");
  assertEquals(m.body, "Çok güzel olmuş!");
});

Deno.test("moment comment: says it is on a moment", () => {
  const m = commentPush("Ali", "", "vay", "post");
  assertEquals(m.title, "Ali anına yorum yaptı");
});

Deno.test("long snippets are clipped with an ellipsis", () => {
  const long = "a".repeat(200);
  const m = commentPush("Ali", "x", long, "gift");
  assertEquals(m.body.length, 60);
  assertEquals(m.body.endsWith("…"), true);
});

Deno.test("surprise: names the giver when known", () => {
  assertEquals(
    surprisePush("Kuzey", "Saat").body,
    "Kuzey sana Saat hediye etmiş.",
  );
  assertEquals(
    surprisePush(null, "Saat").body,
    "Sana bir hediye kaydedilmiş: Saat",
  );
});

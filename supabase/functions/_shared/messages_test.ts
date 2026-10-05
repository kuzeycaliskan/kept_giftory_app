// deno test messages_test.ts — push copy stays short and readable.
import { assertEquals } from "jsr:@std/assert";
import {
  commentPush,
  eventDeletedPush,
  eventRevealPush,
  eventThanksPush,
  giftLoggedPush,
  giftUnboxedPush,
  poolExpiredPush,
  poolLoggedPush,
  poolReleasedPush,
  poolReminderPush,
  poolRemovedPush,
  poolShareRemovedPush,
  surprisePush,
} from "./messages.ts";

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

Deno.test("gift logged: giver and item", () => {
  assertEquals(giftLoggedPush("Kamil", "LEGO Şato").body, "Kamil: LEGO Şato");
});

Deno.test("event note: names the honoree's event", () => {
  const m = commentPush("Kamil", "Ali", "Pastayı aldım", "event");
  assertEquals(m.title, "Kamil · Ali event'i");
});

Deno.test("event reveal: counts the friends, singular for one", () => {
  assertEquals(
    eventRevealPush(3).body,
    "3 arkadaşın hediyeni birlikte hazırladı. Kimler vardı, gör.",
  );
  assertEquals(eventRevealPush(1).body.startsWith("Bir arkadaşın"), true);
});

Deno.test("event thanks: honoree in the title, note clipped", () => {
  const m = eventThanksPush("Kuzey", "x".repeat(200));
  assertEquals(m.title, "Kuzey teşekkür etti 💐");
  assertEquals(m.body.length <= 91, true);
});

Deno.test("event deleted: names the honoree, mentions removed group gifts", () => {
  assertEquals(
    eventDeletedPush("Kuzey · Yeni bebek", 1).title,
    "Kuzey · Yeni bebek event'i silindi",
  );
  assertEquals(eventDeletedPush(null, 0).title, "Hediye event'i silindi");
  assertEquals(
    eventDeletedPush("Kuzey doğum günü", 0).body.startsWith(
      "Kaydedilen hediyeler",
    ),
    true,
  );
});

Deno.test("pool expired: names the item, counts when several", () => {
  assertEquals(
    poolExpiredPush("Espresso machine", 1).body,
    "Espresso machine 24 saatte fiyata ulaşmadı; katkılar düştü.",
  );
  assertEquals(poolExpiredPush(null, 2).body.startsWith("2 havuz"), true);
});

Deno.test("pool reminder and removal copy", () => {
  assertEquals(
    poolReminderPush("Tent", 400, 1000).body,
    "Tent: ₺400 / ₺1.000. Tamamla ya da hediyeyi kaydet.",
  );
  assertEquals(
    poolRemovedPush("Tent").body,
    "Tent istek listesinden kaldırıldı; katkılar düştü.",
  );
});

Deno.test("pool released / logged copy names the organizer", () => {
  assertEquals(
    poolReleasedPush("Kamil", "Tent").body,
    "Kamil Tent için havuzu dağıttı; katkın düştü.",
  );
  assertEquals(
    poolLoggedPush("Kamil", "Tent").body,
    "Kamil Tent kaydetti; sen de verenler arasındasın.",
  );
});

Deno.test("share removed copy", () => {
  assertEquals(
    poolShareRemovedPush("Kamil", "Tent").body,
    "Kamil Tent havuzundan katkını kaldırdı.",
  );
});

Deno.test("unboxing copy names recipient and item", () => {
  assertEquals(
    giftUnboxedPush("Kuzey", "Kahve makinesi").body,
    "Kuzey Kahve makinesi açılışını paylaştı.",
  );
});

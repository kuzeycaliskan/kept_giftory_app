import { assertEquals } from "jsr:@std/assert@1";
import { dedupeNotices } from "./inbox.ts";

Deno.test("inbox: same copy to the same user collapses, others stay", () => {
  const rows = dedupeNotices([
    { user_id: "a", kind: "x", title: "t", body: "b", route: "/r" },
    { user_id: "a", kind: "x", title: "t", body: "b", route: "/r" },
    { user_id: "b", kind: "x", title: "t", body: "b", route: "/r" },
    { user_id: "a", kind: "x", title: "t2", body: "b", route: "/r" },
  ]);
  assertEquals(rows.length, 3);
});

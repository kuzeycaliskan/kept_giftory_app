// deno test purge_test.ts — ordering + failure semantics of the purge (G-203).
import { assertEquals, assertRejects } from "jsr:@std/assert";
import {
  drainPurgeQueue,
  type ExpiredPost,
  groupByBucket,
  purgeExpiredPosts,
  type PurgeStore,
  type QueuedObject,
  type QueueStore,
} from "./purge.ts";

function post(n: number): ExpiredPost {
  return { id: `id-${n}`, media_path: `u/post-${n}.jpg` };
}

class FakeStore implements PurgeStore {
  calls: string[] = [];
  constructor(private rows: ExpiredPost[], private failRemove = false) {}

  listExpired(limit: number): Promise<ExpiredPost[]> {
    this.calls.push(`list:${limit}`);
    return Promise.resolve(this.rows.slice(0, limit));
  }

  removeObjects(paths: string[]): Promise<void> {
    this.calls.push(`remove:${paths.length}`);
    if (this.failRemove) return Promise.reject(new Error("storage down"));
    return Promise.resolve();
  }

  deleteRows(ids: string[]): Promise<void> {
    this.calls.push(`delete:${ids.length}`);
    this.rows = this.rows.filter((r) => !ids.includes(r.id));
    return Promise.resolve();
  }
}

Deno.test("nothing expired → no storage or delete calls", async () => {
  const store = new FakeStore([]);
  const result = await purgeExpiredPosts(store);
  assertEquals(result, {
    objectsRemoved: 0,
    rowsDeleted: 0,
    batches: 0,
    exhausted: true,
  });
  assertEquals(store.calls, ["list:200"]);
});

Deno.test("media is removed before rows, then drains in batches", async () => {
  const store = new FakeStore([1, 2, 3, 4, 5].map(post));
  const result = await purgeExpiredPosts(store, { batchSize: 2 });
  assertEquals(result.rowsDeleted, 5);
  assertEquals(result.objectsRemoved, 5);
  assertEquals(result.batches, 3);
  assertEquals(result.exhausted, true);
  assertEquals(store.calls, [
    "list:2",
    "remove:2",
    "delete:2",
    "list:2",
    "remove:2",
    "delete:2",
    "list:2",
    "remove:1",
    "delete:1",
  ]);
});

Deno.test("maxBatches bounds one tick and reports leftover work", async () => {
  const store = new FakeStore([1, 2, 3, 4, 5].map(post));
  const result = await purgeExpiredPosts(store, {
    batchSize: 2,
    maxBatches: 1,
  });
  assertEquals(result.rowsDeleted, 2);
  assertEquals(result.exhausted, false);
});

Deno.test("a storage failure aborts before any row is deleted", async () => {
  const store = new FakeStore([1, 2].map(post), true);
  await assertRejects(() => purgeExpiredPosts(store), Error, "storage down");
  assertEquals(store.calls, ["list:200", "remove:2"]);
});

class FakeQueueStore implements QueueStore {
  removed: Array<[string, string[]]> = [];
  deleted: number[] = [];
  constructor(public rows: QueuedObject[]) {}
  listQueued(limit: number): Promise<QueuedObject[]> {
    return Promise.resolve(this.rows.slice(0, limit));
  }
  removeFromBucket(bucket: string, paths: string[]): Promise<void> {
    this.removed.push([bucket, paths]);
    return Promise.resolve();
  }
  deleteQueued(ids: number[]): Promise<void> {
    this.deleted.push(...ids);
    this.rows = this.rows.filter((r) => !ids.includes(r.id));
    return Promise.resolve();
  }
}

Deno.test("queue: one storage call per bucket, duplicates collapsed", () => {
  const groups = groupByBucket([
    { id: 1, bucket: "gift-media", path: "a/1.jpg" },
    { id: 2, bucket: "gift-media", path: "a/1.jpg" },
    { id: 3, bucket: "posts", path: "b/2.jpg" },
  ]);
  assertEquals([...groups.entries()], [
    ["gift-media", ["a/1.jpg"]],
    ["posts", ["b/2.jpg"]],
  ]);
});

Deno.test("queue: objects removed before rows, rows gone after", async () => {
  const store = new FakeQueueStore([
    { id: 1, bucket: "gift-media", path: "a/1.jpg" },
    { id: 2, bucket: "gift-media", path: "a/2.jpg" },
  ]);
  const result = await drainPurgeQueue(store);
  assertEquals(store.removed, [["gift-media", ["a/1.jpg", "a/2.jpg"]]]);
  assertEquals(store.deleted, [1, 2]);
  assertEquals(result.objectsRemoved, 2);
  assertEquals(result.rowsDeleted, 2);
  assertEquals(store.rows.length, 0);
});

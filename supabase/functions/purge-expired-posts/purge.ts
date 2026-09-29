// Purge logic for expired ephemeral posts (G-203), kept free of Supabase
// types so it unit-tests with a fake store.
//
// Invariant: media is removed BEFORE its row. A failed storage call aborts
// the run with the rows intact, so the next hourly tick retries the same
// batch — an orphaned object can never outlive its row unnoticed, and a row
// never outlives its object. RLS (`expires_at > now()`) already hides expired
// posts from users; this job only reclaims storage and table space.

export interface ExpiredPost {
  id: string;
  media_path: string;
}

export interface PurgeStore {
  /** Oldest-expired first, at most `limit` rows. */
  listExpired(limit: number): Promise<ExpiredPost[]>;
  /** Removes objects from the posts bucket; must throw on failure. */
  removeObjects(paths: string[]): Promise<void>;
  /** Deletes the given post rows; must throw on failure. */
  deleteRows(ids: string[]): Promise<void>;
}

export interface PurgeOptions {
  /** Rows per storage call — the Storage API caps bulk removes. */
  batchSize?: number;
  /** Upper bound per invocation so one tick can't run unbounded. */
  maxBatches?: number;
}

export interface PurgeResult {
  objectsRemoved: number;
  rowsDeleted: number;
  batches: number;
  /** false when maxBatches was hit with more work left (next tick continues). */
  exhausted: boolean;
}

export async function purgeExpiredPosts(
  store: PurgeStore,
  { batchSize = 200, maxBatches = 5 }: PurgeOptions = {},
): Promise<PurgeResult> {
  const result: PurgeResult = {
    objectsRemoved: 0,
    rowsDeleted: 0,
    batches: 0,
    exhausted: true,
  };

  while (result.batches < maxBatches) {
    const expired = await store.listExpired(batchSize);
    if (expired.length === 0) return result;
    result.batches += 1;

    const paths = [...new Set(expired.map((p) => p.media_path))];
    await store.removeObjects(paths);
    result.objectsRemoved += paths.length;

    await store.deleteRows(expired.map((p) => p.id));
    result.rowsDeleted += expired.length;

    if (expired.length < batchSize) return result;
  }

  result.exhausted = false;
  return result;
}

// ── Storage purge queue ──────────────────────────────────────────────────────
// Rows that lost their object owner (a gift photo row deleted by cascade,
// a released claim's gift, a deleted event's group gift) are queued by a DB
// trigger; this drains the queue bucket by bucket. Removing an object that
// is already gone is a no-op for the Storage API, so the client's
// best-effort deletes and the queue converge.

export interface QueuedObject {
  id: number;
  bucket: string;
  path: string;
}

export interface QueueStore {
  /** Oldest first, at most `limit` rows. */
  listQueued(limit: number): Promise<QueuedObject[]>;
  /** Removes objects from one bucket; must throw on failure. */
  removeFromBucket(bucket: string, paths: string[]): Promise<void>;
  /** Deletes the given queue rows; must throw on failure. */
  deleteQueued(ids: number[]): Promise<void>;
}

/** One storage call per bucket, paths de-duplicated. */
export function groupByBucket(rows: QueuedObject[]): Map<string, string[]> {
  const groups = new Map<string, Set<string>>();
  for (const r of rows) {
    if (!groups.has(r.bucket)) groups.set(r.bucket, new Set());
    groups.get(r.bucket)!.add(r.path);
  }
  return new Map([...groups].map(([b, s]) => [b, [...s]]));
}

export async function drainPurgeQueue(
  store: QueueStore,
  { batchSize = 200, maxBatches = 5 }: PurgeOptions = {},
): Promise<PurgeResult> {
  const result: PurgeResult = {
    objectsRemoved: 0,
    rowsDeleted: 0,
    batches: 0,
    exhausted: true,
  };
  while (result.batches < maxBatches) {
    const queued = await store.listQueued(batchSize);
    if (queued.length === 0) return result;
    result.batches += 1;
    for (const [bucket, paths] of groupByBucket(queued)) {
      await store.removeFromBucket(bucket, paths);
      result.objectsRemoved += paths.length;
    }
    await store.deleteQueued(queued.map((q) => q.id));
    result.rowsDeleted += queued.length;
    if (queued.length < batchSize) return result;
  }
  result.exhausted = false;
  return result;
}

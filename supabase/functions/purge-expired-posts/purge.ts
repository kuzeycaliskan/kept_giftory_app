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

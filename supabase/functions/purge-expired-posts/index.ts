// G-203 — Reclaim storage + rows of expired ephemeral posts.
// Runs hourly via pg_cron → pg_net → this function (same wiring as
// birthday-reminders). RLS already hides expired posts; this only cleans up.
//
// Auth: X-Cron-Secret header must equal CRON_SECRET. `?dry=1` reports how
// many rows are due without touching anything.

import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";
import {
  drainPurgeQueue,
  type ExpiredPost,
  purgeExpiredPosts,
  type PurgeStore,
  type QueuedObject,
  type QueueStore,
} from "./purge.ts";

const BUCKET = "posts";

class SupabasePurgeStore implements PurgeStore {
  constructor(private readonly admin: SupabaseClient) {}

  async listExpired(limit: number): Promise<ExpiredPost[]> {
    const { data, error } = await this.admin
      .from("posts")
      .select("id, media_path")
      .lte("expires_at", new Date().toISOString())
      .order("expires_at", { ascending: true })
      .limit(limit);
    if (error) throw new Error(`list expired: ${error.message}`);
    return data ?? [];
  }

  async removeObjects(paths: string[]): Promise<void> {
    // Missing objects are not an error for the Storage API — a retried batch
    // after a partial failure converges instead of wedging.
    const { error } = await this.admin.storage.from(BUCKET).remove(paths);
    if (error) throw new Error(`remove objects: ${error.message}`);
  }

  async deleteRows(ids: string[]): Promise<void> {
    const { error } = await this.admin.from("posts").delete().in("id", ids);
    if (error) throw new Error(`delete rows: ${error.message}`);
  }
}

class SupabaseQueueStore implements QueueStore {
  constructor(private readonly admin: SupabaseClient) {}

  async listQueued(limit: number): Promise<QueuedObject[]> {
    const { data, error } = await this.admin
      .from("storage_purge_queue")
      .select("id, bucket, path")
      .order("id", { ascending: true })
      .limit(limit);
    if (error) throw new Error(`list queue: ${error.message}`);
    return data ?? [];
  }

  async removeFromBucket(bucket: string, paths: string[]): Promise<void> {
    const { error } = await this.admin.storage.from(bucket).remove(paths);
    if (error) throw new Error(`remove ${bucket}: ${error.message}`);
  }

  async deleteQueued(ids: number[]): Promise<void> {
    const { error } = await this.admin
      .from("storage_purge_queue")
      .delete()
      .in("id", ids);
    if (error) throw new Error(`delete queue rows: ${error.message}`);
  }
}

Deno.serve(async (req) => {
  if (req.headers.get("x-cron-secret") !== Deno.env.get("CRON_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }
  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const store = new SupabasePurgeStore(admin);

  if (new URL(req.url).searchParams.get("dry") === "1") {
    const { count, error } = await admin
      .from("posts")
      .select("id", { count: "exact", head: true })
      .lte("expires_at", new Date().toISOString());
    if (error) return new Response(error.message, { status: 500 });
    return Response.json({ dry: true, due: count ?? 0 });
  }

  try {
    const result = await purgeExpiredPosts(store);
    console.log("purge-expired-posts", JSON.stringify(result));
    // Same tick also drains the storage purge queue (gift photos whose
    // rows went with a gift, a claim release or an event deletion).
    const queue = await drainPurgeQueue(new SupabaseQueueStore(admin));
    console.log("storage-purge-queue", JSON.stringify(queue));
    // The in-app inbox keeps 60 days.
    const cutoff = new Date(Date.now() - 60 * 24 * 3600_000).toISOString();
    const { error: inboxError } = await admin
      .from("notifications")
      .delete()
      .lt("created_at", cutoff);
    if (inboxError) console.error("inbox purge", inboxError.message);
    return Response.json({ posts: result, queue });
  } catch (e) {
    // Rows stay put on failure; the next tick retries the same batch.
    console.error("purge-expired-posts failed", e);
    return new Response(String(e), { status: 500 });
  }
});

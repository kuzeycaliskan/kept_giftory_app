// In-app inbox: every push the server sends is also written to
// public.notifications so the bell shows it whether or not a device took
// the push. One row per (user, copy, route); duplicates in one batch
// collapse.

import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

export interface Notice {
  user_id: string;
  kind: string;
  title: string;
  body: string;
  route: string | null;
}

export function dedupeNotices(rows: Notice[]): Notice[] {
  const seen = new Set<string>();
  const out: Notice[] = [];
  for (const r of rows) {
    const key = `${r.user_id}|${r.title}|${r.body}|${r.route ?? ""}`;
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(r);
  }
  return out;
}

export async function recordNotices(
  supabase: SupabaseClient,
  rows: Notice[],
): Promise<number> {
  const unique = dedupeNotices(rows);
  if (unique.length === 0) return 0;
  const { error } = await supabase.from("notifications").insert(unique);
  if (error) {
    // The push already went (or will); the inbox is best-effort.
    console.error("recordNotices", error.message);
    return 0;
  }
  return unique.length;
}

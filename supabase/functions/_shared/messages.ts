// Push copy (Turkish-first product; the app itself is TR/EN but pushes
// follow the market language for now). Pure so it unit-tests.

const MAX_SNIPPET = 60;

function clip(text: string, max = MAX_SNIPPET): string {
  const t = text.trim().replaceAll(/\s+/g, " ");
  return t.length <= max ? t : `${t.slice(0, max - 1)}…`;
}

export function commentPush(
  commenter: string,
  itemLabel: string,
  snippet: string,
  kind: "gift" | "post" | "event",
): { title: string; body: string } {
  if (kind === "event") {
    // itemLabel = the honoree's name.
    return {
      title: `${commenter} · ${clip(itemLabel, 30)} event'i`,
      body: clip(snippet),
    };
  }
  const where = kind === "gift"
    ? (itemLabel ? clip(itemLabel, 40) : "hediye")
    : "anına";
  return {
    title: kind === "gift"
      ? `${commenter} · ${where}`
      : `${commenter} ${where} yorum yaptı`,
    body: clip(snippet),
  };
}

export function surprisePush(
  giver: string | null,
  itemLabel: string,
): { title: string; body: string } {
  return {
    title: "Sürprizin açıldı 🎁",
    body: giver
      ? `${giver} sana ${clip(itemLabel, 40)} hediye etmiş.`
      : `Sana bir hediye kaydedilmiş: ${clip(itemLabel, 40)}`,
  };
}

export function giftLoggedPush(
  giver: string,
  itemLabel: string,
): { title: string; body: string } {
  return {
    title: "Sana bir hediye kaydedildi 🎁",
    body: `${giver}: ${clip(itemLabel, 60)}`,
  };
}

/// G-307 — the reveal moment, sent once per event to the honoree.
export function eventRevealPush(
  memberCount: number,
): { title: string; body: string } {
  return {
    title: "Arkadaşların senin için bir araya geldi 🎁",
    body: memberCount > 1
      ? `${memberCount} arkadaşın hediyeni birlikte hazırladı. Kimler vardı, gör.`
      : "Bir arkadaşın senin için hediye hazırladı. Gör.",
  };
}

/// G-307 — the honoree's thank-you, sent to every joined member.
export function eventThanksPush(
  honoree: string,
  note: string,
): { title: string; body: string } {
  return {
    title: `${honoree} teşekkür etti 💐`,
    body: clip(note, 90),
  };
}

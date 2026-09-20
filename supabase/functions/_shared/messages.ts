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

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

/// The organizer deleted an open event; under-funded group-gift records
/// went with it.
export function eventDeletedPush(
  honoree: string | null,
  removedGifts: number,
): { title: string; body: string } {
  const who = honoree ? `${honoree} için açılan event` : "Hediye event'i";
  return {
    title: `${who} silindi`,
    body: removedGifts > 0
      ? "Tamamlanmamış ortak hediye kaydı da kaldırıldı; rezervasyonlar duruyor."
      : "Kaydedilen hediyeler ve rezervasyonlar duruyor.",
  };
}

/// A group gift did not reach its price within its day and was removed.
export function poolExpiredPush(
  itemTitle: string | null,
  count: number,
): { title: string; body: string } {
  return {
    title: "Ortak hediye kapandı ⏳",
    body: count > 1
      ? `${count} havuz 24 saatte fiyata ulaşmadı; katkılar düştü.`
      : `${
        itemTitle ? clip(itemTitle, 40) : "Havuz"
      } 24 saatte fiyata ulaşmadı; katkılar düştü.`,
  };
}

/// Two hours before a pool's day runs out, to its organizer.
export function poolReminderPush(
  itemTitle: string | null,
  total: number,
  target: number,
): { title: string; body: string } {
  const fmt = (n: number) =>
    new Intl.NumberFormat("tr-TR", {
      style: "currency",
      currency: "TRY",
      maximumFractionDigits: 0,
    }).format(n);
  return {
    title: "Ortak hediyede 2 saat kaldı ⏳",
    body: `${itemTitle ? clip(itemTitle, 40) : "Havuz"}: ${fmt(total)} / ${
      fmt(target)
    }. Tamamla ya da hediyeyi kaydet.`,
  };
}

/// The wishlist owner removed the item a pool was built on.
export function poolRemovedPush(
  itemTitle: string | null,
): { title: string; body: string } {
  return {
    title: "Ortak hediye kapandı",
    body: `${
      itemTitle ? clip(itemTitle, 40) : "Ürün"
    } istek listesinden kaldırıldı; katkılar düştü.`,
  };
}

/// The organizer closed the pool without a gift.
export function poolReleasedPush(
  actor: string | null,
  itemTitle: string | null,
): { title: string; body: string } {
  return {
    title: "Ortak hediye kapatıldı",
    body: `${actor ?? "Organizatör"} ${
      itemTitle ? clip(itemTitle, 40) + " için" : ""
    } havuzu dağıttı; katkın düştü.`
      .replace("  ", " "),
  };
}

/// The organizer logged the group gift; the pledgers are co-givers now.
export function poolLoggedPush(
  actor: string | null,
  itemTitle: string | null,
): { title: string; body: string } {
  return {
    title: "Ortak hediye kaydedildi 🎁",
    body: `${actor ?? "Organizatör"} ${
      itemTitle ? clip(itemTitle, 40) : "hediyeyi"
    } kaydetti; sen de verenler arasındasın.`,
  };
}

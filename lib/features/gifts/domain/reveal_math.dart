import 'package:kept/features/home/domain/birthday_math.dart';

/// Default reveal moment for a surprise gift (G-51 decision): the recipient's
/// next birthday + 1 day. Without a known birthday, fall back to 30 days out
/// so a surprise can never stay hidden forever.
DateTime defaultRevealAt(DateTime? recipientBirthday, DateTime now) {
  if (recipientBirthday == null) return now.add(const Duration(days: 30));
  return nextBirthday(recipientBirthday, now).add(const Duration(days: 1));
}

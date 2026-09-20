import 'package:intl/intl.dart';

/// Turkish lira only for now (first market); the symbol is fixed so the
/// number reads the same in both app languages.
String formatTry(String locale, double amount) {
  final whole = amount == amount.roundToDouble();
  return NumberFormat.currency(
    locale: locale,
    symbol: '₺',
    decimalDigits: whole ? 0 : 2,
  ).format(amount);
}

/// Accepts "1200", "1.200", "1200,50", "1.200,50" and "1200.50"; null when
/// not a positive amount.
double? parseAmount(String raw) {
  var text = raw.trim().replaceAll(' ', '').replaceAll('₺', '');
  if (text.isEmpty) return null;
  final comma = text.lastIndexOf(',');
  final dot = text.lastIndexOf('.');
  if (comma >= 0 && dot >= 0) {
    // Whichever comes last is the decimal separator.
    text = comma > dot
        ? text.replaceAll('.', '').replaceAll(',', '.')
        : text.replaceAll(',', '');
  } else if (comma >= 0) {
    text = text.replaceAll(',', '.');
  } else if (dot >= 0 && text.length - dot - 1 == 3) {
    // "1.200" is a thousands separator in Turkish habit.
    text = text.replaceAll('.', '');
  }
  final value = double.tryParse(text);
  if (value == null || value <= 0 || !value.isFinite) return null;
  return (value * 100).roundToDouble() / 100;
}

/// Formats a number as Indian rupees, e.g. 1250 -> "₹1,250".
///
/// Written by hand so the app does not need an extra number-formatting package.
/// Indian grouping puts the last 3 digits together, then groups of 2
/// (for example 1234567 becomes 12,34,567).
String formatRupees(num value) {
  final int rounded = value.round();
  final String digits = rounded.abs().toString();
  final String sign = rounded < 0 ? '-' : '';

  if (digits.length <= 3) return '$sign₹$digits';

  final String last3 = digits.substring(digits.length - 3);
  String remaining = digits.substring(0, digits.length - 3);

  final List<String> groups = <String>[];
  while (remaining.length > 2) {
    groups.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) groups.insert(0, remaining);

  return '$sign₹${groups.join(',')},$last3';
}

/// 28 -> "28 mins"
String formatMinutes(int minutes) => '$minutes mins';

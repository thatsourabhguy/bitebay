import 'package:flutter/foundation.dart';

/// A promotional card in the Home screen carousel.
@immutable
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Fake coupon code, e.g. "BITE50".
  final String code;
  final String imageUrl;
}

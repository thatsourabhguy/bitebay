import 'package:flutter/foundation.dart';

/// The kinds of payment shown at checkout. These are display-only in this
/// build — no real payment is ever processed.
enum PaymentType { upi, card, netBanking, wallet, cashOnDelivery }

@immutable
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final String id;
  final PaymentType type;
  final String title;
  final String subtitle;

  /// Optional tag such as "FASTEST".
  final String? badge;
}

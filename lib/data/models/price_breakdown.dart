import 'package:flutter/foundation.dart';

/// The bill: every line the user sees on the Cart and Checkout screens.
///
/// All of these are calculated from the cart, never hard-coded, so the
/// numbers always agree with what is actually in the cart.
@immutable
class PriceBreakdown {
  const PriceBreakdown({
    required this.itemTotal,
    required this.deliveryFee,
    required this.platformFee,
    required this.taxesAndCharges,
    required this.discount,
  });

  final int itemTotal;
  final int deliveryFee;
  final int platformFee;
  final int taxesAndCharges;
  final int discount;

  /// What the user actually pays.
  int get grandTotal =>
      itemTotal + deliveryFee + platformFee + taxesAndCharges - discount;

  bool get hasFreeDelivery => deliveryFee == 0;

  static const PriceBreakdown empty = PriceBreakdown(
    itemTotal: 0,
    deliveryFee: 0,
    platformFee: 0,
    taxesAndCharges: 0,
    discount: 0,
  );
}

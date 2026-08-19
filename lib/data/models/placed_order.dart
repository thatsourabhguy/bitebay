import 'package:flutter/foundation.dart';
import 'cart_item.dart';
import 'price_breakdown.dart';
import 'delivery_address.dart';

/// A fake order that has been "placed". Kept in memory only — nothing is
/// sent anywhere, because there is no backend in this version.
@immutable
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.items,
    required this.breakdown,
    required this.address,
    required this.paymentLabel,
    required this.restaurantName,
    required this.placedAt,
    required this.etaMinutes,
  });

  final String id;
  final List<CartItem> items;
  final PriceBreakdown breakdown;
  final DeliveryAddress address;
  final String paymentLabel;
  final String restaurantName;
  final DateTime placedAt;
  final int etaMinutes;

  int get totalDishes =>
      items.fold(0, (int sum, CartItem item) => sum + item.quantity);
}

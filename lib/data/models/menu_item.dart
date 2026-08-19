import 'package:flutter/foundation.dart';

/// One dish on a restaurant's menu.
@immutable
class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.section,
    required this.isVeg,
    this.rating,
    this.ratingCount,
    this.isBestseller = false,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;

  /// Price in rupees.
  final int price;

  final String imageUrl;

  /// Menu heading this dish sits under, e.g. "Starters".
  final String section;

  final bool isVeg;
  final double? rating;
  final int? ratingCount;
  final bool isBestseller;
}

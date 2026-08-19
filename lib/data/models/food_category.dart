import 'package:flutter/foundation.dart';

/// A food category shown in the circular strip on the Home screen,
/// e.g. "Biryani", "Pizza", "South Indian".
@immutable
class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;
}

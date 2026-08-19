import 'package:flutter/foundation.dart';

/// A single restaurant.
///
/// Everything the UI needs to draw a restaurant card or the details header
/// lives on this one object.
@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.cuisines,
    required this.rating,
    required this.ratingCount,
    required this.deliveryMinutes,
    required this.distanceKm,
    required this.costForTwo,
    required this.area,
    required this.categoryIds,
    this.offerText,
    this.isPureVeg = false,
    this.isPromoted = false,
  });

  final String id;
  final String name;
  final String imageUrl;

  /// e.g. ["North Indian", "Biryani"]
  final List<String> cuisines;

  final double rating;
  final int ratingCount;
  final int deliveryMinutes;
  final double distanceKm;

  /// Approximate cost for two people, in rupees.
  final int costForTwo;

  /// Neighbourhood shown under the name, e.g. "Koramangala".
  final String area;

  /// Which Home-screen categories this restaurant belongs to.
  final List<String> categoryIds;

  /// e.g. "50% OFF up to ₹100". Null when there is no running offer.
  final String? offerText;

  final bool isPureVeg;
  final bool isPromoted;

  /// "North Indian, Biryani"
  String get cuisineLabel => cuisines.join(', ');
}

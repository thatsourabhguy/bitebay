import '../models/delivery_address.dart';
import '../models/food_category.dart';
import '../models/menu_item.dart';
import '../models/payment_method.dart';
import '../models/promo_banner.dart';
import '../models/restaurant.dart';
import '../sources/fake_data.dart';
import '../sources/fake_menus.dart';
import 'restaurant_repository.dart';

/// Reads everything from the local sample data in `lib/data/sources/`.
///
/// A tiny artificial delay is added so the screens behave the way they
/// will once a real server is answering — loading spinners and all.
class FakeRestaurantRepository implements RestaurantRepository {
  const FakeRestaurantRepository();

  static const Duration _latency = Duration(milliseconds: 220);

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(_latency, () => value);

  @override
  Future<List<FoodCategory>> getCategories() => _delayed(FakeData.categories);

  @override
  Future<List<PromoBanner>> getBanners() => _delayed(FakeData.banners);

  @override
  Future<List<Restaurant>> getRestaurants({
    String query = '',
    String? categoryId,
    RestaurantSort sort = RestaurantSort.relevance,
    Set<RestaurantFilter> filters = const <RestaurantFilter>{},
  }) {
    Iterable<Restaurant> result = FakeData.restaurants;

    // Text search across name and cuisines.
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((Restaurant r) {
        final bool inName = r.name.toLowerCase().contains(trimmed);
        final bool inCuisine = r.cuisines.any(
          (String c) => c.toLowerCase().contains(trimmed),
        );
        final bool inArea = r.area.toLowerCase().contains(trimmed);
        return inName || inCuisine || inArea;
      });
    }

    if (categoryId != null) {
      result = result.where((Restaurant r) => r.categoryIds.contains(categoryId));
    }

    for (final RestaurantFilter filter in filters) {
      switch (filter) {
        case RestaurantFilter.pureVeg:
          result = result.where((Restaurant r) => r.isPureVeg);
        case RestaurantFilter.ratingFourPlus:
          result = result.where((Restaurant r) => r.rating >= 4.0);
        case RestaurantFilter.fastDelivery:
          result = result.where((Restaurant r) => r.deliveryMinutes <= 30);
        case RestaurantFilter.offers:
          result = result.where((Restaurant r) => r.offerText != null);
      }
    }

    final List<Restaurant> sorted = result.toList();
    switch (sort) {
      case RestaurantSort.relevance:
        // Promoted restaurants first, then the best rated.
        sorted.sort((Restaurant a, Restaurant b) {
          if (a.isPromoted != b.isPromoted) return a.isPromoted ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
      case RestaurantSort.ratingHighToLow:
        sorted.sort((Restaurant a, Restaurant b) => b.rating.compareTo(a.rating));
      case RestaurantSort.deliveryTime:
        sorted.sort(
          (Restaurant a, Restaurant b) =>
              a.deliveryMinutes.compareTo(b.deliveryMinutes),
        );
      case RestaurantSort.costLowToHigh:
        sorted.sort(
          (Restaurant a, Restaurant b) => a.costForTwo.compareTo(b.costForTwo),
        );
      case RestaurantSort.costHighToLow:
        sorted.sort(
          (Restaurant a, Restaurant b) => b.costForTwo.compareTo(a.costForTwo),
        );
    }

    return _delayed(sorted);
  }

  @override
  Future<Restaurant?> getRestaurantById(String id) {
    Restaurant? found;
    for (final Restaurant r in FakeData.restaurants) {
      if (r.id == id) {
        found = r;
        break;
      }
    }
    return _delayed(found);
  }

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) =>
      _delayed(FakeMenus.byRestaurant[restaurantId] ?? const <MenuItem>[]);

  @override
  Future<List<DeliveryAddress>> getAddresses() => _delayed(FakeData.addresses);

  @override
  Future<List<PaymentMethod>> getPaymentMethods() =>
      _delayed(FakeData.paymentMethods);
}

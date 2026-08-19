import '../models/delivery_address.dart';
import '../models/food_category.dart';
import '../models/menu_item.dart';
import '../models/payment_method.dart';
import '../models/promo_banner.dart';
import '../models/restaurant.dart';

/// How the restaurant list can be ordered.
enum RestaurantSort {
  relevance('Relevance'),
  ratingHighToLow('Rating: High to Low'),
  deliveryTime('Delivery Time'),
  costLowToHigh('Cost: Low to High'),
  costHighToLow('Cost: High to Low');

  const RestaurantSort(this.label);
  final String label;
}

/// Quick filters shown as chips above the restaurant list.
enum RestaurantFilter {
  pureVeg('Pure Veg'),
  ratingFourPlus('Rating 4.0+'),
  fastDelivery('Fast Delivery'),
  offers('Great Offers');

  const RestaurantFilter(this.label);
  final String label;
}

/// The contract every data source must satisfy.
///
/// Today the only implementation reads from local fake data. When a real
/// server is added later, a new class implements this same interface and
/// the screens keep working untouched — that is why this file exists.
abstract class RestaurantRepository {
  Future<List<FoodCategory>> getCategories();

  Future<List<PromoBanner>> getBanners();

  Future<List<Restaurant>> getRestaurants({
    String query = '',
    String? categoryId,
    RestaurantSort sort = RestaurantSort.relevance,
    Set<RestaurantFilter> filters = const <RestaurantFilter>{},
  });

  Future<Restaurant?> getRestaurantById(String id);

  Future<List<MenuItem>> getMenu(String restaurantId);

  Future<List<DeliveryAddress>> getAddresses();

  Future<List<PaymentMethod>> getPaymentMethods();
}

import 'package:flutter/material.dart';

import '../../data/models/placed_order.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/restaurant_details/restaurant_details_screen.dart';
import '../../features/restaurants/restaurant_list_screen.dart';
import '../../features/shell/main_shell.dart';

/// Every screen name in one place, so a typo becomes a compile error
/// instead of a crash at runtime.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String restaurants = '/restaurants';
  static const String restaurantDetails = '/restaurant';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
}

/// Extra information handed to the Restaurant List screen when it opens.
@immutable
class RestaurantListArgs {
  const RestaurantListArgs({this.categoryId, this.categoryName, this.query = ''});

  final String? categoryId;
  final String? categoryName;
  final String query;
}

/// Builds the right screen for a route name.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _page(const MainShell(), settings);

      case AppRoutes.restaurants:
        final Object? args = settings.arguments;
        return _page(
          RestaurantListScreen(
            args: args is RestaurantListArgs ? args : const RestaurantListArgs(),
            showBackButton: true,
          ),
          settings,
        );

      case AppRoutes.restaurantDetails:
        final Object? args = settings.arguments;
        if (args is! String) return _missing(settings);
        return _page(RestaurantDetailsScreen(restaurantId: args), settings);

      case AppRoutes.cart:
        return _page(const CartScreen(showBackButton: true), settings);

      case AppRoutes.checkout:
        return _page(const CheckoutScreen(), settings);

      case AppRoutes.orderSuccess:
        final Object? args = settings.arguments;
        if (args is! PlacedOrder) return _missing(settings);
        return _page(OrderSuccessScreen(order: args), settings);

      default:
        return _missing(settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute<dynamic>(builder: (_) => child, settings: settings);

  static MaterialPageRoute<dynamic> _missing(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('No screen matches "${settings.name}".')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/fake_restaurant_repository.dart';
import 'data/repositories/restaurant_repository.dart';
import 'state/cart_controller.dart';
import 'state/navigation_controller.dart';

void main() {
  runApp(const BiteBayApp());
}

/// The root of the app.
///
/// Everything the whole app needs to share — the cart, the selected tab and
/// the data source — is created once here and handed down to every screen.
class BiteBayApp extends StatelessWidget {
  const BiteBayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Swap this one line for a real API client later and every screen
        // keeps working unchanged.
        Provider<RestaurantRepository>(
          create: (_) => const FakeRestaurantRepository(),
        ),
        ChangeNotifierProvider<CartController>(
          create: (_) => CartController(),
        ),
        ChangeNotifierProvider<NavigationController>(
          create: (_) => NavigationController(),
        ),
      ],
      child: MaterialApp(
        title: 'BiteBay',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}

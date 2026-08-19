// Tests for the BiteBay demo app.
//
// These check the two things most likely to break: the cart maths, and the
// screens actually opening and reacting to taps.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bitebay/core/router/app_router.dart';
import 'package:bitebay/core/utils/formatters.dart';
import 'package:bitebay/data/models/menu_item.dart';
import 'package:bitebay/data/models/restaurant.dart';
import 'package:bitebay/data/repositories/fake_restaurant_repository.dart';
import 'package:bitebay/data/repositories/restaurant_repository.dart';
import 'package:bitebay/data/sources/fake_data.dart';
import 'package:bitebay/data/sources/fake_menus.dart';
import 'package:bitebay/features/restaurant_details/restaurant_details_screen.dart';
import 'package:bitebay/main.dart';
import 'package:bitebay/state/cart_controller.dart';
import 'package:bitebay/state/navigation_controller.dart';

Restaurant get _restaurant => FakeData.restaurants.first;
List<MenuItem> get _menu => FakeMenus.byRestaurant[_restaurant.id]!;

void main() {
  group('CartController', () {
    test('starts empty', () {
      final CartController cart = CartController();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalQuantity, 0);
      expect(cart.grandTotal, 0);
    });

    test('adding the same dish twice increases its quantity', () {
      final CartController cart = CartController();
      cart.addItem(_menu[0], _restaurant);
      cart.addItem(_menu[0], _restaurant);

      expect(cart.items.length, 1);
      expect(cart.quantityOf(_menu[0].id), 2);
      expect(cart.totalQuantity, 2);
      expect(cart.itemTotal, _menu[0].price * 2);
    });

    test('decrementing to zero drops the line and empties the cart', () {
      final CartController cart = CartController();
      cart.addItem(_menu[0], _restaurant);
      cart.decrementItem(_menu[0].id);

      expect(cart.isEmpty, isTrue);
      expect(cart.restaurant, isNull);
    });

    test('removeItem deletes the whole line regardless of quantity', () {
      final CartController cart = CartController();
      cart.addItem(_menu[0], _restaurant);
      cart.addItem(_menu[0], _restaurant);
      cart.addItem(_menu[1], _restaurant);

      cart.removeItem(_menu[0].id);

      expect(cart.items.length, 1);
      expect(cart.quantityOf(_menu[0].id), 0);
    });

    test('the bill adds up: items + fees + tax - discount', () {
      final CartController cart = CartController();
      cart.addItem(_menu[0], _restaurant); // 289

      final int expected =
          cart.itemTotal +
          cart.deliveryFee +
          cart.platformFee +
          cart.taxesAndCharges -
          cart.discount;

      expect(cart.grandTotal, expected);
      expect(cart.breakdown.grandTotal, expected);
    });

    test('delivery becomes free once the order passes the threshold', () {
      final CartController cart = CartController();
      // Add enough of the first dish to cross 499.
      while (cart.itemTotal < 499) {
        cart.addItem(_menu[0], _restaurant);
      }
      expect(cart.deliveryFee, 0);
      expect(cart.amountToFreeDelivery, 0);
    });

    test('BITE50 gives half off, capped at 100', () {
      final CartController cart = CartController();
      cart.addItem(_menu[0], _restaurant); // 289, above the 199 minimum

      final CouponResult result = cart.applyCoupon('bite50');

      expect(result.success, isTrue);
      expect(cart.appliedCoupon, 'BITE50');
      expect(cart.discount, 100); // 50% of 289 = 144, capped at 100
    });

    test('a coupon below its minimum order is rejected', () {
      final CartController cart = CartController();
      cart.addItem(_menu[7], _restaurant); // 59, below every minimum

      final CouponResult result = cart.applyCoupon('FEAST125');

      expect(result.success, isFalse);
      expect(cart.appliedCoupon, isNull);
      expect(cart.discount, 0);
    });

    test('an unknown coupon is rejected', () {
      final CartController cart = CartController();
      cart.addItem(_menu[0], _restaurant);

      expect(cart.applyCoupon('NOPE').success, isFalse);
    });

    test('switching restaurants needs an explicit replace', () {
      final CartController cart = CartController();
      final Restaurant other = FakeData.restaurants[1];
      final MenuItem otherDish = FakeMenus.byRestaurant[other.id]!.first;

      cart.addItem(_menu[0], _restaurant);
      expect(cart.wouldReplaceCart(other), isTrue);

      // Without permission, nothing changes.
      cart.addItem(otherDish, other);
      expect(cart.restaurant!.id, _restaurant.id);

      // With permission, the cart is swapped.
      cart.addItem(otherDish, other, replaceCart: true);
      expect(cart.restaurant!.id, other.id);
      expect(cart.items.length, 1);
    });
  });

  group('Screens', () {
    /// The default test window is only 800x600, which is shorter than these
    /// screens. Giving the test a tall window means everything is laid out
    /// and can be found without scrolling first.
    void useTallWindow(WidgetTester tester, {double height = 3000}) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(1000, height);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('the app boots and Home shows restaurants', (
      WidgetTester tester,
    ) async {
      useTallWindow(tester);

      await tester.pumpWidget(const BiteBayApp());
      await tester.pumpAndSettle();

      expect(find.text("What's on your mind?"), findsOneWidget);
      expect(find.text('Top picks for you'), findsOneWidget);
      // At least one real restaurant name made it onto the screen.
      expect(find.text('Idli Express'), findsWidgets);
    });

    testWidgets('adding a dish from the menu updates the cart', (
      WidgetTester tester,
    ) async {
      useTallWindow(tester, height: 2400);
      final CartController cart = CartController();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RestaurantRepository>(
              create: (_) => const FakeRestaurantRepository(),
            ),
            ChangeNotifierProvider<CartController>.value(value: cart),
          ],
          child: MaterialApp(
            home: RestaurantDetailsScreen(restaurantId: _restaurant.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(cart.isEmpty, isTrue);

      // Tap the first ADD button on the menu.
      await tester.tap(find.text('ADD').first);
      await tester.pumpAndSettle();

      expect(cart.totalQuantity, 1);
      expect(cart.restaurant!.id, _restaurant.id);

      // The ADD button has now become a quantity stepper showing "1".
      expect(find.text('1'), findsWidgets);

      // Increase, then decrease back to nothing.
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      expect(cart.totalQuantity, 2);

      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.pumpAndSettle();
      expect(cart.isEmpty, isTrue);
    });

    testWidgets('full flow: menu -> cart -> checkout -> order placed', (
      WidgetTester tester,
    ) async {
      useTallWindow(tester, height: 2400);
      final CartController cart = CartController();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<RestaurantRepository>(
              create: (_) => const FakeRestaurantRepository(),
            ),
            ChangeNotifierProvider<CartController>.value(value: cart),
            ChangeNotifierProvider<NavigationController>(
              create: (_) => NavigationController(),
            ),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: RestaurantDetailsScreen(restaurantId: _restaurant.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Add two different dishes from the menu.
      await tester.tap(find.text('ADD').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD').first);
      await tester.pumpAndSettle();
      expect(cart.items.length, 2);

      final int expectedTotal = cart.grandTotal;

      // 2. The cart bar appeared — follow it to the Cart screen.
      expect(find.text('View Cart'), findsOneWidget);
      await tester.tap(find.text('View Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Your cart'), findsOneWidget);
      expect(find.text('Bill details'), findsOneWidget);
      expect(find.text('To pay'), findsOneWidget);

      // 3. Remove one line with the bin icon.
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
      expect(cart.items.length, 1);
      expect(cart.grandTotal, lessThan(expectedTotal));

      // 4. Continue to Checkout.
      await tester.tap(find.text('Proceed to Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Delivery address'), findsOneWidget);
      expect(find.text('Payment method'), findsOneWidget);
      // Checkout shows the same total the cart calculated.
      expect(find.text(formatRupees(cart.grandTotal)), findsWidgets);

      // 5. Choose Cash on Delivery, then place the order.
      await tester.tap(find.text('Cash on Delivery'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      // 6. We land on the confirmation screen and the cart is emptied.
      expect(find.text('Order placed!'), findsOneWidget);
      expect(find.textContaining('Arriving in'), findsOneWidget);
      expect(find.textContaining('Paid via Cash on Delivery'), findsOneWidget);
      expect(cart.isEmpty, isTrue);
    });
  });
}

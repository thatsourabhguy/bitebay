import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/cart_controller.dart';
import '../../state/navigation_controller.dart';
import '../../widgets/cart_bar.dart';
import '../account/account_screen.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import '../restaurants/restaurant_list_screen.dart';

/// The frame that holds the four main tabs and the bottom navigation bar.
///
/// `IndexedStack` keeps every tab alive, so switching tabs does not lose
/// your scroll position or reload the data.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController nav = context.watch<NavigationController>();
    final CartController cart = context.watch<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: nav.index,
        children: const <Widget>[
          HomeScreen(),
          RestaurantListScreen(args: RestaurantListArgs()),
          CartScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The cart bar hides on the Cart tab itself — you are already there.
          if (nav.index != NavigationController.cartTab)
            CartBar(
              onTap: () =>
                  context.read<NavigationController>().goToTab(
                    NavigationController.cartTab,
                  ),
            ),
          _BottomBar(
            index: nav.index,
            cartCount: cart.totalQuantity,
            onChanged: (int i) =>
                context.read<NavigationController>().goToTab(i),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.cartCount,
    required this.onChanged,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: BottomNavigationBar(
        currentIndex: index,
        onTap: onChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.textTertiary,
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.saved_search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: _CartIcon(count: cartCount, active: false),
            activeIcon: _CartIcon(count: cartCount, active: true),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

/// Cart icon with the little orange count bubble.
class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, required this.active});

  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(
          active
              ? Icons.shopping_cart_rounded
              : Icons.shopping_cart_outlined,
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

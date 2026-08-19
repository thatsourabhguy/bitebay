import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cart_item.dart';
import '../../state/cart_controller.dart';
import '../../state/navigation_controller.dart';
import '../../widgets/bill_details_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/food_image.dart';
import 'widgets/coupon_field.dart';

/// Everything the user has chosen, with quantity controls, a coupon box,
/// the full bill and the button through to Checkout.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final CartController cart = context.watch<CartController>();
    final double sidePad = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        title: const Text('Your cart'),
        actions: <Widget>[
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('Clear'),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  'Add dishes from a restaurant and they will show up here.',
              actionLabel: 'Browse restaurants',
              onAction: () {
                if (showBackButton) {
                  Navigator.of(context).pop();
                } else {
                  context.read<NavigationController>().goToTab(
                    NavigationController.searchTab,
                  );
                }
              },
            )
          : ResponsiveCenter(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  sidePad,
                  AppSpacing.lg,
                  sidePad,
                  AppSpacing.xxxl,
                ),
                children: <Widget>[
                  _RestaurantStrip(name: cart.restaurant?.name ?? ''),
                  const SizedBox(height: AppSpacing.md),
                  _ItemsCard(items: cart.items),
                  const SizedBox(height: AppSpacing.md),
                  if (cart.amountToFreeDelivery > 0) ...<Widget>[
                    _FreeDeliveryNudge(amount: cart.amountToFreeDelivery),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  const CouponField(),
                  const SizedBox(height: AppSpacing.md),
                  BillDetailsCard(
                    breakdown: cart.breakdown,
                    appliedCoupon: cart.appliedCoupon,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _CheckoutBar(
              total: cart.grandTotal,
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.checkout),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final CartController cart = context.read<CartController>();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Empty your cart?'),
        content: const Text('This removes every dish you have added.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Empty cart'),
          ),
        ],
      ),
    );
    if (confirmed == true) cart.clear();
  }
}

/// Shows which restaurant the cart belongs to.
class _RestaurantStrip extends StatelessWidget {
  const _RestaurantStrip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.storefront_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

/// The white card listing every dish in the cart.
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            _CartLine(item: items[i]),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final CartController cart = context.read<CartController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: <Widget>[
          FoodImage(
            photoId: item.menuItem.imageUrl,
            width: 52,
            height: 52,
            targetWidth: 160,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    VegIndicator(isVeg: item.menuItem.isVeg, size: 12),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.menuItem.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  formatRupees(item.menuItem.price),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              QuantitySelector(
                quantity: item.quantity,
                width: 92,
                height: 32,
                onAdd: () => cart.addItem(
                  item.menuItem,
                  cart.restaurant!,
                  replaceCart: true,
                ),
                onRemove: () => cart.decrementItem(item.menuItem.id),
              ),
              const SizedBox(height: 4),
              Text(
                formatRupees(item.lineTotal),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontSize: 13.5),
              ),
            ],
          ),
          // The bin icon removes the whole line at once.
          IconButton(
            tooltip: 'Remove ${item.menuItem.name}',
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: () {
              cart.removeItem(item.menuItem.id);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('${item.menuItem.name} removed'),
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
          ),
        ],
      ),
    );
  }
}

/// "Add ₹120 more for free delivery".
class _FreeDeliveryNudge extends StatelessWidget {
  const _FreeDeliveryNudge({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EE),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.veg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.delivery_dining_rounded,
            color: AppColors.veg,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Add ${formatRupees(amount)} more to get free delivery',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10693F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The sticky bar at the bottom with the total and the checkout button.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onTap});

  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  formatRupees(total),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Total amount',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: ElevatedButton(
                onPressed: onTap,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Proceed to Checkout'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

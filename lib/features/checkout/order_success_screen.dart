import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/placed_order.dart';
import '../../state/navigation_controller.dart';

/// Confirmation screen shown after the fake order is placed.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final PlacedOrder order;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Clears the whole navigation history and lands back on the Home tab.
  void _backToHome() {
    context.read<NavigationController>().goToTab(NavigationController.homeTab);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final PlacedOrder order = widget.order;
    final double sidePad = Responsive.pagePadding(context);

    return PopScope(
      // Going "back" from here should return Home, not to Checkout.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _backToHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceAlt,
        body: SafeArea(
          child: ResponsiveCenter(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                sidePad,
                AppSpacing.xxxl,
                sidePad,
                AppSpacing.xxxl,
              ),
              children: <Widget>[
                // ------------------------------------------- success mark
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: Curves.elasticOut,
                  ),
                  child: Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.veg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Order placed!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your food from ${order.restaurantName} is being prepared.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ----------------------------------------- arrival estimate
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.brandSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Arriving in ${formatMinutes(order.etaMinutes)}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Order #${order.id}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // --------------------------------------------- the details
                _DetailCard(
                  title: 'Delivering to',
                  children: <Widget>[
                    Text(
                      order.address.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.address.fullAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailCard(
                  title: '${order.totalDishes} items ordered',
                  children: <Widget>[
                    for (final CartItem line in order.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${line.menuItem.name} x${line.quantity}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              formatRupees(line.lineTotal),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Paid via ${order.paymentLabel}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          formatRupees(order.breakdown.grandTotal),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    if (order.paymentId != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Payment reference: ${order.paymentId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton(
                  onPressed: _backToHome,
                  child: const Text('Back to Home'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    order.paymentId == null
                        ? 'This is a demo order. No payment was taken and no '
                              'restaurant was contacted.'
                        : 'Test payment only — no real money moved, and no '
                              'restaurant was contacted.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

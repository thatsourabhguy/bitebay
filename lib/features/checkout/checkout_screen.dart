import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/delivery_address.dart';
import '../../data/models/payment_method.dart';
import '../../data/models/placed_order.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../payments/payment_service.dart';
import '../../payments/razorpay_config.dart';
import '../../state/cart_controller.dart';
import '../../widgets/bill_details_card.dart';
import '../../widgets/common_widgets.dart';
import 'widgets/address_card.dart';
import 'widgets/payment_option_tile.dart';

/// The last step: confirm the address, review the order, pick a (pretend)
/// payment method and place the order.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  /// Addresses and payment options come from the repository, exactly like
  /// restaurants do, so a real backend can supply them later.
  List<DeliveryAddress> _addresses = const <DeliveryAddress>[];
  List<PaymentMethod> _payments = const <PaymentMethod>[];

  DeliveryAddress? _address;
  PaymentMethod? _payment;
  bool _loadingOptions = true;

  /// True from the moment "Place Order" is tapped until we have navigated
  /// away. It stops the screen redrawing itself with an emptied cart.
  bool _placingOrder = false;

  /// Opens the Razorpay payment window. Created once per visit to this screen.
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = createPaymentService();
    _loadOptions();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final RestaurantRepository repo = context.read<RestaurantRepository>();
    final List<DeliveryAddress> addresses = await repo.getAddresses();
    final List<PaymentMethod> payments = await repo.getPaymentMethods();
    if (!mounted) return;

    setState(() {
      _addresses = addresses;
      _payments = payments;
      _address = addresses.isEmpty ? null : addresses.first;
      _payment = payments.isEmpty ? null : payments.first;
      _loadingOptions = false;
    });
  }

  Future<void> _placeOrder() async {
    final CartController cart = context.read<CartController>();
    final DeliveryAddress? address = _address;
    final PaymentMethod? payment = _payment;
    if (cart.isEmpty || address == null || payment == null) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String restaurantName = cart.restaurant?.name ?? 'BiteBay Kitchen';
    final int amountToCollect = cart.grandTotal;

    setState(() => _placingOrder = true);

    String? paymentId;

    if (payment.type == PaymentType.cashOnDelivery) {
      // Nothing to collect now — the delivery partner takes the money.
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } else {
      final PaymentOutcome outcome = await _paymentService.payForOrder(
        amountInRupees: amountToCollect,
        description: 'Order from $restaurantName',
      );
      if (!mounted) return;

      switch (outcome) {
        case PaymentSucceeded(paymentId: final String id):
          paymentId = id;

        case PaymentSkipped():
          // No Razorpay key set up yet, so fall back to the demo behaviour.
          await Future<void>.delayed(const Duration(milliseconds: 700));

        case PaymentCancelled():
          setState(() => _placingOrder = false);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Payment cancelled. Your cart is safe.')),
            );
          return;

        case PaymentFailed(message: final String message):
          setState(() => _placingOrder = false);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          return;
      }
    }

    if (!mounted) return;

    final PlacedOrder order = PlacedOrder(
      id: 'BB${DateTime.now().millisecondsSinceEpoch.remainder(100000000)}',
      items: cart.items,
      breakdown: cart.breakdown,
      address: address,
      paymentLabel: payment.title,
      restaurantName: restaurantName,
      placedAt: DateTime.now(),
      etaMinutes: (cart.restaurant?.deliveryMinutes ?? 30) + 5,
      paymentId: paymentId,
    );

    // Move to the confirmation screen, then empty the cart.
    //
    // Note: the Future returned by pushReplacementNamed only completes when
    // the *new* screen is later popped, so it must not be awaited here —
    // awaiting it would leave the cart full after the order was placed.
    // The `_placingOrder` flag above keeps this screen from redrawing itself
    // as "empty" during the transition.
    unawaited(
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.orderSuccess, arguments: order),
    );
    cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    final CartController cart = context.watch<CartController>();
    final double sidePad = Responsive.pagePadding(context);

    // Someone emptied the cart from another screen.
    if (cart.isEmpty && !_placingOrder) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'Your cart is empty',
          message: 'Add a few dishes before checking out.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    if (_loadingOptions) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(title: const Text('Checkout')),
      body: AbsorbPointer(
        absorbing: _placingOrder,
        child: ResponsiveCenter(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              sidePad,
              AppSpacing.lg,
              sidePad,
              AppSpacing.xxxl,
            ),
            children: <Widget>[
              // ------------------------------------------- delivery address
              _SectionTitle(
                icon: Icons.location_on_rounded,
                title: 'Delivery address',
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final DeliveryAddress address in _addresses)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AddressCard(
                    address: address,
                    selected: address.id == _address?.id,
                    onTap: () => setState(() => _address = address),
                  ),
                ),

              // --------------------------------------------- order summary
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                icon: Icons.receipt_long_rounded,
                title: 'Order summary',
              ),
              const SizedBox(height: AppSpacing.sm),
              _OrderSummaryCard(
                restaurantName: cart.restaurant?.name ?? '',
                items: cart.items,
              ),

              // ------------------------------------------- payment methods
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                icon: Icons.credit_card_rounded,
                title: 'Payment method',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                RazorpayConfig.isConfigured
                    ? (RazorpayConfig.isTestKey
                          ? 'Razorpay TEST MODE — use a test card, no real money moves.'
                          : 'Payments are processed by Razorpay.')
                    : 'Demo only — no real payment is taken.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < _payments.length; i++)
                      PaymentOptionTile(
                        method: _payments[i],
                        selected: _payments[i].id == _payment?.id,
                        showDivider: i < _payments.length - 1,
                        onTap: () => setState(() => _payment = _payments[i]),
                      ),
                  ],
                ),
              ),

              // ---------------------------------------------------- the bill
              const SizedBox(height: AppSpacing.lg),
              BillDetailsCard(
                breakdown: cart.breakdown,
                appliedCoupon: cart.appliedCoupon,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PlaceOrderBar(
        total: cart.grandTotal,
        paymentLabel: _payment?.title ?? '',
        busy: _placingOrder,
        onTap: _placeOrder,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.brand),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

/// A compact list of what is being ordered.
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.restaurantName, required this.items});

  final String restaurantName;
  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (restaurantName.isNotEmpty) ...<Widget>[
            Text(
              restaurantName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final CartItem line in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: <Widget>[
                  VegIndicator(isVeg: line.menuItem.isVeg, size: 12),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      line.menuItem.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    ' x${line.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    formatRupees(line.lineTotal),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar holding the total and the Place Order button.
class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.total,
    required this.paymentLabel,
    required this.busy,
    required this.onTap,
  });

  final int total;
  final String paymentLabel;
  final bool busy;
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
                SizedBox(
                  width: 96,
                  child: Text(
                    paymentLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: ElevatedButton(
                onPressed: busy ? null : onTap,
                child: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

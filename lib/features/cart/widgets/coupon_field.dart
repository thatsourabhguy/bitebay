import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../state/cart_controller.dart';

/// Lets the user type one of the sample coupon codes (BITE50, FEAST125,
/// FREEDEL) and see the discount applied to the bill immediately.
class CouponField extends StatefulWidget {
  const CouponField({super.key});

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final CouponResult result = context.read<CartController>().applyCoupon(
      _controller.text,
    );
    setState(() => _error = result.success ? null : result.message);

    if (result.success) {
      _controller.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cart = context.watch<CartController>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: cart.appliedCoupon != null
          ? _AppliedCoupon(
              code: cart.appliedCoupon!,
              onRemove: () {
                context.read<CartController>().removeCoupon();
                setState(() => _error = null);
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.confirmation_num_outlined,
                      size: 18,
                      color: AppColors.brand,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Apply a coupon',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Try BITE50, FEAST125 or FREEDEL',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: (_) => _apply(),
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          errorText: _error,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _apply,
                      child: const Text('APPLY'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _AppliedCoupon extends StatelessWidget {
  const _AppliedCoupon({required this.code, required this.onRemove});

  final String code;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.verified_rounded, color: AppColors.veg, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '"$code" applied',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Savings are shown in the bill below',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        TextButton(onPressed: onRemove, child: const Text('REMOVE')),
      ],
    );
  }
}

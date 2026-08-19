import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/formatters.dart';
import '../data/models/price_breakdown.dart';
import 'common_widgets.dart';

/// The itemised bill. Used on both the Cart and the Checkout screen so the
/// numbers can never disagree between them.
class BillDetailsCard extends StatelessWidget {
  const BillDetailsCard({
    super.key,
    required this.breakdown,
    this.appliedCoupon,
    this.title = 'Bill details',
  });

  final PriceBreakdown breakdown;
  final String? appliedCoupon;
  final String title;

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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _BillRow(label: 'Item total', value: breakdown.itemTotal),
          _BillRow(
            label: 'Delivery fee',
            value: breakdown.deliveryFee,
            strikethroughWhenFree: true,
          ),
          _BillRow(label: 'Platform fee', value: breakdown.platformFee),
          _BillRow(label: 'GST and charges', value: breakdown.taxesAndCharges),
          if (breakdown.discount > 0)
            _BillRow(
              label: appliedCoupon == null
                  ? 'Discount'
                  : 'Discount ($appliedCoupon)',
              value: -breakdown.discount,
              highlight: true,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: DottedDivider(),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'To pay',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                formatRupees(breakdown.grandTotal),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.strikethroughWhenFree = false,
  });

  final String label;
  final int value;
  final bool highlight;

  /// When the delivery fee is waived, show "FREE" in green.
  final bool strikethroughWhenFree;

  @override
  Widget build(BuildContext context) {
    final bool isFree = strikethroughWhenFree && value == 0;
    final Color valueColor = highlight || isFree
        ? AppColors.veg
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            isFree ? 'FREE' : formatRupees(value),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isFree || highlight
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

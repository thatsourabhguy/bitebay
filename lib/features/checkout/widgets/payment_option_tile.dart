import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/payment_method.dart';
import '../../../widgets/common_widgets.dart';

/// One selectable payment row. These are for show only — nothing is charged.
class PaymentOptionTile extends StatelessWidget {
  const PaymentOptionTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
    this.showDivider = true,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  IconData get _icon {
    switch (method.type) {
      case PaymentType.upi:
        return Icons.account_balance_wallet_rounded;
      case PaymentType.card:
        return Icons.credit_card_rounded;
      case PaymentType.netBanking:
        return Icons.account_balance_rounded;
      case PaymentType.wallet:
        return Icons.wallet_rounded;
      case PaymentType.cashOnDelivery:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.brandSoft
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _icon,
                    size: 19,
                    color: selected
                        ? AppColors.brand
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              method.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (method.badge != null) ...<Widget>[
                            const SizedBox(width: AppSpacing.sm),
                            InfoPill(
                              label: method.badge!,
                              color: AppColors.veg,
                              background: const Color(0xFFE9F7EE),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        method.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? AppColors.brand : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 66),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}

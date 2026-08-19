import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/food_image.dart';

/// One dish row on the restaurant menu: details on the left, photo and the
/// ADD / quantity control on the right.
class MenuItemTile extends StatelessWidget {
  const MenuItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ------------------------------------------------ text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    VegIndicator(isVeg: item.isVeg),
                    if (item.isBestseller) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      const InfoPill(
                        label: 'Bestseller',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.warning,
                        background: Color(0xFFFFF6E5),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupees(item.price),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.rating != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      RatingBadge(rating: item.rating!, compact: true),
                      const SizedBox(width: 6),
                      Text(
                        '(${item.ratingCount ?? 0})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // --------------------------------------- photo + add control
          SizedBox(
            width: 118,
            child: Column(
              children: <Widget>[
                FoodImage(
                  photoId: item.imageUrl,
                  width: 118,
                  height: 108,
                  targetWidth: 300,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                // Pulled up so the button overlaps the photo, the way food
                // apps usually present it.
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: QuantitySelector(
                    quantity: quantity,
                    onAdd: onAdd,
                    onRemove: onRemove,
                    width: 96,
                    height: 36,
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

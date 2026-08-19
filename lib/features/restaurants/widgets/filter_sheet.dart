import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/restaurant_repository.dart';

/// The pop-up sheet that lets you choose how the restaurant list is ordered.
///
/// It returns the chosen option to whoever opened it, or null if the user
/// dismissed it without picking.
class SortSheet extends StatelessWidget {
  const SortSheet({super.key, required this.current});

  final RestaurantSort current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // RadioGroup keeps the selection for all the radio tiles beneath it.
      child: RadioGroup<RestaurantSort>(
        groupValue: current,
        onChanged: (RestaurantSort? value) => Navigator.of(context).pop(value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final RestaurantSort option in RestaurantSort.values)
              RadioListTile<RestaurantSort>(
                value: option,
                activeColor: AppColors.brand,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: option == current
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

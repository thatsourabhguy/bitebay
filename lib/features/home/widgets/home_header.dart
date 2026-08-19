import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// The top of the Home screen: delivery location, profile bubble and the
/// tappable search box.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onSearchTap,
    required this.sidePadding,
  });

  final VoidCallback onSearchTap;
  final double sidePadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sidePadding,
        AppSpacing.md,
        sidePadding,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.brand,
                size: 26,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Home',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 17),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                    Text(
                      'Koramangala 4th Block, Bengaluru',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Looks like a search field, but tapping it jumps to the Search tab.
          Material(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textTertiary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Search for restaurants, cuisines or dishes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Container(width: 1, height: 20, color: AppColors.divider),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.brand,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

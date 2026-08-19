import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/formatters.dart';
import '../data/models/restaurant.dart';
import 'common_widgets.dart';
import 'food_image.dart';

/// The wide restaurant card used on the Restaurant List screen and in the
/// "All restaurants" section of Home.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    FoodImage(
                      photoId: restaurant.imageUrl,
                      width: 104,
                      height: 104,
                      targetWidth: 300,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    if (restaurant.offerText != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(AppRadius.md),
                              bottomRight: Radius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            restaurant.offerText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              restaurant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (restaurant.isPureVeg) ...<Widget>[
                            const SizedBox(width: 6),
                            const VegIndicator(isVeg: true, size: 13),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          RatingBadge(rating: restaurant.rating, compact: true),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${formatMinutes(restaurant.deliveryMinutes)} · ${formatRupees(restaurant.costForTwo)} for two',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.cuisineLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${restaurant.area} · ${restaurant.distanceKm} km',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (restaurant.isPromoted) ...<Widget>[
                        const SizedBox(height: 8),
                        const InfoPill(
                          label: 'PROMOTED',
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ],
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

/// The narrower, image-on-top card used in the horizontal carousel on Home.
class RestaurantCardCompact extends StatelessWidget {
  const RestaurantCardCompact({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.width = 200,
  });

  final Restaurant restaurant;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                FoodImage(
                  photoId: restaurant.imageUrl,
                  width: width,
                  height: 132,
                  targetWidth: 400,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                if (restaurant.offerText != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppRadius.lg),
                          bottomRight: Radius.circular(AppRadius.lg),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.78),
                          ],
                        ),
                      ),
                      child: Text(
                        restaurant.offerText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              restaurant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                RatingBadge(rating: restaurant.rating, compact: true),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    formatMinutes(restaurant.deliveryMinutes),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              restaurant.cuisineLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

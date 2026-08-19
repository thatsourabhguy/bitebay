import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/food_category.dart';
import '../../../widgets/food_image.dart';

/// The scrolling row of round category pictures ("Biryani", "Pizza"...).
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.onTap,
    required this.sidePadding,
  });

  final List<FoodCategory> categories;
  final void Function(FoodCategory category) onTap;
  final double sidePadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(
          sidePadding,
          AppSpacing.md,
          sidePadding,
          0,
        ),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (BuildContext context, int i) {
          final FoodCategory category = categories[i];
          return SizedBox(
            width: 76,
            child: InkWell(
              onTap: () => onTap(category),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Column(
                children: <Widget>[
                  FoodImage(
                    photoId: category.imageUrl,
                    width: 68,
                    height: 68,
                    targetWidth: 200,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    category.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

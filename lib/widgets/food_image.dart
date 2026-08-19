import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/sources/app_images.dart';

/// Shows a food photograph, with sensible behaviour when things go wrong.
///
/// While the photo downloads you see a soft grey block; if the device is
/// offline you see a tinted placeholder with a food icon instead of a broken
/// image. That way the app still looks finished with no internet.
class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.photoId,
    this.width,
    this.height,
    this.targetWidth = 600,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  /// The photo identifier from [AppImages].
  final String photoId;

  final double? width;
  final double? height;

  /// How wide the downloaded file should be. Smaller cards ask for smaller
  /// files, which keeps the app fast on slow connections.
  final int targetWidth;

  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.network(
      AppImages.photo(photoId, width: targetWidth),
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            return _Placeholder(
              photoId: photoId,
              width: width,
              height: height,
              showIcon: false,
            );
          },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return _Placeholder(photoId: photoId, width: width, height: height);
      },
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

/// A tinted block used while loading and when the photo cannot be fetched.
class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.photoId,
    this.width,
    this.height,
    this.showIcon = true,
  });

  final String photoId;
  final double? width;
  final double? height;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    // Derive a stable colour from the id so the same dish always gets the
    // same tint instead of flickering between colours.
    final int seed = photoId.codeUnits.fold(0, (int a, int b) => a + b);
    final List<Color> palette = <Color>[
      const Color(0xFFFFE3D3),
      const Color(0xFFFFF0D6),
      const Color(0xFFE4F1E6),
      const Color(0xFFE7EAF6),
      const Color(0xFFF7E4EE),
    ];
    final Color tint = palette[seed % palette.length];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[tint, Color.lerp(tint, Colors.white, 0.55)!],
        ),
      ),
      alignment: Alignment.center,
      child: showIcon
          ? Icon(
              Icons.restaurant_menu_rounded,
              size: 26,
              color: AppColors.brand.withValues(alpha: 0.45),
            )
          : null,
    );
  }
}

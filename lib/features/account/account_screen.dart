import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../data/sources/fake_data.dart';

/// A simple profile tab.
///
/// Sign-in, order history and saved addresses are deliberately left as
/// placeholders — they need a backend, which this version does not have.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double sidePad = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account')),
      body: ResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            sidePad,
            AppSpacing.lg,
            sidePad,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
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
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sample User',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        FakeData.addresses.first.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            _Tile(
              icon: Icons.receipt_long_rounded,
              title: 'Your orders',
              subtitle: 'Needs a backend — coming later',
            ),
            _Tile(
              icon: Icons.location_on_outlined,
              title: 'Saved addresses',
              subtitle: '${FakeData.addresses.length} sample addresses',
            ),
            _Tile(
              icon: Icons.favorite_border_rounded,
              title: 'Favourites',
              subtitle: 'Needs a backend — coming later',
            ),
            _Tile(
              icon: Icons.help_outline_rounded,
              title: 'Help and support',
              subtitle: 'Needs a backend — coming later',
            ),

            const SizedBox(height: AppSpacing.xxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'About this build',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'BiteBay demo v1.0 — every restaurant, dish, price and '
                    'payment option here is sample data stored inside the app. '
                    'There is no sign-in, no server and no real payment.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('This needs a backend, which comes later.'),
          ),
        ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/menu_item.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../state/cart_controller.dart';
import '../../widgets/cart_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/food_image.dart';
import 'widgets/menu_item_tile.dart';

/// A single restaurant: photo header, key information and the full menu
/// with add-to-cart controls.
class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  late Future<_DetailsData?> _future;

  /// Only show vegetarian dishes when this is on.
  bool _vegOnly = false;

  /// One key per menu section so the section chips can scroll to them.
  final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DetailsData?> _load() async {
    final RestaurantRepository repo = context.read<RestaurantRepository>();
    final Restaurant? restaurant = await repo.getRestaurantById(
      widget.restaurantId,
    );
    if (restaurant == null) return null;

    final List<MenuItem> menu = await repo.getMenu(widget.restaurantId);
    return _DetailsData(restaurant: restaurant, menu: menu);
  }

  /// Adds a dish, asking first if the cart belongs to another restaurant.
  Future<void> _addItem(MenuItem item, Restaurant restaurant) async {
    final CartController cart = context.read<CartController>();

    if (cart.wouldReplaceCart(restaurant)) {
      final bool? replace = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Start a new cart?'),
          content: Text(
            'Your cart has items from ${cart.restaurant!.name}. '
            'Adding this dish will empty it and start a fresh cart from '
            '${restaurant.name}.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep old cart'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Start new cart'),
            ),
          ],
        ),
      );
      if (replace != true) return;
      if (!mounted) return;
    }

    cart.addItem(item, restaurant, replaceCart: true);
  }

  void _scrollToSection(String section) {
    final BuildContext? target = _sectionKeys[section]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_DetailsData?>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<_DetailsData?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.storefront_outlined,
                title: 'Restaurant not found',
                message: 'This restaurant is no longer available.',
              ),
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
      bottomNavigationBar: CartBar(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.cart),
      ),
    );
  }

  Widget _buildContent(_DetailsData data) {
    final Restaurant restaurant = data.restaurant;
    final double sidePad = Responsive.pagePadding(context);
    final CartController cart = context.watch<CartController>();

    final List<MenuItem> visible = _vegOnly
        ? data.menu.where((MenuItem m) => m.isVeg).toList()
        : data.menu;

    // Menu sections in the order they appear on the menu.
    final List<String> sections = <String>[];
    for (final MenuItem item in visible) {
      if (!sections.contains(item.section)) sections.add(item.section);
    }
    for (final String s in sections) {
      _sectionKeys.putIfAbsent(s, () => GlobalKey());
    }

    return ResponsiveCenter(
      child: CustomScrollView(
        slivers: <Widget>[
          // ------------------------------------------------ photo header
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Text(restaurant.name),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  FoodImage(photoId: restaurant.imageUrl, targetWidth: 900),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------- information card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                sidePad,
                AppSpacing.lg,
                sidePad,
                AppSpacing.sm,
              ),
              child: _InfoCard(restaurant: restaurant),
            ),
          ),

          // ------------------------------------------------ veg-only switch
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                sidePad,
                AppSpacing.sm,
                sidePad,
                AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  const VegIndicator(isVeg: true, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Veg only',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: _vegOnly,
                    activeThumbColor: AppColors.veg,
                    onChanged: (bool value) => setState(() => _vegOnly = value),
                  ),
                ],
              ),
            ),
          ),

          // ---------------------------------------------- section shortcuts
          if (sections.length > 1)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: sidePad),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int i) => ActionChip(
                    label: Text(sections[i]),
                    onPressed: () => _scrollToSection(sections[i]),
                  ),
                ),
              ),
            ),

          // ---------------------------------------------------- the menu
          if (visible.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.no_food_outlined,
                title: 'No vegetarian dishes',
                message: 'Turn off "Veg only" to see the full menu.',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int i,
              ) {
                final MenuItem item = visible[i];
                final bool startsSection =
                    i == 0 || visible[i - 1].section != item.section;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (startsSection)
                        Padding(
                          key: _sectionKeys[item.section],
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xl,
                            bottom: AppSpacing.xs,
                          ),
                          child: Text(
                            item.section,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontSize: 19),
                          ),
                        ),
                      MenuItemTile(
                        item: item,
                        quantity: cart.quantityOf(item.id),
                        onAdd: () => _addItem(item, restaurant),
                        onRemove: () =>
                            context.read<CartController>().decrementItem(
                              item.id,
                            ),
                      ),
                      if (i < visible.length - 1 &&
                          visible[i + 1].section == item.section)
                        const Divider(height: 1),
                    ],
                  ),
                );
              }, childCount: visible.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _DetailsData {
  const _DetailsData({required this.restaurant, required this.menu});

  final Restaurant restaurant;
  final List<MenuItem> menu;
}

/// The bordered card under the photo holding rating, time and cost.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.restaurant});

  final Restaurant restaurant;

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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (restaurant.isPureVeg)
                const InfoPill(
                  label: 'PURE VEG',
                  color: AppColors.veg,
                  background: Color(0xFFE9F7EE),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            restaurant.cuisineLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${restaurant.area} · ${restaurant.distanceKm} km away',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              _Stat(
                value: restaurant.rating.toStringAsFixed(1),
                label: '${restaurant.ratingCount}+ ratings',
                icon: Icons.star_rounded,
                iconColor: AppColors.ratingGreen,
              ),
              _StatDivider(),
              _Stat(
                value: '${restaurant.deliveryMinutes}',
                label: 'minutes',
                icon: Icons.access_time_rounded,
              ),
              _StatDivider(),
              _Stat(
                value: formatRupees(restaurant.costForTwo),
                label: 'for two',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
          if (restaurant.offerText != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.brand.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.local_offer_rounded,
                    size: 18,
                    color: AppColors.brand,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      restaurant.offerText!,
                      style: const TextStyle(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor = AppColors.textSecondary,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: AppColors.divider);
}

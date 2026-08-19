import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/food_category.dart';
import '../../data/models/promo_banner.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../state/navigation_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/restaurant_card.dart';
import 'widgets/category_strip.dart';
import 'widgets/home_header.dart';
import 'widgets/promo_carousel.dart';

/// The first screen you see: location, search, categories, offers and
/// restaurant listings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Fetches everything Home needs in one go.
  Future<_HomeData> _load() async {
    final RestaurantRepository repo = context.read<RestaurantRepository>();
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      repo.getCategories(),
      repo.getBanners(),
      repo.getRestaurants(sort: RestaurantSort.relevance),
    ]);

    return _HomeData(
      categories: results[0] as List<FoodCategory>,
      banners: results[1] as List<PromoBanner>,
      restaurants: results[2] as List<Restaurant>,
    );
  }

  void _openRestaurant(String id) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.restaurantDetails, arguments: id);
  }

  void _openCategory(FoodCategory category) {
    Navigator.of(context).pushNamed(
      AppRoutes.restaurants,
      arguments: RestaurantListArgs(
        categoryId: category.id,
        categoryName: category.name,
      ),
    );
  }

  void _openSearch() =>
      context.read<NavigationController>().goToTab(NavigationController.searchTab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<_HomeData> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Could not load restaurants',
                message: 'Something went wrong while loading the sample data.',
                actionLabel: 'Try again',
                onAction: () => setState(() => _future = _load()),
              );
            }

            final _HomeData data = snapshot.data!;
            return _HomeContent(
              data: data,
              onOpenRestaurant: _openRestaurant,
              onOpenCategory: _openCategory,
              onOpenSearch: _openSearch,
            );
          },
        ),
      ),
    );
  }
}

/// Everything Home needs, loaded together.
class _HomeData {
  const _HomeData({
    required this.categories,
    required this.banners,
    required this.restaurants,
  });

  final List<FoodCategory> categories;
  final List<PromoBanner> banners;
  final List<Restaurant> restaurants;
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    required this.onOpenRestaurant,
    required this.onOpenCategory,
    required this.onOpenSearch,
  });

  final _HomeData data;
  final void Function(String restaurantId) onOpenRestaurant;
  final void Function(FoodCategory category) onOpenCategory;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final double sidePad = Responsive.pagePadding(context);

    // Top-rated restaurants get the "Top picks" carousel.
    final List<Restaurant> topPicks = List<Restaurant>.from(data.restaurants)
      ..sort((Restaurant a, Restaurant b) => b.rating.compareTo(a.rating));

    return ResponsiveCenter(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: HomeHeader(onSearchTap: onOpenSearch, sidePadding: sidePad),
          ),

          // ------------------------------------------------ categories
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(sidePad, AppSpacing.sm, sidePad, 0),
              child: Text(
                "What's on your mind?",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CategoryStrip(
              categories: data.categories,
              sidePadding: sidePad,
              onTap: onOpenCategory,
            ),
          ),

          // ---------------------------------------------------- offers
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(sidePad, AppSpacing.lg, sidePad, 0),
              child: Text(
                'Offers for you',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: PromoCarousel(
              banners: data.banners,
              sidePadding: sidePad,
            ),
          ),

          // ------------------------------------------------- top picks
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePad),
              child: SectionHeader(
                title: 'Top picks for you',
                actionLabel: 'See all',
                onAction: () => Navigator.of(context).pushNamed(
                  AppRoutes.restaurants,
                  arguments: const RestaurantListArgs(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpacing.xl,
                  0,
                  AppSpacing.md,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 232,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                itemCount: topPicks.length > 8 ? 8 : topPicks.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (BuildContext context, int i) {
                  final Restaurant r = topPicks[i];
                  return RestaurantCardCompact(
                    restaurant: r,
                    onTap: () => onOpenRestaurant(r.id),
                  );
                },
              ),
            ),
          ),

          // ------------------------------------------ all restaurants
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePad),
              child: SectionHeader(
                title: 'All restaurants nearby',
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpacing.xxl,
                  0,
                  AppSpacing.md,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, AppSpacing.xxxl),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                // A fixed height keeps every card aligned no matter how long
                // the restaurant name is.
                mainAxisExtent: 150,
              ),
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int i,
              ) {
                final Restaurant r = data.restaurants[i];
                return RestaurantCard(
                  restaurant: r,
                  onTap: () => onOpenRestaurant(r.id),
                );
              }, childCount: data.restaurants.length),
            ),
          ),
        ],
      ),
    );
  }
}

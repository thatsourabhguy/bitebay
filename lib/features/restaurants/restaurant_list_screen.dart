import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/restaurant.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/restaurant_card.dart';
import 'widgets/filter_sheet.dart';

/// Browse every restaurant, with search, quick filters and sorting.
///
/// The same screen is used twice: as the "Search" tab inside the bottom
/// navigation, and as a pushed page when you tap a category on Home.
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({
    super.key,
    required this.args,
    this.showBackButton = false,
  });

  final RestaurantListArgs args;
  final bool showBackButton;

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late final TextEditingController _searchController;

  RestaurantSort _sort = RestaurantSort.relevance;
  Set<RestaurantFilter> _filters = <RestaurantFilter>{};

  List<Restaurant> _results = <Restaurant>[];
  bool _loading = true;

  /// Guards against slow answers arriving after newer ones. Every search
  /// gets a number; only the newest number is allowed to update the screen.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.args.query);
    _search();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final int id = ++_requestId;
    setState(() => _loading = true);

    final List<Restaurant> found = await context
        .read<RestaurantRepository>()
        .getRestaurants(
          query: _searchController.text,
          categoryId: widget.args.categoryId,
          sort: _sort,
          filters: _filters,
        );

    if (!mounted || id != _requestId) return;
    setState(() {
      _results = found;
      _loading = false;
    });
  }

  void _toggleFilter(RestaurantFilter filter) {
    setState(() {
      _filters = <RestaurantFilter>{..._filters};
      if (!_filters.add(filter)) _filters.remove(filter);
    });
    _search();
  }

  Future<void> _openSortSheet() async {
    final RestaurantSort? picked = await showModalBottomSheet<RestaurantSort>(
      context: context,
      showDragHandle: true,
      builder: (_) => SortSheet(current: _sort),
    );
    if (picked == null || picked == _sort) return;
    setState(() => _sort = picked);
    _search();
  }

  void _clearAll() {
    _searchController.clear();
    setState(() {
      _filters = <RestaurantFilter>{};
      _sort = RestaurantSort.relevance;
    });
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final double sidePad = Responsive.pagePadding(context);
    final String title = widget.args.categoryName ?? 'All restaurants';
    final bool filtersActive =
        _filters.isNotEmpty || _sort != RestaurantSort.relevance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: Text(title),
        actions: <Widget>[
          if (filtersActive)
            TextButton(onPressed: _clearAll, child: const Text('Clear')),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ResponsiveCenter(
          child: Column(
            children: <Widget>[
              // ------------------------------------------------ search box
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sidePad,
                  AppSpacing.sm,
                  sidePad,
                  AppSpacing.md,
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Search restaurants, cuisines or areas',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textTertiary,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _search();
                            },
                          ),
                  ),
                ),
              ),

              // ------------------------------------------ filters and sort
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: sidePad),
                  children: <Widget>[
                    _SortChip(sort: _sort, onTap: _openSortSheet),
                    const SizedBox(width: AppSpacing.sm),
                    for (final RestaurantFilter f in RestaurantFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(f.label),
                          selected: _filters.contains(f),
                          onSelected: (_) => _toggleFilter(f),
                          showCheckmark: false,
                          selectedColor: AppColors.brandSoft,
                          side: BorderSide(
                            color: _filters.contains(f)
                                ? AppColors.brand
                                : AppColors.divider,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _filters.contains(f)
                                ? AppColors.brand
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ----------------------------------------------- result count
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sidePad,
                  AppSpacing.lg,
                  sidePad,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _loading
                        ? 'Finding restaurants...'
                        : '${_results.length} ${_results.length == 1 ? 'restaurant' : 'restaurants'} found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // --------------------------------------------------- results
              Expanded(child: _buildResults(sidePad)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(double sidePad) {
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No restaurants found',
        message:
            'Try a different search, or remove a filter to see more results.',
        actionLabel: 'Clear filters',
        onAction: _clearAll,
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, AppSpacing.xxxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: 150,
      ),
      itemCount: _results.length,
      itemBuilder: (BuildContext context, int i) {
        final Restaurant r = _results[i];
        return RestaurantCard(
          restaurant: r,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.restaurantDetails, arguments: r.id),
        );
      },
    );
  }
}

/// The "Sort" pill that opens the sort options sheet.
class _SortChip extends StatelessWidget {
  const _SortChip({required this.sort, required this.onTap});

  final RestaurantSort sort;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = sort != RestaurantSort.relevance;
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        Icons.swap_vert_rounded,
        size: 18,
        color: active ? AppColors.brand : AppColors.textPrimary,
      ),
      label: Text(active ? sort.label : 'Sort'),
      backgroundColor: active ? AppColors.brandSoft : Colors.white,
      side: BorderSide(color: active ? AppColors.brand : AppColors.divider),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: active ? AppColors.brand : AppColors.textPrimary,
      ),
    );
  }
}

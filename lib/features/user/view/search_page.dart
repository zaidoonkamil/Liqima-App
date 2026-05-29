import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/home_page_data.dart';
import '../data/meal_details_api_data.dart';
import '../data/search_page_data.dart';
import 'meal_details.dart';
import 'restaurant_details.dart';
import 'widgets/user_page_shimmers.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  Timer? debounce;
  bool loaded = false;
  bool initialLoadFinished = false;

  bool get hasSearch => searchController.text.trim().length >= 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      UserCubit.get(context).loadSearchInitialData();
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      UserCubit.get(
        context,
      ).runSearch(query: value, mode: UserCubit.get(context).searchMode);
    });
  }

  void _useQuery(String query) {
    searchController.text = query;
    searchController.selection = TextSelection.collapsed(offset: query.length);
    _onSearchChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<UserCubit, UserStates>(
            listener: (context, state) {
              if (state is UserSearchErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserSearchSuccessState) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final loading =
                  state is UserSearchLoadingState || !initialLoadFinished;
              final mode = cubit.searchMode;
              final meals = cubit.searchMeals;
              final restaurants = cubit.searchRestaurants;
              final resultCount =
                  mode == SearchMode.meals ? meals.length : restaurants.length;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const UserNavHeaderSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: _SearchPanel(
                      controller: searchController,
                      hasSearch: hasSearch,
                      selectedMode: mode,
                      suggestions: cubit.searchSuggestions,
                      recentSearches: cubit.searchHistory,
                      onChanged: _onSearchChanged,
                      onModeChanged: cubit.changeSearchMode,
                      onQueryTap: _useQuery,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (!hasSearch) ...[
                    const SliverToBoxAdapter(
                      child: _SectionTitle(title: 'اقتراحات البحث'),
                    ),
                    SliverToBoxAdapter(
                      child: _SuggestionChips(
                        suggestions: cubit.searchSuggestions,
                        onTap: _useQuery,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    const SliverToBoxAdapter(
                      child: _SectionTitle(title: 'عمليات البحث الأخيرة'),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 5)),
                    SliverToBoxAdapter(
                      child: _RecentSearches(
                        searches: cubit.searchHistory,
                        onTap: _useQuery,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SearchModeBar(
                          selectedMode: mode,
                          onChanged: cubit.changeSearchMode,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title:
                          hasSearch
                              ? 'نتائج البحث ($resultCount)'
                              : mode == SearchMode.meals
                              ? 'أشهر الوجبات'
                              : 'المطاعم القريبة منك',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  if (loading)
                    ListPageShimmerSlivers(twoColumns: mode == SearchMode.meals)
                  else if (mode == SearchMode.meals)
                    meals.isEmpty
                        ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptySearch(),
                        )
                        : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _MealResultCard(meal: meals[index]),
                              childCount: meals.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: .78,
                                ),
                          ),
                        )
                  else
                    restaurants.isEmpty
                        ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptySearch(),
                        )
                        : SliverList.separated(
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _RestaurantResultCard(
                                restaurant: restaurants[index],
                              ),
                            );
                          },
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemCount: restaurants.length,
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 88)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.hasSearch,
    required this.selectedMode,
    required this.suggestions,
    required this.recentSearches,
    required this.onChanged,
    required this.onModeChanged,
    required this.onQueryTap,
  });

  final TextEditingController controller;
  final bool hasSearch;
  final SearchMode selectedMode;
  final List<SearchSuggestionData> suggestions;
  final List<SearchHistoryData> recentSearches;
  final ValueChanged<String> onChanged;
  final ValueChanged<SearchMode> onModeChanged;
  final ValueChanged<String> onQueryTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: _softDecoration(radius: 22),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SizedBox(
              height: 20,
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                onFieldSubmitted:
                    (_) => UserCubit.get(context).saveCurrentSearch(),
                textInputAction: TextInputAction.search,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF151B18),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ابحث عن مطعم أو وجبة...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8C9492),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Transform.translate(
                    offset: const Offset(0, -5),
                    child: IconButton(
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child:
                            controller.text.isEmpty
                                ? const Icon(
                                  Iconsax.search_normal,
                                  key: ValueKey('search'),
                                  color: Color(0xFF77807F),
                                  size: 16,
                                )
                                : const Icon(
                                  Iconsax.close_circle,
                                  key: ValueKey('clear'),
                                  color: Color(0xFF77807F),
                                  size: 16,
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (hasSearch) ...[
              const SizedBox(height: 8),
              _SearchModeBar(
                selectedMode: selectedMode,
                onChanged: onModeChanged,
              ),
              if (recentSearches.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InlineRecentSearches(
                  searches: recentSearches,
                  onTap: onQueryTap,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF151B18),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.suggestions, required this.onTap});

  final List<SearchSuggestionData> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return InkWell(
            onTap: () => onTap(suggestion.title),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: _softDecoration(radius: 18),
              child: Row(
                children: [
                  _SuggestionIcon(imageUrl: suggestion.imageUrl),
                  const SizedBox(width: 5),
                  Text(
                    suggestion.title,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: suggestions.length,
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.searches, required this.onTap});

  final List<SearchHistoryData> searches;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'ماكو عمليات بحث أخيرة',
          style: TextStyle(
            color: Color(0xFF747D79),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final history = searches[index];
          return _HistoryChip(
            text: history.query,
            onTap: () => onTap(history.query),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemCount: searches.length,
      ),
    );
  }
}

class _InlineRecentSearches extends StatelessWidget {
  const _InlineRecentSearches({required this.searches, required this.onTap});

  final List<SearchHistoryData> searches;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final history = searches[index];
          return _HistoryChip(
            text: history.query,
            onTap: () => onTap(history.query),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemCount: searches.length,
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFF0F1EF)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.clock, color: Color(0xFF747D79), size: 13),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF555D59),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchModeBar extends StatelessWidget {
  const _SearchModeBar({required this.selectedMode, required this.onChanged});

  final SearchMode selectedMode;
  final ValueChanged<SearchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              title: 'الوجبات',
              icon: Iconsax.coffee,
              selected: selectedMode == SearchMode.meals,
              onTap: () => onChanged(SearchMode.meals),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ModeButton(
              title: 'المطاعم',
              icon: Iconsax.shop,
              selected: selectedMode == SearchMode.restaurants,
              onTap: () => onChanged(SearchMode.restaurants),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? primaryColor : const Color(0xFF555D59);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealResultCard extends StatelessWidget {
  const _MealResultCard({required this.meal});

  final MealCardData meal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => navigateTo(
            context,
            BlocProvider.value(
              value: UserCubit.get(context),
              child: MealDetailsPage(
                productId: meal.id,
                initialMeal: MealDetailsData.fromSeed(
                  id: meal.id,
                  name: meal.name,
                  imageUrl: meal.imageUrl,
                  price: meal.price,
                  rating: meal.rating,
                  isFavorite: meal.isFavorite,
                  deliveryTime: meal.time,
                  restaurantId: meal.restaurantId,
                  restaurantName: meal.restaurant,
                ),
              ),
            ),
          ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: _softDecoration(radius: 18),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  meal.imageUrl,
                  width: double.infinity,
                  height: 104,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 104,
                        color: const Color(0xFFF4F4F2),
                        child: const Icon(Iconsax.gallery, color: primaryColor),
                      ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: _CircleIcon(
                    icon: meal.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    color: meal.isFavorite ? secondaryColor : primaryColor,
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _MiniPill(text: meal.time, icon: Iconsax.timer),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meal.restaurant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8A8F8D),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.star,
                          color: Color(0xFFFFAA22),
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          meal.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF656B69),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'د.ع ${_formatPrice(meal.price)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const _AddButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantResultCard extends StatelessWidget {
  const _RestaurantResultCard({required this.restaurant});

  final RestaurantCardData restaurant;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () => navigateTo(
            context,
            BlocProvider.value(
              value: UserCubit.get(context),
              child: RestaurantDetailsPage(restaurantId: restaurant.id),
            ),
          ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 105,
        decoration: _softDecoration(radius: 18),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    restaurant.imageUrl,
                    width: 108,
                    height: 85,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 108,
                          height: 85,
                          color: const Color(0xFFF4F4F2),
                          child: const Icon(Iconsax.shop, color: primaryColor),
                        ),
                  ),
                ),
                Positioned(
                  right: -22,
                  top: 22,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF24342B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      restaurant.logoText,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8C9291),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Iconsax.star,
                        color: Color(0xFFFFA51E),
                        size: 12,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          restaurant.distance,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8C9291),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _MiniPill(text: restaurant.time, icon: Iconsax.timer),
          ],
        ),
      ),
    );
  }
}

class _SuggestionIcon extends StatelessWidget {
  const _SuggestionIcon({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return const Icon(Iconsax.category, color: primaryColor, size: 16);
    }
    return Image.network(
      imageUrl!,
      width: 18,
      height: 18,
      fit: BoxFit.contain,
      errorBuilder:
          (_, __, ___) =>
              const Icon(Iconsax.category, color: primaryColor, size: 16),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 15, color: color),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Icon(icon, color: primaryColor, size: 10),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.search_normal,
              color: primaryColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ماكو نتائج حالياً',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرّب كلمة ثانية أو غيّر نوع البحث',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF747D79),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

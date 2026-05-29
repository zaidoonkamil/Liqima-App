import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liqima/core/widgets/show_toast.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/user_nav_header.dart' show UserNavHeaderSliver;
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/favorites_page_data.dart';
import '../data/meal_details_api_data.dart';
import 'meal_details.dart';
import 'restaurant_details.dart';
import 'widgets/user_page_shimmers.dart';

enum _FavoriteTab { meals, restaurants }

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, this.active = true});

  final bool active;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  _FavoriteTab selectedTab = _FavoriteTab.meals;
  bool initialLoadFinished = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavoritesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _loadFavorites(refresh: true);
    }
  }

  void _loadFavorites({bool refresh = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) return;
      UserCubit.get(context).getFavoritesData(refresh: refresh);
    });
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
              if (state is UserFavoritesErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserFavoritesSuccessState) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final data = cubit.favoritesData;
              final loading =
                  data == null &&
                  (!initialLoadFinished || state is UserFavoritesLoadingState);
              final contentSlivers =
                  selectedTab == _FavoriteTab.meals
                      ? [
                        ..._mealSlivers(data?.meals ?? const []),
                        ..._restaurantSlivers(data?.restaurants ?? const []),
                      ]
                      : [
                        ..._restaurantSlivers(data?.restaurants ?? const []),
                        ..._mealSlivers(data?.meals ?? const []),
                      ];

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const UserNavHeaderSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _FavoriteTabs(
                      selectedTab: selectedTab,
                      mealsCount: data?.productsCount ?? 0,
                      restaurantsCount: data?.restaurantsCount ?? 0,
                      onChanged: (tab) {
                        setState(() => selectedTab = tab);
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  if (loading)
                    const FavoritesPageShimmerSlivers()
                  else if ((data?.meals.isEmpty ?? true) &&
                      (data?.restaurants.isEmpty ?? true))
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyFavorites(),
                    )
                  else ...[
                    ...contentSlivers,
                    const SliverToBoxAdapter(child: SizedBox(height: 104)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _mealSlivers(List<FavoriteMealData> meals) {
    return [
      const SliverToBoxAdapter(
        child: _SectionTitle(
          title: 'الأكلات المفضلة',
          icon: Iconsax.heart,
          color: secondaryColor,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 10)),
      if (meals.isEmpty)
        const SliverToBoxAdapter(
          child: _SectionEmpty(text: 'ماكو أكلات مفضلة حالياً'),
        )
      else
        SliverList.separated(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FavoriteMealCard(
                meal: meals[index],
                highlighted: index == 0,
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: meals.length,
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 18)),
    ];
  }

  List<Widget> _restaurantSlivers(List<FavoriteRestaurantData> restaurants) {
    return [
      const SliverToBoxAdapter(
        child: _SectionTitle(
          title: 'المطاعم المفضلة',
          icon: Icons.storefront_outlined,
          color: primaryColor,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 10)),
      if (restaurants.isEmpty)
        const SliverToBoxAdapter(
          child: _SectionEmpty(text: 'ماكو مطاعم مفضلة حالياً'),
        )
      else
        SliverList.separated(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FavoriteRestaurantCard(restaurant: restaurants[index]),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: restaurants.length,
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 18)),
    ];
  }
}

class _FavoriteTabs extends StatelessWidget {
  const _FavoriteTabs({
    required this.selectedTab,
    required this.mealsCount,
    required this.restaurantsCount,
    required this.onChanged,
  });

  final _FavoriteTab selectedTab;
  final int mealsCount;
  final int restaurantsCount;
  final ValueChanged<_FavoriteTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE7EAE7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabSegment(
                title: 'المطاعم',
                count: restaurantsCount,
                icon: Iconsax.shop,
                selected: selectedTab == _FavoriteTab.restaurants,
                onTap: () => onChanged(_FavoriteTab.restaurants),
              ),
            ),
            Expanded(
              child: _TabSegment(
                title: 'الأكل',
                count: mealsCount,
                icon: FontAwesomeIcons.burger,
                selected: selectedTab == _FavoriteTab.meals,
                onTap: () => onChanged(_FavoriteTab.meals),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.title,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: double.infinity,
        decoration:
            selected
                ? BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                )
                : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$title $count',
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF151B18),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: selected ? Colors.white : primaryColor, size: 14),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteMealCard extends StatelessWidget {
  const _FavoriteMealCard({required this.meal, required this.highlighted});

  final FavoriteMealData meal;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final heartColor = highlighted ? secondaryColor : primaryColor;
    final cubit = UserCubit.get(context);
    return InkWell(
      onTap: () {
        navigateTo(
          context,
          BlocProvider.value(
            value: cubit,
            child: MealDetailsPage(
              productId: meal.id,
              initialMeal: MealDetailsData.fromSeed(
                id: meal.id,
                name: meal.name,
                imageUrl: meal.imageUrl,
                price: meal.price,
                rating: meal.rating,
                isFavorite: true,
                restaurantId: meal.restaurantId,
                restaurantName: meal.restaurant,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 95,
        decoration: _softDecoration(radius: 18),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            InkWell(
              onTap: () => cubit.removeFavoriteMeal(meal.id),
              customBorder: const CircleBorder(),
              child: Icon(
                highlighted ? Iconsax.heart5 : Iconsax.heart,
                color: heartColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                meal.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Text(
                    meal.restaurant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star,
                        color: Color(0xFFFFA51E),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meal.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${meal.ratingCount})',
                        style: const TextStyle(
                          color: Color(0xFF9AA09D),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'د.ع ${_formatPrice(meal.price)}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LogoCircle(text: meal.logoText),
                  const SizedBox(height: 2),
                  const _DeliveryPill(),
                  const SizedBox(height: 2),
                  const _AddToCartPill(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteRestaurantCard extends StatelessWidget {
  const _FavoriteRestaurantCard({required this.restaurant});

  final FavoriteRestaurantData restaurant;

  @override
  Widget build(BuildContext context) {
    final cubit = UserCubit.get(context);
    return InkWell(
      onTap: () {
        if (restaurant.id == 0) {
          showToastError(text: 'تعذر فتح تفاصيل المطعم', context: context);
          return;
        }
        navigateTo(
          context,
          BlocProvider.value(
            value: cubit,
            child: RestaurantDetailsPage(restaurantId: restaurant.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 92,
        decoration: _softDecoration(radius: 18),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            InkWell(
              onTap: () => cubit.removeFavoriteRestaurant(restaurant.id),
              customBorder: const CircleBorder(),
              child: const Icon(Iconsax.heart5, color: primaryColor, size: 18),
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    restaurant.imageUrl,
                    width: 75,
                    height: 66,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: -20,
                  top: 18,
                  child: _LogoCircle(text: restaurant.logoText),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.type,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star,
                        color: Color(0xFFFFA51E),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF151B18),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(${restaurant.ratingCount})',
                        style: const TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 88,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _DeliveryPill(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        restaurant.time,
                        style: const TextStyle(
                          color: Color(0xFF747D79),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Iconsax.timer, color: primaryColor, size: 12),
                    ],
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

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF24342B),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DeliveryPill extends StatelessWidget {
  const _DeliveryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'توصيل مجاني',
            style: TextStyle(
              color: primaryColor,
              fontSize: 6,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.delivery_dining_rounded, color: primaryColor, size: 12),
        ],
      ),
    );
  }
}

class _AddToCartPill extends StatelessWidget {
  const _AddToCartPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB45D)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'أضف إلى السلة',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 2),
          Icon(Iconsax.shopping_cart, color: secondaryColor, size: 12),
        ],
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 58,
        alignment: Alignment.center,
        decoration: _softDecoration(radius: 14),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF747D79),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.heart, color: primaryColor, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            'قائمة المفضلة فارغة',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'من تضيف أكلة أو مطعم للمفضلة راح يظهر هنا',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF747D79),
              fontSize: 10,
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

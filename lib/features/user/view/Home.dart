import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/auth_guard.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/home_page_data.dart';
import '../data/meal_details_api_data.dart';
import 'widgets/user_page_shimmers.dart';
import 'meal_details.dart';
import 'meals_list_page.dart';
import 'nearby_restaurants_page.dart';
import 'restaurant_details.dart';
import 'search_page.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.onSearchTap});

  final VoidCallback? onSearchTap;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      UserCubit.get(context).getHomeData();
    }
  }

  void _openSearch(BuildContext context) {
    final callback = widget.onSearchTap;
    if (callback != null) {
      callback();
    } else {
      navigateTo(context, const SearchPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<UserCubit, UserStates>(
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final home = cubit.homeData;

              if (state is UserHomeLoadingState && home == null) {
                return const HomePageShimmer();
              }

              if (home == null) {
                return const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    UserNavHeaderSliver(),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'تعذر تحميل الصفحة الرئيسية',
                          style: TextStyle(
                            color: Color(0xFF747D79),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const UserNavHeaderSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: _SearchRow(onTap: () => _openSearch(context)),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _HeroBanner(ads: home.ads)),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: _CategoryStrip(
                      categories: home.categories,
                      onCategoryTap:
                          (category) => _openMealsList(
                            context,
                            title: category.title,
                            categoryId: category.id,
                          ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'أشهر الوجبات',
                      onTap:
                          () => _openMealsList(context, title: 'أشهر الوجبات'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        home.popularMeals.isEmpty
                            ? const _EmptyHomeLine(
                              text: 'لا توجد وجبات قريبة حالياً',
                            )
                            : SizedBox(
                              height: 210,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder:
                                    (context, index) => _MealCard(
                                      meal: home.popularMeals[index],
                                    ),
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 6),
                                itemCount: home.popularMeals.length,
                              ),
                            ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'المطاعم القريبة منك',
                      onTap: () => _openNearbyRestaurants(context),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (home.nearbyRestaurants.isEmpty)
                    const SliverToBoxAdapter(
                      child: _EmptyHomeLine(text: 'لا توجد مطاعم قريبة حالياً'),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _RestaurantCard(
                            restaurant: home.nearbyRestaurants[index],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: home.nearbyRestaurants.length,
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(29),
            child: Container(
              width: 38,
              height: 38,
              decoration: _softDecoration(radius: 29),
              child: const Icon(Iconsax.candle_2, size: 14),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                height: 38,
                decoration: _softDecoration(radius: 28),
                child: const Row(
                  children: [
                    SizedBox(width: 18),
                    Icon(
                      Iconsax.search_normal,
                      color: Color(0xFF77807F),
                      size: 15,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'إبحث عن مطعم أو وجبة...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8C9492),
                        fontWeight: FontWeight.w600,
                      ),
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

class _HeroBanner extends StatefulWidget {
  const _HeroBanner({required this.ads});

  final List<HomeAdData> ads;

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images =
        widget.ads
            .expand((ad) => ad.imageUrls)
            .where((imageUrl) => imageUrl.isNotEmpty)
            .toList();
    if (images.isEmpty) images.add('');

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CarouselSlider.builder(
              itemCount: images.length,
              itemBuilder:
                  (context, index, realIndex) =>
                      _HeroImage(imageUrl: images[index]),
              options: CarouselOptions(
                height: 130,
                viewportFraction: 1,
                autoPlay: images.length > 1,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 650),
                enableInfiniteScroll: images.length > 1,
                onPageChanged: (index, reason) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentIndex == index ? 20 : 7,
                height: 5,
                decoration: BoxDecoration(
                  color:
                      currentIndex == index
                          ? primaryColor
                          : const Color(0xFFDCE2DE),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/ChatGPT Image May 22, 2026, 04_52_01 PM.png',
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Image.asset(
            'assets/images/ChatGPT Image May 22, 2026, 04_52_01 PM.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories, required this.onCategoryTap});

  final List<CategoryData> categories;
  final ValueChanged<CategoryData> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyHomeLine(text: 'لا توجد أقسام حالياً');
    }

    return SizedBox(
      height: 65,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => onCategoryTap(category),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 55,
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          index == 0
                              ? const Color(0xFFFFF3E9)
                              : const Color(0xFFF8F8F5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .04),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child:
                        category.imageUrl == null
                            ? const Icon(
                              Iconsax.category,
                              color: primaryColor,
                              size: 24,
                            )
                            : Image.network(
                              category.imageUrl!,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Iconsax.category,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                            ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: const Row(
              children: [
                Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealCardData meal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateTo(
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
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 110,
        decoration: _softDecoration(radius: 18),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  meal.imageUrl,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 80,
                        color: const Color(0xFFF4F4F2),
                        child: const Icon(
                          Iconsax.gallery,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: _FavoriteCircle(
                    isFavorite: meal.isFavorite,
                    onTap:
                        () => runWithLogin(
                          context,
                          featureName: 'المفضلة',
                          action:
                              () => UserCubit.get(
                                context,
                              ).toggleHomeMealFavorite(meal),
                        ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _MiniPill(text: meal.time, icon: Iconsax.timer),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meal.restaurant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8A8F8D),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        meal.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF656B69),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Iconsax.star,
                        color: Color(0xFFFFAA22),
                        size: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});

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
                          child: const Icon(
                            Iconsax.shop,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                  ),
                ),
                Positioned(
                  right: 7,
                  top: 7,
                  child: _FavoriteCircle(
                    isFavorite: restaurant.isFavorite,
                    onTap:
                        () => runWithLogin(
                          context,
                          featureName: 'المفضلة',
                          action:
                              () => UserCubit.get(
                                context,
                              ).toggleHomeRestaurantFavorite(restaurant),
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

class _EmptyHomeLine extends StatelessWidget {
  const _EmptyHomeLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF747D79),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FavoriteCircle extends StatelessWidget {
  const _FavoriteCircle({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedScale(
        scale: isFavorite ? 1.08 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFavorite ? Iconsax.heart5 : Iconsax.heart,
            size: 13,
            color: isFavorite ? secondaryColor : primaryColor,
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: primaryColor,
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

BoxDecoration _softDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .07),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

void _openMealsList(
  BuildContext context, {
  required String title,
  int? categoryId,
}) {
  navigateTo(
    context,
    BlocProvider.value(
      value: UserCubit.get(context),
      child: MealsListPage(categoryId: categoryId, title: title),
    ),
  );
}

void _openNearbyRestaurants(BuildContext context) {
  navigateTo(
    context,
    BlocProvider.value(
      value: UserCubit.get(context),
      child: const NearbyRestaurantsPage(),
    ),
  );
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

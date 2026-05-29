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
import 'restaurant_details.dart';
import 'widgets/user_page_shimmers.dart';

class NearbyRestaurantsPage extends StatefulWidget {
  const NearbyRestaurantsPage({super.key});

  @override
  State<NearbyRestaurantsPage> createState() => _NearbyRestaurantsPageState();
}

class _NearbyRestaurantsPageState extends State<NearbyRestaurantsPage> {
  bool requestedInitialData = false;
  bool initialLoadFinished = false;

  @override
  Widget build(BuildContext context) {
    try {
      context.read<UserCubit>();
      return _buildWithCubit(context);
    } catch (_) {
      return BlocProvider(
        create: (_) => UserCubit(),
        child: Builder(builder: _buildWithCubit),
      );
    }
  }

  Widget _buildWithCubit(BuildContext context) {
    _requestInitialData(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<UserCubit, UserStates>(
            listener: (context, state) {
              if (state is UserNearbyRestaurantsErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserNearbyRestaurantsSuccessState) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final restaurants = cubit.nearbyRestaurantsList;
              final loading =
                  restaurants.isEmpty &&
                  (!initialLoadFinished ||
                      state is UserNearbyRestaurantsLoadingState);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const UserAppBarSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _RestaurantsHeader(count: restaurants.length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (loading)
                    const ListPageShimmerSlivers()
                  else if (restaurants.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyRestaurants(),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _FavoriteRestaurantCard(
                            restaurant: restaurants[index],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: restaurants.length,
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 92)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _requestInitialData(BuildContext context) {
    if (requestedInitialData) return;
    requestedInitialData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      UserCubit.get(context).getNearbyRestaurantsList();
    });
  }
}

class _RestaurantsHeader extends StatelessWidget {
  const _RestaurantsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.shop, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المطاعم القريبة منك',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  count == 0
                      ? 'مطاعم ضمن نطاق 10 كم'
                      : '$count مطعم ضمن نطاق 10 كم',
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRestaurantCard extends StatelessWidget {
  const _FavoriteRestaurantCard({required this.restaurant});

  final RestaurantCardData restaurant;

  @override
  Widget build(BuildContext context) {
    final cubit = UserCubit.get(context);
    return InkWell(
      onTap: () {
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
              onTap: () => cubit.toggleHomeRestaurantFavorite(restaurant),
              customBorder: const CircleBorder(),
              child: AnimatedScale(
                scale: restaurant.isFavorite ? 1.08 : 1,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: Icon(
                  restaurant.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                  color: primaryColor,
                  size: 18,
                ),
              ),
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
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 75,
                          height: 66,
                          color: const Color(0xFFF4F4F2),
                          child: const Icon(
                            Iconsax.shop,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
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
          SizedBox(width: 3),
          Icon(Iconsax.truck_fast, color: primaryColor, size: 10),
        ],
      ),
    );
  }
}

class _EmptyRestaurants extends StatelessWidget {
  const _EmptyRestaurants();

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
            child: const Icon(Iconsax.shop, color: primaryColor, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'ماكو مطاعم قريبة حالياً',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اسحب للتحديث حتى نبحث مرة ثانية',
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

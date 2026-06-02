import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/auth_guard.dart';
import '../../../core/widgets/show_toast.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/home_page_data.dart';
import '../data/meal_details_api_data.dart';
import 'meal_details.dart';
import 'widgets/user_page_shimmers.dart';

class MealsListPage extends StatefulWidget {
  const MealsListPage({super.key, this.categoryId, required this.title});

  final int? categoryId;
  final String title;

  @override
  State<MealsListPage> createState() => _MealsListPageState();
}

class _MealsListPageState extends State<MealsListPage> {
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
              if (state is UserMealsListErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserMealsListSuccessState) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final meals = cubit.mealsList;
              final loading =
                  meals.isEmpty &&
                  (!initialLoadFinished || state is UserMealsListLoadingState);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const UserAppBarSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _MealsListHeader(
                      title: widget.title,
                      count: meals.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (loading)
                    const ListPageShimmerSlivers(twoColumns: true)
                  else if (meals.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyMeals(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _GridMealCard(meal: meals[index]);
                        }, childCount: meals.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: .77,
                            ),
                      ),
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
      UserCubit.get(
        context,
      ).getMealsList(categoryId: widget.categoryId, title: widget.title);
    });
  }
}

class _MealsListHeader extends StatelessWidget {
  const _MealsListHeader({required this.title, required this.count});

  final String title;
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
              color: secondaryColor.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.cup, color: secondaryColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  count == 0
                      ? 'وجبات ضمن نطاق 10 كم'
                      : '$count وجبة ضمن نطاق 10 كم',
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

class _GridMealCard extends StatelessWidget {
  const _GridMealCard({required this.meal});

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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: _softDecoration(radius: 16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  meal.imageUrl,
                  height: 104,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 104,
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

class _FavoriteCircle extends StatelessWidget {
  const _FavoriteCircle({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .09),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Iconsax.heart5 : Iconsax.heart,
          color: isFavorite ? secondaryColor : primaryColor,
          size: 17,
        ),
      ),
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

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals();

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
            child: const Icon(Iconsax.cup, color: primaryColor, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'ماكو وجبات حالياً',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرب قسم ثاني أو اسحب للتحديث',
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

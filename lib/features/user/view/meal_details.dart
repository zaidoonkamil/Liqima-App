import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/meal_details_api_data.dart';
import 'restaurant_details.dart';
import 'widgets/user_page_shimmers.dart';

class MealDetailsPage extends StatefulWidget {
  const MealDetailsPage({super.key, this.productId, this.initialMeal});

  final int? productId;
  final MealDetailsData? initialMeal;

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController favoritePulse;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    favoritePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 190),
      lowerBound: .86,
      upperBound: 1.12,
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      loaded = true;
      final cubit = UserCubit.get(context);
      final productId = widget.productId;
      if (productId == null) {
        cubit.showPreviewMealDetails();
      } else {
        cubit.getMealDetails(productId, initialMeal: widget.initialMeal);
      }
    }
  }

  @override
  void dispose() {
    favoritePulse.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    showToastInfo(text: message, context: context);
  }

  Future<void> _toggleFavorite(UserCubit cubit) async {
    await favoritePulse.forward();
    await favoritePulse.reverse();
    await cubit.toggleMealFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<UserCubit, UserStates>(
          listener: (context, state) {
            if (state is UserFavoriteErrorState) {
              _showMessage('تعذر تحديث المفضلة');
            } else if (state is UserCartSuccessState) {
              _showMessage('تمت إضافة الوجبة إلى السلة');
            } else if (state is UserCartErrorState) {
              _showMessage('تعذر إضافة الوجبة إلى السلة');
            }
          },
          builder: (context, state) {
            final cubit = UserCubit.get(context);
            final meal = cubit.mealDetails;

            if (state is UserMealDetailsLoadingState && meal == null) {
              return const MealDetailsPageShimmer();
            }

            if (meal == null) {
              return const Center(
                child: Text(
                  'تعذر تحميل تفاصيل الوجبة',
                  style: TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }

            return Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 202,
                      collapsedHeight: 0,
                      toolbarHeight: 0,
                      pinned: false,
                      stretch: true,
                      backgroundColor: Colors.white,
                      automaticallyImplyLeading: false,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                        ],
                        background: _MealImageHeader(imageUrl: meal.imageUrl),
                      ),
                    ),
                    SliverToBoxAdapter(child: _MealInfo(meal: meal)),
                    const SliverToBoxAdapter(child: SizedBox(height: 126)),
                  ],
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => navigateBack(context),
                          ),
                          const Spacer(),
                          ScaleTransition(
                            scale: favoritePulse,
                            child: _HeaderButton(
                              icon:
                                  cubit.mealFavorite
                                      ? Iconsax.heart5
                                      : Iconsax.heart,
                              iconColor:
                                  cubit.mealFavorite
                                      ? secondaryColor
                                      : Colors.white,
                              onTap: () => _toggleFavorite(cubit),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .42),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: .2),
            width: 0.5,
          ),
        ),
        child: Icon(icon, color: iconColor, size: 14),
      ),
    );
  }
}

class _MealImageHeader extends StatelessWidget {
  const _MealImageHeader({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                color: const Color(0xFFF4F4F2),
                child: const Icon(Iconsax.gallery, color: primaryColor),
              ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .22),
                Colors.transparent,
                Colors.black.withValues(alpha: .10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MealInfo extends StatelessWidget {
  const _MealInfo({required this.meal});

  final MealDetailsData meal;

  @override
  Widget build(BuildContext context) {
    final cubit = UserCubit.get(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _SliderDots()),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      meal.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF737B79),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 66,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meal.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Iconsax.star1,
                      color: Color(0xFFFFA31C),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'د.ع ${_formatPrice(meal.price)}',
            style: const TextStyle(
              color: primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Iconsax.truck_fast,
                  title: meal.freeDelivery ? 'توصيل مجاني' : 'رسوم التوصيل',
                  subtitle:
                      meal.minimumOrder > 0
                          ? 'للطلبات فوق ${_formatPrice(meal.minimumOrder)} د.ع'
                          : 'حسب المطعم',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoTile(
                  icon: Iconsax.timer,
                  title: 'وقت التوصيل',
                  subtitle: meal.deliveryTime,
                ),
              ),
            ],
          ),
          if (meal.restaurantId > 0 ||
              meal.restaurantName.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _MealRestaurantCard(meal: meal),
          ],
          if (meal.sizes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'اختر الحجم',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(meal.sizes.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == meal.sizes.length - 1 ? 0 : 8,
                    ),
                    child: _SizeTile(
                      data: meal.sizes[index],
                      active: cubit.selectedSizeIndex == index,
                      onTap: () => cubit.changeMealSize(index),
                    ),
                  ),
                );
              }),
            ),
          ],
          if (meal.addons.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'إضافات أخرى',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final addon = meal.addons[index];
                  return _ExtraTile(
                    data: addon,
                    active: cubit.selectedAddonIds.contains(addon.id),
                    onTap: () => cubit.toggleMealAddon(addon),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: meal.addons.length,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _AddToCartBar(
            quantity: cubit.mealQuantity,
            total: cubit.mealTotal(),
            loading: cubit.addingMealToCart,
            onMinus: cubit.decreaseMealQuantity,
            onPlus: cubit.increaseMealQuantity,
            onAddToCart: cubit.addMealToCart,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFF1EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8B9290),
                    fontSize: 9,
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

class _MealRestaurantCard extends StatelessWidget {
  const _MealRestaurantCard({required this.meal});

  final MealDetailsData meal;

  @override
  Widget build(BuildContext context) {
    final canOpen = meal.restaurantId > 0;

    return InkWell(
      onTap:
          canOpen
              ? () => navigateTo(
                context,
                BlocProvider.value(
                  value: UserCubit.get(context),
                  child: RestaurantDetailsPage(restaurantId: meal.restaurantId),
                ),
              )
              : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBF8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6EFE8)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: .07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _RestaurantLogo(imageUrl: meal.restaurantImageUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مقدم الوجبة',
                    style: TextStyle(
                      color: Color(0xFF8B9290),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.restaurantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF141A17),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _RestaurantChip(
                        icon: Iconsax.timer,
                        text: meal.deliveryTime,
                      ),
                      const SizedBox(width: 6),
                      _RestaurantChip(
                        icon: Iconsax.truck_fast,
                        text: meal.freeDelivery ? 'توصيل مجاني' : 'حسب المطعم',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE3ECE6)),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: canOpen ? primaryColor : const Color(0xFFB8C0BD),
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  const _RestaurantLogo({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final image = imageUrl;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
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
      clipBehavior: Clip.antiAlias,
      child:
          image == null || image.isEmpty
              ? const Icon(Iconsax.shop, color: primaryColor, size: 24)
              : Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        const Icon(Iconsax.shop, color: primaryColor, size: 24),
              ),
    );
  }
}

class _RestaurantChip extends StatelessWidget {
  const _RestaurantChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryColor, size: 12),
          const SizedBox(width: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF16734B),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeTile extends StatelessWidget {
  const _SizeTile({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final MealSizeData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF8FFFA) : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: active ? primaryColor : const Color(0xFFEFF1EE),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.name,
                style: TextStyle(
                  color: active ? primaryColor : Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'د.ع ${_formatPrice(data.price)}',
                style: TextStyle(
                  color: active ? primaryColor : Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtraTile extends StatelessWidget {
  const _ExtraTile({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final MealAddonData data;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 104,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF8FFFA) : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: active ? primaryColor : const Color(0xFFEFF1EE),
          ),
        ),
        child: Column(
          children: [
            Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
            ),
            Text(
              'د.ع ${_formatPrice(data.price)}',
              style: const TextStyle(
                color: Color(0xFF626B68),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (data.image == null)
                  const Icon(Iconsax.additem, color: primaryColor, size: 20)
                else
                  Image.network(
                    data.image!,
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: active ? primaryColor : const Color(0xFFF0F5F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    active ? Icons.check_rounded : Icons.add,
                    color: active ? Colors.white : primaryColor,
                    size: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.quantity,
    required this.total,
    required this.loading,
    required this.onMinus,
    required this.onPlus,
    required this.onAddToCart,
  });

  final int quantity;
  final int total;
  final bool loading;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: loading ? null : onAddToCart,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: .25),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 17),
                  Text(
                    'د.ع ${_formatPrice(total)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  loading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'أضف إلى السلة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  const Spacer(),
                  const Icon(
                    Iconsax.shopping_cart,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 17),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 105,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add, color: primaryColor, size: 14),
              ),
              Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove, color: primaryColor, size: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderDots extends StatelessWidget {
  const _SliderDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

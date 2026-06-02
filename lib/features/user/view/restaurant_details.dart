import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/auth_guard.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/meal_details_api_data.dart';
import '../data/restaurant_details_api_data.dart';
import 'cart_page.dart';
import 'meal_details.dart';
import 'widgets/user_page_shimmers.dart';

class RestaurantDetailsPage extends StatefulWidget {
  const RestaurantDetailsPage({super.key, required this.restaurantId});

  final int restaurantId;

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserCubit.get(context).getRestaurantDetails(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<UserCubit, UserStates>(
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final restaurant = cubit.restaurantDetails;

              if (restaurant == null &&
                  state is UserRestaurantDetailsLoadingState) {
                return const RestaurantDetailsPageShimmer();
              }

              if (restaurant == null) {
                return Center(
                  child: Text(
                    state is UserRestaurantDetailsErrorState
                        ? state.message
                        : 'تعذر تحميل المطعم',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6F7775),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }

              final items = restaurant.itemsForCategory(
                cubit.selectedRestaurantCategoryId,
              );

              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _CoverHeader(imageUrl: restaurant.coverUrl),
                  ),
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _RestaurantTopSection(restaurant: restaurant),
                      ),
                      SliverToBoxAdapter(
                        child: _RestaurantDetailsTabs(
                          selectedIndex: _selectedTab,
                          onChanged:
                              (index) => setState(() => _selectedTab = index),
                        ),
                      ),
                      if (_selectedTab == 0) ...[
                        SliverToBoxAdapter(
                          child: _CategoryChips(
                            restaurant: restaurant,
                            selectedCategoryId:
                                cubit.selectedRestaurantCategoryId,
                            onChanged: cubit.selectRestaurantCategory,
                          ),
                        ),

                        if (items.isEmpty)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: _EmptyMenuText(),
                            ),
                          )
                        else
                          SliverList.separated(
                            itemBuilder: (context, index) {
                              return ColoredBox(
                                color: Colors.white,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Padding(
                                    key: ValueKey(
                                      '${cubit.selectedRestaurantCategoryId}-${items[index].id}',
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                    ),
                                    child: _MenuItem(
                                      item: items[index],
                                      restaurant: restaurant,
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (_, __) => const ColoredBox(
                                  color: Colors.white,
                                  child: SizedBox(height: 14),
                                ),
                            itemCount: items.length,
                          ),
                      ] else if (_selectedTab == 1)
                        SliverToBoxAdapter(
                          child: _RestaurantOffersInfo(restaurant: restaurant),
                        )
                      else if (_selectedTab == 2)
                        SliverToBoxAdapter(
                          child: _RestaurantRatingsInfo(restaurant: restaurant),
                        )
                      else
                        SliverToBoxAdapter(
                          child: _RestaurantInformation(restaurant: restaurant),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ),
                  Padding(
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
                          _HeaderButton(
                            icon: Iconsax.shopping_cart,
                            count:
                                isUserLoggedIn
                                    ? cubit.cartData?.summary.itemsCount ?? 0
                                    : 0,
                            onTap:
                                () => runWithLogin(
                                  context,
                                  featureName: 'السلة',
                                  action:
                                      () => navigateTo(
                                        context,
                                        BlocProvider.value(
                                          value: cubit,
                                          child: const CartPage(),
                                        ),
                                      ),
                                ),
                          ),
                          const SizedBox(width: 8),
                          _FavoriteHeaderButton(
                            isFavorite: cubit.restaurantFavorite,
                            onTap:
                                () => runWithLogin(
                                  context,
                                  featureName: 'المفضلة',
                                  action: cubit.toggleRestaurantFavorite,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RestaurantTopSection extends StatelessWidget {
  const _RestaurantTopSection({required this.restaurant});

  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: _RestaurantInfoCard(restaurant: restaurant),
          ),
          Positioned(
            right: 38,
            top: 104,
            child: _RestaurantLogo(imageUrl: restaurant.logoUrl),
          ),
        ],
      ),
    );
  }
}

class _CoverHeader extends StatelessWidget {
  const _CoverHeader({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: .27)),
        ],
      ),
    );
  }
}

class _RestaurantInfoCard extends StatelessWidget {
  const _RestaurantInfoCard({required this.restaurant});

  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: primaryColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            restaurant.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6F7775),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _RestaurantStats(restaurant: restaurant),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  const _RestaurantLogo({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover)),
    );
  }
}

class _RestaurantStats extends StatelessWidget {
  const _RestaurantStats({required this.restaurant});

  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatItem(
          icon: Iconsax.star,
          iconColor: const Color(0xFFFFA31C),
          text: restaurant.rating.toStringAsFixed(1),
          dark: true,
        ),
        const _SmallDivider(),
        _StatItem(text: '(${restaurant.ratingCount}) تقييم'),
        const _SmallDivider(),
        _StatItem(
          icon: Iconsax.location,
          iconColor: primaryColor,
          text: restaurant.distance,
          dark: true,
        ),
        const _SmallDivider(),
        _StatItem(
          icon: Iconsax.timer,
          iconColor: primaryColor,
          text: restaurant.deliveryTime,
          dark: true,
        ),
        const _SmallDivider(),
        _StatItem(
          icon: Iconsax.truck_fast,
          iconColor: primaryColor,
          text: restaurant.freeDelivery ? 'توصيل مجاني' : 'توصيل',
          green: true,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.text,
    this.icon,
    this.iconColor,
    this.green = false,
    this.dark = false,
  });

  final String text;
  final IconData? icon;
  final Color? iconColor;
  final bool green;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textColor =
        green
            ? primaryColor
            : (dark ? Colors.black87 : const Color(0xFF6F7775));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor, size: 12),
          const SizedBox(width: 2),
        ],
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SmallDivider extends StatelessWidget {
  const _SmallDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 13,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: const Color(0xFFE5E8E4),
    );
  }
}

class _RestaurantDetailsTabs extends StatelessWidget {
  const _RestaurantDetailsTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = ['القائمة', 'العروض', 'التقييمات', 'المعلومات'];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            selectedIndex == i
                                ? primaryColor
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          selectedIndex == i
                              ? primaryColor
                              : const Color(0xFF565F5A),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RestaurantInformation extends StatelessWidget {
  const _RestaurantInformation({required this.restaurant});

  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    final hours =
        restaurant.openingTime.isEmpty && restaurant.closingTime.isEmpty
            ? 'غير محدد'
            : '${restaurant.openingTime.isEmpty ? '--' : restaurant.openingTime} - ${restaurant.closingTime.isEmpty ? '--' : restaurant.closingTime}';
    final deliveryText =
        restaurant.deliveryFee <= 0
            ? 'توصيل مجاني'
            : 'د.ع ${_formatPrice(restaurant.deliveryFee)}';
    final policyText =
        'مجاني لحد ${restaurant.freeDeliveryDistanceKm.toStringAsFixed(1)} كم'
        '${restaurant.deliveryPricePerKm > 0 ? '، وبعدها د.ع ${_formatPrice(restaurant.deliveryPricePerKm)} لكل كم' : ''}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Column(
        children: [
          _InfoCard(
            title: 'معلومات المطعم',
            icon: Iconsax.info_circle,
            children: [
              if (restaurant.description.isNotEmpty)
                _InfoRow(
                  icon: Iconsax.note_text,
                  title: 'الوصف',
                  value: restaurant.description,
                ),
              _InfoRow(
                icon: Iconsax.location,
                title: 'العنوان',
                value:
                    restaurant.address.isEmpty
                        ? 'لم يتم تحديد العنوان'
                        : restaurant.address,
              ),
              _InfoRow(
                icon: Iconsax.map,
                title: 'المنطقة',
                value: restaurant.area.isEmpty ? 'غير محددة' : restaurant.area,
              ),
              _InfoRow(
                icon: Iconsax.routing,
                title: 'المسافة عنك',
                value: restaurant.distance,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoCard(
            title: 'التوصيل والعمل',
            icon: Iconsax.truck_fast,
            children: [
              _InfoRow(icon: Iconsax.clock, title: 'أوقات العمل', value: hours),
              _InfoRow(
                icon: Iconsax.tick_circle,
                title: 'حالة المطعم',
                value: restaurant.isOpen ? 'مفتوح' : 'مغلق حالياً',
                valueColor:
                    restaurant.isOpen ? primaryColor : const Color(0xFFE05757),
              ),
              _InfoRow(
                icon: Iconsax.timer,
                title: 'وقت التوصيل',
                value: restaurant.deliveryTime,
              ),
              _InfoRow(
                icon: Iconsax.receipt,
                title: 'الحد الأدنى للطلب',
                value: 'د.ع ${_formatPrice(restaurant.minimumOrder)}',
              ),
              _InfoRow(
                icon: Iconsax.money_4,
                title: 'رسوم التوصيل',
                value: deliveryText,
                valueColor: restaurant.deliveryFee <= 0 ? primaryColor : null,
              ),
              _InfoRow(
                icon: Iconsax.map_1,
                title: 'سياسة التوصيل',
                value: policyText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestaurantOffersInfo extends StatelessWidget {
  const _RestaurantOffersInfo({required this.restaurant});

  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    final hasOffer =
        restaurant.discountPercent > 0 && restaurant.discountMinOrder > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child:
          hasOffer
              ? _InfoCard(
                title: 'العروض المتاحة',
                icon: Iconsax.discount_shape,
                children: [
                  _InfoRow(
                    icon: Iconsax.percentage_square,
                    title: 'خصم الطلب',
                    value:
                        '${restaurant.discountPercent.toStringAsFixed(0)}% على الطلبات فوق د.ع ${_formatPrice(restaurant.discountMinOrder)}',
                    valueColor: primaryColor,
                  ),
                ],
              )
              : const _EmptyInfoCard(
                icon: Iconsax.discount_shape,
                title: 'ماكو عروض حالياً',
                subtitle: 'من يضيف المطعم عرض جديد راح يظهر هنا',
              ),
    );
  }
}

class _RestaurantRatingsInfo extends StatelessWidget {
  const _RestaurantRatingsInfo({required this.restaurant});

  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: _InfoCard(
        title: 'التقييمات',
        icon: Iconsax.star,
        children: [
          _InfoRow(
            icon: Iconsax.star1,
            title: 'تقييم المطعم',
            value: restaurant.rating.toStringAsFixed(1),
            valueColor: const Color(0xFFFFA31C),
          ),
          _InfoRow(
            icon: Iconsax.message_question,
            title: 'عدد التقييمات',
            value: '${restaurant.ratingCount} تقييم',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEFED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 17),
              const SizedBox(width: 7),
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
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 15),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? const Color(0xFF151B18),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
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

class _EmptyInfoCard extends StatelessWidget {
  const _EmptyInfoCard({
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEFED)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.restaurant,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final RestaurantDetailsData restaurant;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = restaurant.categories;
    return Container(
      color: Colors.white,
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final active =
              isAll
                  ? selectedCategoryId == null
                  : selectedCategoryId == category!.id;
          return GestureDetector(
            onTap: () => onChanged(category?.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 68,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: active ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active ? primaryColor : const Color(0xFFECEFED),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .045),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isAll)
                    Icon(
                      Icons.grid_view_rounded,
                      color: active ? Colors.white : primaryColor,
                      size: 22,
                    )
                  else if (category!.imageUrl != null)
                    ClipOval(
                      child: Image.network(
                        category.imageUrl!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(
                      Iconsax.category,
                      color: active ? Colors.white : primaryColor,
                      size: 22,
                    ),
                  const SizedBox(height: 5),
                  Text(
                    isAll ? 'الكل' : category!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFF303631),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemCount: categories.length + 1,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.item, required this.restaurant});

  final RestaurantMenuItemApiData item;
  final RestaurantDetailsData restaurant;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateTo(
          context,
          BlocProvider.value(
            value: UserCubit.get(context),
            child: MealDetailsPage(
              productId: item.id,
              initialMeal: MealDetailsData.fromSeed(
                id: item.id,
                name: item.name,
                description: item.description,
                imageUrl: item.imageUrl,
                price: item.price,
                rating: item.rating,
                restaurantId:
                    item.restaurantId > 0 ? item.restaurantId : restaurant.id,
                restaurantName: restaurant.name,
                restaurantImageUrl: restaurant.logoUrl,
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF141A17),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF767E7A),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF3A403D),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Iconsax.star,
                        color: Color(0xFFFFA31C),
                        size: 14,
                      ),
                      const Spacer(),
                      const _GreenAddButton(),
                      const SizedBox(width: 8),
                      Text(
                        'د.ع ${_formatPrice(item.price)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
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
    );
  }
}

class _FavoriteHeaderButton extends StatelessWidget {
  const _FavoriteHeaderButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: AnimatedScale(
        scale: isFavorite ? 1.12 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isFavorite
                    ? secondaryColor
                    : Colors.black.withValues(alpha: .42),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: .2),
              width: 0.5,
            ),
          ),
          child: Icon(
            isFavorite ? Iconsax.heart5 : Iconsax.heart,
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
    );
  }
}

class _GreenAddButton extends StatelessWidget {
  const _GreenAddButton();

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

class _EmptyMenuText extends StatelessWidget {
  const _EmptyMenuText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'لا توجد وجبات في هذا القسم',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF767E7A),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

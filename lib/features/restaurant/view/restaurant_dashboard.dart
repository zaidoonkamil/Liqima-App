import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_states.dart';
import '../model/restaurant_models.dart';
import 'restaurant_deliveries_page.dart';
import 'restaurant_menu_page.dart';
import 'widgets/restaurant_ui_widgets.dart';

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<RestaurantCubit, RestaurantState>(
            builder: (context, state) {
              final dashboard =
                  state is RestaurantLoaded
                      ? state.dashboard
                      : context.read<RestaurantCubit>().dashboard;

              if (dashboard == null && state is RestaurantLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (dashboard == null) {
                return _EmptyDashboard(message: _errorText(state));
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const RestaurantHeaderSliver(title: 'لوحة المطعم'),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _OverviewCard(dashboard: dashboard),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _QuickActions(
                      onAddDelivery: () => showDeliverySheet(context: context),
                      onAddMeal: () => showProductSheet(context: context),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الدلفرية الخاصين',
                      icon: Icons.delivery_dining_rounded,
                      count: dashboard.deliveries.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: DeliveryCard(
                          delivery: dashboard.deliveries[index],
                          onEdit:
                              () => showDeliverySheet(
                                context: context,
                                delivery: dashboard.deliveries[index],
                              ),
                          onDelete:
                              () => showRestaurantDeleteDialog(
                                context: context,
                                title: 'حذف الدلفري؟',
                                message:
                                    'راح ينحذف هذا الدلفري من مطعمك بشكل نهائي.',
                                onConfirm:
                                    () => context
                                        .read<RestaurantCubit>()
                                        .deleteDelivery(
                                          dashboard.deliveries[index].id,
                                        ),
                              ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: dashboard.deliveries.take(2).length,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الأقسام والأكلات',
                      icon: Iconsax.reserve,
                      count:
                          dashboard.categories.length +
                          dashboard.products.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: ProductCard(
                          product: dashboard.products[index],
                          categories: dashboard.categories,
                          onEdit:
                              () => showProductSheet(
                                context: context,
                                product: dashboard.products[index],
                              ),
                          onDelete:
                              () => showRestaurantDeleteDialog(
                                context: context,
                                title: 'حذف الأكلة؟',
                                message:
                                    'راح تنحذف الأكلة من قائمة المطعم بشكل نهائي.',
                                onConfirm:
                                    () => context
                                        .read<RestaurantCubit>()
                                        .deleteProduct(
                                          dashboard.products[index].id,
                                        ),
                              ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: dashboard.products.take(3).length,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 94)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.dashboard});

  final RestaurantDashboardModel dashboard;

  @override
  Widget build(BuildContext context) {
    final restaurant = dashboard.restaurant;
    final cover =
        restaurant.coverImage ??
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: restaurantSoftDecoration(radius: 18),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 118,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(cover, fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: .28)),
                  Positioned(
                    right: 14,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          restaurant.subtitle ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RestaurantStatusPill(
                          text: restaurant.isOpen ? 'مفتوح الآن' : 'مغلق',
                          color:
                              restaurant.isOpen
                                  ? primaryColor
                                  : const Color(0xFF8A8F8D),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  _StatItem(
                    value: dashboard.stats.todayOrders.toString(),
                    title: 'طلبات اليوم',
                    icon: Iconsax.receipt_text,
                    color: primaryColor,
                  ),
                  _Divider(),
                  _StatItem(
                    value: formatRestaurantPrice(dashboard.stats.todayRevenue),
                    title: 'مبيعات اليوم',
                    icon: Iconsax.wallet_3,
                    color: secondaryColor,
                  ),
                  _Divider(),
                  _StatItem(
                    value: dashboard.stats.rating.toStringAsFixed(1),
                    title: 'التقييم',
                    icon: Iconsax.star,
                    color: const Color(0xFFFFA51E),
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String value;
  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF151B18),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF66706C),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: const Color(0xFFE8ECE8));
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onAddDelivery, required this.onAddMeal});

  final VoidCallback onAddDelivery;
  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _ActionCard(
            title: 'إضافة دلفري',
            subtitle: 'خاص بالمطعم',
            icon: Icons.delivery_dining_rounded,
            color: primaryColor,
            onTap: onAddDelivery,
          ),
          const SizedBox(width: 8),
          _ActionCard(
            title: 'إضافة أكلة',
            subtitle: 'وجبة جديدة',
            icon: Iconsax.reserve,
            color: secondaryColor,
            onTap: onAddMeal,
          ),
          const SizedBox(width: 8),
          _ActionCard(
            title: 'إضافة قسم',
            subtitle: 'تنظيم القائمة',
            icon: Iconsax.category,
            color: const Color(0xFF2D8AC8),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: restaurantSoftDecoration(radius: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 7),
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
                  color: Color(0xFF747D79),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const RestaurantHeaderSliver(title: 'لوحة المطعم'),
        SliverFillRemaining(
          child: Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

String _errorText(RestaurantState state) {
  if (state is RestaurantError) return state.message;
  return 'لا توجد بيانات حالياً';
}

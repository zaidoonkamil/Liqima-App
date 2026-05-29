import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/delivery_cubit.dart';
import '../cubit/delivery_states.dart';
import '../model/delivery_models.dart';
import 'widgets/delivery_ui_widgets.dart';

class DeliveryDashboardPage extends StatefulWidget {
  const DeliveryDashboardPage({super.key});

  @override
  State<DeliveryDashboardPage> createState() => _DeliveryDashboardPageState();
}

class _DeliveryDashboardPageState extends State<DeliveryDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeliveryCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<DeliveryCubit, DeliveryState>(
            listener: (context, state) {
              if (state is DeliveryError) {
                showToastError(text: state.message, context: context);
              }
            },
            builder: (context, state) {
              final cubit = context.read<DeliveryCubit>();
              final dashboard = cubit.dashboard;
              final loading =
                  dashboard == null && state is DeliveryDashboardLoading;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const DeliveryHeaderSliver(title: 'لوحة الدلفري'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (loading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (dashboard == null)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'تعذر تحميل بيانات الدلفري',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: _DeliveryHero(delivery: dashboard.delivery),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate([
                          _StatCard(
                            title: 'طلبات اليوم',
                            value: dashboard.stats.todayOrders.toString(),
                            icon: Iconsax.receipt_text,
                            color: primaryColor,
                          ),
                          _StatCard(
                            title: 'طلبات فعالة',
                            value: dashboard.stats.activeOrders.toString(),
                            icon: Iconsax.timer,
                            color: secondaryColor,
                          ),
                          _StatCard(
                            title: 'تم توصيلها اليوم',
                            value: dashboard.stats.deliveredToday.toString(),
                            icon: Iconsax.tick_circle,
                            color: const Color(0xFF2D8AC8),
                          ),
                          _StatCard(
                            title: 'دخل اليوم',
                            value:
                                '${formatDeliveryPrice(dashboard.stats.todayRevenue)} د.ع',
                            icon: Iconsax.wallet_2,
                            color: primaryColor,
                          ),
                          _StatCard(
                            title: 'كل الرحلات',
                            value: dashboard.stats.totalTrips.toString(),
                            icon: Icons.delivery_dining_rounded,
                            color: secondaryColor,
                          ),
                          _StatCard(
                            title: 'أقصى مسافة',
                            value:
                                '${dashboard.stats.maxDistanceKm.toStringAsFixed(1)} كم',
                            icon: Iconsax.routing_2,
                            color: const Color(0xFF2D8AC8),
                          ),
                        ]),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.55,
                            ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: DeliverySectionHeader(
                        title: 'آخر الطلبات',
                        icon: Iconsax.receipt_text,
                        count: dashboard.recentOrders.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    if (dashboard.recentOrders.isEmpty)
                      const SliverToBoxAdapter(
                        child: _EmptyLine(text: 'ماكو طلبات موجهة حالياً'),
                      )
                    else
                      SliverList.separated(
                        itemBuilder: (context, index) {
                          final order = dashboard.recentOrders[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: _MiniOrderCard(order: order),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: dashboard.recentOrders.length,
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeliveryHero extends StatelessWidget {
  const _DeliveryHero({required this.delivery});

  final DeliveryInfoModel delivery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: deliverySoftDecoration(radius: 18),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                color: primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${delivery.vehicleType} · ${delivery.phone}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            DeliveryStatusPill(
              text: delivery.isAvailable ? 'متاح' : 'غير متاح',
              color:
                  delivery.isAvailable ? primaryColor : const Color(0xFFE34B4B),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: deliverySoftDecoration(radius: 16),
      padding: const EdgeInsets.all(12),
      child: Row(
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _MiniOrderCard extends StatelessWidget {
  const _MiniOrderCard({required this.order});

  final DeliveryOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: deliverySoftDecoration(radius: 16),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.receipt_text,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.orderNumber} · ${order.restaurantName}',
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
                  order.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747D79),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          DeliveryStatusPill(
            text: order.statusLabel,
            color: _statusColor(order.status),
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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

Color _statusColor(String status) {
  return switch (status) {
    'ready_for_pickup' => secondaryColor,
    'on_way' => const Color(0xFF2D8AC8),
    'delivered' => primaryColor,
    'cancelled' => const Color(0xFFE34B4B),
    _ => const Color(0xFF8A8F8D),
  };
}

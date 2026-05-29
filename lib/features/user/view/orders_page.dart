import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/services/orders_socket_service.dart';
import '../../../core/widgets/user_nav_header.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../data/orders_page_data.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import 'widgets/user_page_shimmers.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, this.active = true});

  final bool active;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with WidgetsBindingObserver {
  UserOrderStatus selectedStatus = UserOrderStatus.all;
  bool initialLoadFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.active) _openOrdersConnection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.active) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      OrdersSocketService.instance.disconnect();
    }
    if (state == AppLifecycleState.resumed) {
      _openOrdersConnection();
    }
  }

  @override
  void didUpdateWidget(covariant OrdersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _openOrdersConnection();
    } else if (!widget.active && oldWidget.active) {
      OrdersSocketService.instance.disconnect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.active) OrdersSocketService.instance.disconnect();
    super.dispose();
  }

  void _openOrdersConnection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active) return;
      UserCubit.get(context).getOrdersData(refresh: true);
      OrdersSocketService.instance.connect(
        role: 'user',
        onOrdersChanged: () {
          if (!mounted || !widget.active) return;
          UserCubit.get(context).getOrdersData(refresh: true);
        },
      );
    });
  }

  List<OrderCardData> _visibleOrders(List<OrderCardData> orders) {
    if (selectedStatus == UserOrderStatus.all) return orders;
    return orders.where((order) => order.status == selectedStatus).toList();
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
              if (state is UserOrdersErrorState) {
                initialLoadFinished = true;
                showToastError(text: state.message, context: context);
              }
              if (state is UserOrdersSuccessState) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              final cubit = UserCubit.get(context);
              final orders =
                  cubit.ordersData?.orders ?? const <OrderCardData>[];
              final visibleOrders = _visibleOrders(orders);
              final loading =
                  cubit.ordersData == null &&
                  (!initialLoadFinished || state is UserOrdersLoadingState);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const UserNavHeaderSliver(),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _StatusFilter(
                      selectedStatus: selectedStatus,
                      onChanged:
                          (status) => setState(() => selectedStatus = status),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (loading)
                    const OrdersPageShimmerSlivers()
                  else if (visibleOrders.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyOrders(),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _OrderCard(order: visibleOrders[index]),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: visibleOrders.length,
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

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selectedStatus, required this.onChanged});

  final UserOrderStatus selectedStatus;
  final ValueChanged<UserOrderStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final filter = OrdersPageData.filters[index];
          final selected = selectedStatus == filter.status;
          return InkWell(
            onTap: () => onChanged(filter.status),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? primaryColor : const Color(0xFFE8ECE8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    filter.icon,
                    color: selected ? Colors.white : primaryColor,
                    size: 17,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF151B18),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: OrdersPageData.filters.length,
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

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
              Iconsax.shopping_bag,
              color: primaryColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ماكو طلبات حالياً',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'من تكمل طلبك راح يظهر هنا وتكدر تتابع حالته',
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderCardData order;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: _softDecoration(radius: 18),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          order.logoUrl,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.restaurantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF151B18),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            order.restaurantType,
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
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.calendar,
                        color: primaryColor,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.dateText,
                        style: const TextStyle(
                          color: Color(0xFF555D59),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (order.timeText.isNotEmpty) ...[
                        const Icon(
                          Iconsax.timer,
                          color: primaryColor,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.timeText,
                          style: const TextStyle(
                            color: Color(0xFF555D59),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (order.itemsText.isNotEmpty)
                    Text(
                      order.itemsText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF666E6B),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Text(
                      order.canceledText ?? '',
                      style: const TextStyle(
                        color: Color(0xFFE34B4B),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (order.secondaryAction != null) ...[
                        _ActionPill(
                          text: order.secondaryAction!,
                          icon: Iconsax.call,
                          green: false,
                        ),
                        const SizedBox(width: 6),
                      ],
                      _ActionPill(
                        text: order.primaryAction,
                        icon: _actionIcon(order.status),
                        green: true,
                      ),
                      const Spacer(),

                      Text(
                        'د.ع ${_formatPrice(order.price)}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFEFF1EE)),
          SizedBox(width: 102, child: _OrderStatusPanel(order: order)),
        ],
      ),
    );
  }
}

class _OrderStatusPanel extends StatelessWidget {
  const _OrderStatusPanel({required this.order});

  final OrderCardData order;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final statusAsset = _statusAsset(order.status);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  order.statusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                statusAsset == null
                    ? Icon(order.sideIcon, color: color, size: 24)
                    : Image.asset(statusAsset, width: 20, height: 20),
          ),
          const SizedBox(height: 9),
          Text(
            order.statusTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.statusDescription,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF747D79),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          // if (order.rating != null) ...[
          //   const SizedBox(height: 5),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(Icons.star, color: Color(0xFFFFA31C), size: 12),
          //       const SizedBox(width: 3),
          //       Text(
          //         order.rating!.toStringAsFixed(1),
          //         style: const TextStyle(
          //           color: Color(0xFF151B18),
          //           fontSize: 10,
          //           fontWeight: FontWeight.w900,
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.text,
    required this.icon,
    required this.green,
  });

  final String text;
  final IconData icon;
  final bool green;

  @override
  Widget build(BuildContext context) {
    final color = green ? primaryColor : secondaryColor;
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _RecentOrders extends StatelessWidget {
  const _RecentOrders();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Text(
                'الطلبات الأخيرة',
                style: TextStyle(
                  color: Color(0xFF151B18),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right_rounded, color: primaryColor, size: 16),
              Text(
                'عرض الكل',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 74,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final order = OrdersPageData.recentOrders[index];
              return SizedBox(
                width: 64,
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.network(
                        order.logoUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      order.number,
                      style: const TextStyle(
                        color: Color(0xFF5F6764),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: OrdersPageData.recentOrders.length,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.preparing => secondaryColor,
    UserOrderStatus.readyForPickup => secondaryColor,
    UserOrderStatus.onWay => const Color(0xFF2D8AC8),
    UserOrderStatus.delivered => primaryColor,
    UserOrderStatus.canceled => const Color(0xFFE34B4B),
    UserOrderStatus.all => primaryColor,
  };
}

String? _statusAsset(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.preparing => 'assets/images/orderisinordering.png',
    UserOrderStatus.readyForPickup => 'assets/images/deliverylokma.png',
    UserOrderStatus.onWay => 'assets/images/orderindeliverd.png',
    _ => null,
  };
}

IconData _actionIcon(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.readyForPickup => Icons.inventory_2_outlined,
    UserOrderStatus.onWay => Icons.location_on_outlined,
    UserOrderStatus.delivered => Icons.refresh_rounded,
    UserOrderStatus.canceled => Icons.refresh_rounded,
    _ => Icons.chevron_left_rounded,
  };
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

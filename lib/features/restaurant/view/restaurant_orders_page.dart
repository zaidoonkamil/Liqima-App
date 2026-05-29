import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/services/orders_socket_service.dart';
import '../../../core/styles/themes.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_states.dart';
import '../model/restaurant_models.dart';
import 'widgets/restaurant_ui_widgets.dart';

class RestaurantOrdersPage extends StatefulWidget {
  const RestaurantOrdersPage({super.key, this.active = true});

  final bool active;

  @override
  State<RestaurantOrdersPage> createState() => _RestaurantOrdersPageState();
}

class _RestaurantOrdersPageState extends State<RestaurantOrdersPage>
    with WidgetsBindingObserver {
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
  void didUpdateWidget(covariant RestaurantOrdersPage oldWidget) {
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
      final cubit = context.read<RestaurantCubit>();
      if (cubit.dashboard == null) cubit.loadDashboard();
      cubit.loadOrders(status: cubit.selectedOrderStatus);
      OrdersSocketService.instance.connect(
        role: 'restaurant',
        onOrdersChanged: () {
          if (!mounted || !widget.active) return;
          final cubit = context.read<RestaurantCubit>();
          cubit.loadOrders(status: cubit.selectedOrderStatus);
          cubit.refreshDashboard();
        },
      );
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
          child: BlocBuilder<RestaurantCubit, RestaurantState>(
            builder: (context, state) {
              final cubit = context.read<RestaurantCubit>();
              final isLoading = state is RestaurantOrdersLoading;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const RestaurantHeaderSliver(title: 'طلبات المطعم'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _StatusFilter(
                      selectedStatus: cubit.selectedOrderStatus,
                      onChanged: (status) => cubit.loadOrders(status: status),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: RestaurantSectionHeader(
                      title: 'الطلبات القادمة',
                      icon: Iconsax.receipt_text,
                      count: cubit.orders.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else if (cubit.orders.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'ماكو طلبات حالياً',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final order = cubit.orders[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _RestaurantOrderCard(order: order),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: cubit.orders.length,
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

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selectedStatus, required this.onChanged});

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  static const statuses = [
    _OrderStatusOption(value: 'all', label: 'الكل'),
    _OrderStatusOption(value: 'incoming', label: 'قادمة'),
    _OrderStatusOption(value: 'preparing', label: 'تحضير'),
    _OrderStatusOption(value: 'delivery_pending', label: 'توجيه'),
    _OrderStatusOption(value: 'on_way', label: 'بالطريق'),
    _OrderStatusOption(value: 'delivered', label: 'مكتملة'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final selected = selectedStatus == status.value;
          return InkWell(
            onTap: () => onChanged(status.value),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? primaryColor : const Color(0xFFE8ECE8),
                ),
              ),
              child: Text(
                status.label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF151B18),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: statuses.length,
      ),
    );
  }
}

class _OrderStatusOption {
  const _OrderStatusOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _RestaurantOrderCard extends StatelessWidget {
  const _RestaurantOrderCard({required this.order});

  final RestaurantOrderModel order;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      decoration: restaurantSoftDecoration(radius: 18),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '#${order.orderNumber}',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              RestaurantStatusPill(
                text: _statusLabel(order.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.user, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'د.ع ${formatRestaurantPrice(order.total)}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    order.createdAtText,
                    style: const TextStyle(
                      color: Color(0xFF747D79),
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order.itemSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF555D59),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _OrderActions(order: order),
        ],
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.order});

  final RestaurantOrderModel order;

  @override
  Widget build(BuildContext context) {
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              text: order.status == 'delivered' ? 'مكتمل' : 'ملغي',
              icon:
                  order.status == 'delivered'
                      ? Iconsax.tick_circle
                      : Iconsax.close_circle,
              color:
                  order.status == 'delivered'
                      ? primaryColor
                      : const Color(0xFFE34B4B),
              onTap: () {},
            ),
          ),
        ],
      );
    }

    final actions = _actionsForStatus(order.status);
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          Expanded(
            child: _ActionButton(
              text: actions[i].label,
              icon: actions[i].icon,
              color: actions[i].color,
              onTap:
                  () => _confirmOrderAction(
                    context: context,
                    title: 'تأكيد تحديث الحالة',
                    message:
                        'هل تريد تغيير حالة الطلب إلى "${actions[i].label}"؟',
                    onConfirm:
                        () => context.read<RestaurantCubit>().updateOrderStatus(
                          orderId: order.id,
                          status: actions[i].nextStatus,
                        ),
                  ),
            ),
          ),
          if (i != actions.length - 1) const SizedBox(width: 8),
        ],
        if (order.status == 'ready_for_pickup') ...[
          if (actions.isNotEmpty) const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              text: 'توجيه دلفري',
              icon: Icons.delivery_dining_rounded,
              color: primaryColor,
              onTap: () => _showAssignDeliverySheet(context, order),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderActionData {
  const _OrderActionData({
    required this.label,
    required this.nextStatus,
    required this.icon,
    required this.color,
  });

  final String label;
  final String nextStatus;
  final IconData icon;
  final Color color;
}

List<_OrderActionData> _actionsForStatus(String status) {
  if (status == 'pending') {
    return const [
      _OrderActionData(
        label: 'قبول الطلب',
        nextStatus: 'accepted',
        icon: Iconsax.tick_circle,
        color: primaryColor,
      ),
    ];
  }
  if (status == 'accepted') {
    return const [
      _OrderActionData(
        label: 'بدء التحضير',
        nextStatus: 'preparing',
        icon: Iconsax.timer_start,
        color: secondaryColor,
      ),
    ];
  }
  if (status == 'preparing') {
    return const [
      _OrderActionData(
        label: 'جاهز للتوصيل',
        nextStatus: 'ready_for_pickup',
        icon: Iconsax.box_tick,
        color: primaryColor,
      ),
    ];
  }
  return const [];
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showAssignDeliverySheet(
  BuildContext context,
  RestaurantOrderModel order,
) {
  final cubit = context.read<RestaurantCubit>();
  final deliveries = cubit.dashboard?.deliveries ?? [];
  int? selectedDeliveryId =
      order.deliveryUserId ?? (deliveries.isEmpty ? null : deliveries.first.id);

  return showRestaurantSheet(
    context: context,
    title: 'توجيه الطلب',
    icon: Icons.delivery_dining_rounded,
    children: [
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE3E5E6)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedDeliveryId,
                isExpanded: true,
                hint: const Text(
                  'اختر الدلفري',
                  style: TextStyle(
                    color: Color(0xFF8E9295),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                items:
                    deliveries.map((delivery) {
                      return DropdownMenuItem<int?>(
                        value: delivery.id,
                        child: Text(
                          delivery.name,
                          style: const TextStyle(
                            color: Color(0xFF151B18),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => selectedDeliveryId = value),
              ),
            ),
          );
        },
      ),
    ],
    buttonText: 'توجيه الطلب',
    onSubmit: () {
      if (selectedDeliveryId == null) return;
      final deliveryId = selectedDeliveryId!;
      navigateBack(context);
      _confirmOrderAction(
        context: context,
        title: 'تأكيد توجيه الطلب',
        message: 'هل تريد توجيه هذا الطلب إلى الدلفري المختار؟',
        onConfirm:
            () => cubit.assignDelivery(
              orderId: order.id,
              deliveryUserId: deliveryId,
            ),
      );
    },
  );
}

Future<void> _confirmOrderAction({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF747D79),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => navigateBack(dialogContext),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Color(0xFF747D79),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                navigateBack(dialogContext);
                onConfirm();
              },
              child: const Text(
                'تأكيد',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _statusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'طلب جديد';
    case 'accepted':
      return 'مقبول';
    case 'preparing':
      return 'قيد التحضير';
    case 'ready_for_pickup':
      return 'جاهز للتوجيه';
    case 'on_way':
      return 'في الطريق';
    case 'delivered':
      return 'تم التوصيل';
    case 'cancelled':
      return 'ملغي';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'pending':
      return secondaryColor;
    case 'accepted':
    case 'preparing':
    case 'ready_for_pickup':
      return primaryColor;
    case 'on_way':
      return const Color(0xFF2D8AC8);
    case 'cancelled':
      return const Color(0xFFE34B4B);
    default:
      return const Color(0xFF8A8F8D);
  }
}

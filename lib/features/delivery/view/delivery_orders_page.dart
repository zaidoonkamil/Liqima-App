import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/services/orders_socket_service.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/show_toast.dart';
import '../cubit/delivery_cubit.dart';
import '../cubit/delivery_states.dart';
import '../model/delivery_models.dart';
import 'widgets/delivery_ui_widgets.dart';

class DeliveryOrdersPage extends StatefulWidget {
  const DeliveryOrdersPage({super.key, this.active = true});

  final bool active;

  @override
  State<DeliveryOrdersPage> createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends State<DeliveryOrdersPage>
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
  void didUpdateWidget(covariant DeliveryOrdersPage oldWidget) {
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
      final cubit = context.read<DeliveryCubit>();
      cubit.loadOrders(status: cubit.selectedStatus);
      OrdersSocketService.instance.connect(
        role: 'delivery',
        onOrdersChanged: () {
          if (!mounted || !widget.active) return;
          final cubit = context.read<DeliveryCubit>();
          cubit.loadOrders(status: cubit.selectedStatus);
          cubit.loadDashboard(silent: true);
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
          child: BlocConsumer<DeliveryCubit, DeliveryState>(
            listener: (context, state) {
              if (state is DeliveryError) {
                showToastError(text: state.message, context: context);
              }
              if (state is DeliveryActionSuccess) {
                showToastSuccess(text: 'تم تحديث حالة الطلب', context: context);
              }
            },
            builder: (context, state) {
              final cubit = context.read<DeliveryCubit>();
              final isLoading = state is DeliveryOrdersLoading;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const DeliveryHeaderSliver(title: 'طلبات الدلفري'),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _StatusFilter(
                      selectedStatus: cubit.selectedStatus,
                      onChanged: (status) => cubit.loadOrders(status: status),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: DeliverySectionHeader(
                      title: 'الطلبات الموجهة إليك',
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
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'ماكو طلبات موجهة حالياً',
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
                          child: _DeliveryOrderCard(order: order),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: cubit.orders.length,
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
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
    _OrderStatusOption(value: 'pending', label: 'جاهزة'),
    _OrderStatusOption(value: 'on_way', label: 'بالطريق'),
    _OrderStatusOption(value: 'delivered', label: 'مكتملة'),
    _OrderStatusOption(value: 'cancelled', label: 'ملغية'),
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

class _DeliveryOrderCard extends StatelessWidget {
  const _DeliveryOrderCard({required this.order});

  final DeliveryOrderModel order;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Container(
      decoration: deliverySoftDecoration(radius: 18),
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
              DeliveryStatusPill(text: order.statusLabel, color: statusColor),
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
                child: const Icon(
                  Iconsax.routing_2,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
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
                      order.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF747D79),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatDeliveryPrice(order.deliveryFee)} د.ع',
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

  final DeliveryOrderModel order;

  @override
  Widget build(BuildContext context) {
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return _ActionButton(
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
      );
    }

    if (order.status == 'ready_for_pickup') {
      return _ActionButton(
        text: 'بدء الرحلة',
        icon: Icons.delivery_dining_rounded,
        color: primaryColor,
        onTap:
            () => _confirmDeliveryAction(
              context: context,
              title: 'تأكيد بدء الرحلة',
              message: 'هل تريد تغيير حالة الطلب إلى في الطريق؟',
              onConfirm:
                  () => context.read<DeliveryCubit>().updateOrderStatus(
                    orderId: order.id,
                    status: 'on_way',
                  ),
            ),
      );
    }

    if (order.status == 'on_way') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              text: 'تم التوصيل',
              icon: Iconsax.tick_circle,
              color: primaryColor,
              onTap:
                  () => _confirmDeliveryAction(
                    context: context,
                    title: 'تأكيد التوصيل',
                    message: 'هل تريد تأكيد أن الطلب تم توصيله؟',
                    onConfirm:
                        () => context.read<DeliveryCubit>().updateOrderStatus(
                          orderId: order.id,
                          status: 'delivered',
                        ),
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              text: 'إلغاء',
              icon: Iconsax.close_circle,
              color: const Color(0xFFE34B4B),
              onTap:
                  () => _confirmDeliveryAction(
                    context: context,
                    title: 'تأكيد الإلغاء',
                    message: 'هل تريد إلغاء هذا الطلب؟',
                    onConfirm:
                        () => context.read<DeliveryCubit>().updateOrderStatus(
                          orderId: order.id,
                          status: 'cancelled',
                        ),
                  ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

Future<void> _confirmDeliveryAction({
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

Color _statusColor(String status) {
  return switch (status) {
    'ready_for_pickup' => secondaryColor,
    'on_way' => const Color(0xFF2D8AC8),
    'delivered' => primaryColor,
    'cancelled' => const Color(0xFFE34B4B),
    _ => const Color(0xFF8A8F8D),
  };
}

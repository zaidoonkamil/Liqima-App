import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/ navigation/navigation.dart';
import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/user_nav_header.dart'
    show PinnedAppHeaderSliver;
import '../../cubit/delivery_cubit.dart';
import '../../cubit/delivery_states.dart';
import '../delivery_notifications_page.dart';

class DeliveryHeader extends StatefulWidget {
  const DeliveryHeader({super.key, required this.title});

  final String title;

  @override
  State<DeliveryHeader> createState() => _DeliveryHeaderState();
}

class _DeliveryHeaderState extends State<DeliveryHeader> {
  bool requestedNotifications = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestNotifications();
  }

  @override
  Widget build(BuildContext context) {
    DeliveryCubit? cubit;
    try {
      cubit = context.read<DeliveryCubit>();
    } catch (_) {
      cubit = null;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 44),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child:
                  cubit == null
                      ? const Icon(Iconsax.notification, size: 22)
                      : BlocBuilder<DeliveryCubit, DeliveryState>(
                        bloc: cubit,
                        builder: (context, state) {
                          final unread =
                              cubit?.notificationsData?.unreadCount ?? 0;
                          return _DeliveryNotificationButton(
                            count: unread,
                            onTap:
                                () => navigateTo(
                                  context,
                                  BlocProvider.value(
                                    value: cubit!,
                                    child: const DeliveryNotificationsPage(),
                                  ),
                                ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestNotifications() {
    if (requestedNotifications) return;
    requestedNotifications = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final cubit = context.read<DeliveryCubit>();
        if (cubit.notificationsData == null) {
          cubit.getNotificationsData();
        }
      } catch (_) {}
    });
  }
}

class _DeliveryNotificationButton extends StatelessWidget {
  const _DeliveryNotificationButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Iconsax.notification, size: 22),
          if (count > 0)
            Positioned(
              right: -2,
              top: -5,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
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

class DeliveryHeaderSliver extends StatelessWidget {
  const DeliveryHeaderSliver({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PinnedAppHeaderSliver(
      height: 72,
      child: DeliveryHeader(title: title),
    );
  }
}

class DeliverySectionHeader extends StatelessWidget {
  const DeliverySectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
  });

  final String title;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 16),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF151B18),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FAF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryStatusPill extends StatelessWidget {
  const DeliveryStatusPill({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

BoxDecoration deliverySoftDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFF0F1EF)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .06),
        blurRadius: 16,
        offset: const Offset(0, 7),
      ),
    ],
  );
}

String formatDeliveryPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

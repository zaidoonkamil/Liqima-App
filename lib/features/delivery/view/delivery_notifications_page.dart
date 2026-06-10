import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/user_nav_header.dart' show PinnedAppHeaderSliver;
import '../../user/data/notifications_page_data.dart';
import '../../user/view/widgets/user_page_shimmers.dart';
import '../cubit/delivery_cubit.dart';
import '../cubit/delivery_states.dart';

class DeliveryNotificationsPage extends StatefulWidget {
  const DeliveryNotificationsPage({super.key});

  @override
  State<DeliveryNotificationsPage> createState() =>
      _DeliveryNotificationsPageState();
}

class _DeliveryNotificationsPageState extends State<DeliveryNotificationsPage> {
  bool requestedInitialData = false;
  bool initialLoadFinished = false;

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
              if (state is DeliveryNotificationsLoaded ||
                  state is DeliveryNotificationsRead ||
                  state is DeliveryError) {
                initialLoadFinished = true;
              }
            },
            builder: (context, state) {
              _requestInitialData(context);
              final cubit = context.read<DeliveryCubit>();
              final data = cubit.notificationsData;
              final notifications =
                  data?.notifications ?? const <UserNotificationData>[];
              final loading =
                  data == null &&
                  (!initialLoadFinished ||
                      state is DeliveryNotificationsLoading);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  const PinnedAppHeaderSliver(
                    height: 72,
                    child: _DeliveryNotificationsBar(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: _NotificationsSummary(
                      total: notifications.length,
                      unread: data?.unreadCount ?? 0,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (loading)
                    const OrdersPageShimmerSlivers()
                  else if (notifications.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyNotifications(),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _NotificationCard(
                            notification: notifications[index],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 9),
                      itemCount: notifications.length,
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<DeliveryCubit>();
      await cubit.getNotificationsData(refresh: true);
      await cubit.markNotificationsRead();
    });
  }
}

class _DeliveryNotificationsBar extends StatelessWidget {
  const _DeliveryNotificationsBar();

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'إشعارات الدلفري',
                    style: TextStyle(
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
              child: InkWell(
                onTap: () => navigateBack(context),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: _softDecoration(radius: 18),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF151B18),
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSummary extends StatelessWidget {
  const _NotificationsSummary({required this.total, required this.unread});

  final int total;
  final int unread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4FAF6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2EEE7)),
        ),
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
                Iconsax.notification_status,
                color: primaryColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unread > 0
                        ? 'عندك $unread إشعارات جديدة'
                        : 'كل الإشعارات مقروءة',
                    style: const TextStyle(
                      color: Color(0xFF151B18),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'إجمالي الإشعارات: $total',
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
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final UserNotificationData notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: _softDecoration(radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.notification_bing,
              color: secondaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151B18),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notification.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF68706C),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.clock, color: primaryColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _formatNotificationDate(notification.createdAt),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

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
              Iconsax.notification,
              color: primaryColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ماكو إشعارات حالياً',
            style: TextStyle(
              color: Color(0xFF151B18),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أي تحديث مهم راح يظهر هنا',
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

String _formatNotificationDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final dayText =
      target == today
          ? 'اليوم'
          : target == today.subtract(const Duration(days: 1))
          ? 'أمس'
          : '${date.year}/${date.month}/${date.day}';
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'م' : 'ص';
  return '$dayText، $hour:$minute $suffix';
}

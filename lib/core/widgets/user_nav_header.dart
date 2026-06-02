import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/user/cubit/cubit.dart';
import '../../features/user/cubit/states.dart';
import '../../features/user/view/cart_page.dart';
import '../../features/user/view/notifications.dart';
import '../ navigation/navigation.dart';
import '../services/location_service.dart';
import '../styles/themes.dart';
import 'auth_guard.dart';

class UserNavHeader extends StatelessWidget {
  const UserNavHeader({super.key});

  @override
  Widget build(BuildContext context) {
    UserCubit? cubit;
    try {
      cubit = UserCubit.get(context);
    } catch (_) {
      cubit = null;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 44),
                    const Text(
                      'أكلك يوصل لباب بيتك',
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
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.location, color: primaryColor),
                    const SizedBox(width: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<String>(
                          valueListenable: LocationService.locationLabel,
                          builder: (context, value, _) {
                            return SizedBox(
                              width: 92,
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'توصيل إلى باب البيت',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: _HeaderActions(cubit: cubit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserNavHeaderSliver extends StatelessWidget {
  const UserNavHeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const PinnedAppHeaderSliver(height: 78, child: UserNavHeader());
  }
}

class UserAppBar extends StatelessWidget {
  const UserAppBar({super.key});

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
                    'أكلك يوصل لباب بيتك',
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
              child: _AppBarCircleButton(
                icon: Icons.arrow_forward_ios,
                onTap: () => navigateBack(context),
              ),
            ),
            const Align(alignment: Alignment.centerRight, child: _SecurePill()),
          ],
        ),
      ),
    );
  }
}

class UserAppBarSliver extends StatelessWidget {
  const UserAppBarSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const PinnedAppHeaderSliver(height: 72, child: UserAppBar());
  }
}

class PinnedAppHeaderSliver extends StatelessWidget {
  const PinnedAppHeaderSliver({
    super.key,
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedAppHeaderDelegate(child: child, height: height),
    );
  }
}

class _PinnedAppHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedAppHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: .08),
      child: SizedBox(height: height, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedAppHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.cubit});

  final UserCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final activeCubit = cubit;
    if (activeCubit == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.shopping_cart),
          SizedBox(width: 8),
          Icon(Iconsax.notification),
        ],
      );
    }

    return BlocBuilder<UserCubit, UserStates>(
      bloc: activeCubit,
      builder: (context, state) {
        final cartCount = activeCubit.cartData?.summary.itemsCount ?? 0;
        final unreadCount = activeCubit.notificationsData?.unreadCount ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderIconButton(
              icon: Iconsax.shopping_cart,
              count: isUserLoggedIn ? cartCount : 0,
              onTap:
                  () => runWithLogin(
                    context,
                    featureName: 'السلة',
                    action:
                        () => navigateTo(
                          context,
                          BlocProvider.value(
                            value: activeCubit,
                            child: const CartPage(),
                          ),
                        ),
                  ),
            ),
            const SizedBox(width: 4),
            _HeaderIconButton(
              icon: Iconsax.notification,
              count: isUserLoggedIn ? unreadCount : 0,
              onTap:
                  () => runWithLogin(
                    context,
                    featureName: 'الإشعارات',
                    action:
                        () => navigateTo(
                          context,
                          BlocProvider.value(
                            value: activeCubit,
                            child: const NotificationsUser(),
                          ),
                        ),
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
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
          Icon(icon),
          if (count > 0)
            Positioned(
              right: -2,
              top: -5,
              child: _HeaderBadge(text: count > 99 ? '99+' : '$count'),
            ),
        ],
      ),
    );
  }
}

class _SecurePill extends StatelessWidget {
  const _SecurePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.lock, color: primaryColor, size: 16),
          SizedBox(width: 4),
          Text(
            'عملية آمنة',
            style: TextStyle(
              color: primaryColor,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarCircleButton extends StatelessWidget {
  const _AppBarCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: _softDecoration(radius: 18),
        child: Icon(icon, color: const Color(0xFF151B18), size: 17),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: secondaryColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
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

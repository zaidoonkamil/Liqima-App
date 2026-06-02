import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/user/cubit/cubit.dart';
import '../../features/user/view/Home.dart';
import '../../features/user/view/favorites_page.dart';
import '../../features/user/view/orders_page.dart';
import '../../features/user/view/profile_page.dart';
import '../../features/user/view/search_page.dart';
import '../services/location_service.dart';
import '../styles/themes.dart';
import '../widgets/auth_guard.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, this.initialIndex = 2});

  final int initialIndex;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int currentIndex;
  late final Set<int> loadedIndexes;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    loadedIndexes = {currentIndex};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationService.loadCachedLocation();
      LocationService.startLocationUpdates();
    });
  }

  Future<void> _changeIndex(int index) async {
    if ((index == 0 || index == 3 || index == 4) && !isUserLoggedIn) {
      final featureName = switch (index) {
        0 => 'الملف الشخصي',
        3 => 'طلباتي',
        _ => 'المفضلة',
      };
      await requireLogin(context, featureName: featureName);
      return;
    }

    setState(() {
      currentIndex = index;
      loadedIndexes.add(index);
    });
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return ProfilePage(onFavoritesTap: () => _changeIndex(4));
      case 1:
        return const SearchPage();
      case 2:
        return Home(onSearchTap: () => _changeIndex(1));
      case 3:
        return OrdersPage(active: currentIndex == 3);
      case 4:
        return FavoritesPage(active: currentIndex == 4);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .16),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: .10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.logout,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'الخروج من التطبيق؟',
                      style: TextStyle(
                        color: Color(0xFF151B18),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF747D79),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _ExitDialogButton(
                            title: 'لا',
                            filled: false,
                            onTap: () => Navigator.of(dialogContext).pop(false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ExitDialogButton(
                            title: 'نعم',
                            filled: true,
                            onTap: () => Navigator.of(dialogContext).pop(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => UserCubit(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _confirmExit();
          },
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: currentIndex,
              children: List.generate(
                5,
                (index) =>
                    loadedIndexes.contains(index)
                        ? _buildScreen(index)
                        : const SizedBox.shrink(),
              ),
            ),
            bottomNavigationBar: _FloatingBottomNav(
              currentIndex: currentIndex,
              onTap: _changeIndex,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExitDialogButton extends StatelessWidget {
  const _ExitDialogButton({
    required this.title,
    required this.filled,
    required this.onTap,
  });

  final String title;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? primaryColor : const Color(0xFFF3FAF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled ? primaryColor : primaryColor.withValues(alpha: .24),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: filled ? Colors.white : primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .11),
                blurRadius: 22,
                offset: const Offset(0, -7),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    label: 'البروفايل',
                    icon: Iconsax.user,
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'البحث',
                    icon: Iconsax.search_normal,
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                Expanded(
                  child: _CenterLogoButton(
                    selected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'طلباتي',
                    icon: Iconsax.shopping_bag,
                    selected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'المفضلة',
                    icon: Iconsax.heart,
                    selected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? primaryColor : const Color(0xFF1A1D1B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterLogoButton extends StatelessWidget {
  const _CenterLogoButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? primaryColor : const Color(0xFFE8EDE8),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

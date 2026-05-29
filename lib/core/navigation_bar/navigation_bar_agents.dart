import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/delivery/cubit/delivery_cubit.dart';
import '../../features/delivery/view/delivery_dashboard_page.dart';
import '../../features/delivery/view/delivery_orders_page.dart';
import '../../features/delivery/view/delivery_profile_page.dart';
import '../styles/themes.dart';

class BottomNavBarAgents extends StatefulWidget {
  const BottomNavBarAgents({super.key});

  @override
  State<BottomNavBarAgents> createState() => _BottomNavBarAgentsState();
}

class _BottomNavBarAgentsState extends State<BottomNavBarAgents> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DeliveryProfilePage(),
      const DeliveryDashboardPage(),
      DeliveryOrdersPage(active: currentIndex == 2),
    ];

    return BlocProvider(
      create: (_) => DeliveryCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(index: currentIndex, children: screens),
          bottomNavigationBar: _FloatingBottomNav(
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
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
                    label: 'الحساب',
                    icon: Iconsax.user,
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                Expanded(
                  child: _CenterLogoButton(
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: 'الطلبات',
                    icon: Iconsax.receipt_text,
                    selected: currentIndex == 2,
                    onTap: () => onTap(2),
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

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';
import '../../../core/widgets/constant.dart';
import 'widgets/delivery_ui_widgets.dart';

class DeliveryProfilePage extends StatelessWidget {
  const DeliveryProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const DeliveryHeaderSliver(title: 'حساب الدلفري'),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    decoration: deliverySoftDecoration(radius: 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Color(0xFFEAF5EE),
                          child: Icon(
                            Icons.delivery_dining_rounded,
                            color: primaryColor,
                            size: 27,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حساب الدلفري',
                                style: TextStyle(
                                  color: Color(0xFF151B18),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'إدارة الجلسة ومتابعة الطلبات الموجهة',
                                style: TextStyle(
                                  color: Color(0xFF747D79),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _AccountActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 94),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _AccountButton(
            text: 'تسجيل الخروج',
            icon: Iconsax.logout,
            color: primaryColor,
            onTap: () => signOut(context),
          ),
        ],
      ),
    );
  }
}

class _AccountButton extends StatelessWidget {
  const _AccountButton({
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
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

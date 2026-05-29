import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/styles/themes.dart';
import '../../../../core/widgets/user_nav_header.dart'
    show PinnedAppHeaderSliver;

class DeliveryHeader extends StatelessWidget {
  const DeliveryHeader({super.key, required this.title});

  final String title;

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
                  Text(
                    title,
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Iconsax.notification, size: 22),
            ),
          ],
        ),
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

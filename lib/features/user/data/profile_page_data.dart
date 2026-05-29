import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/styles/themes.dart';

class ProfileStatData {
  const ProfileStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class ProfileAddressData {
  const ProfileAddressData({
    required this.title,
    required this.badge,
    required this.details,
    required this.icon,
    required this.color,
  });

  final String title;
  final String badge;
  final String details;
  final IconData icon;
  final Color color;
}

class ProfileOptionData {
  const ProfileOptionData({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class ProfilePageData {
  const ProfilePageData._();

  static const name = 'أحمد محمد';
  static const phone = '+964 770 123 4567';
  static const memberSince = 'عضو منذ مايو 2024';
  static const avatarUrl =
      'https://images.unsplash.com/photo-1633332755192-727a05c4013d?auto=format&fit=crop&w=300&q=80';

  static const walletBalance = 16500;
  static const points = 120;
  static const redeemText = 'قابل للاستبدال في الطلبات';

  static const stats = [
    ProfileStatData(
      title: 'تقييمي',
      value: '4.8',
      icon: Iconsax.star1,
      color: Color(0xFFFF9517),
    ),
    ProfileStatData(
      title: 'كوبونات',
      value: '4',
      icon: Icons.confirmation_number_outlined,
      color: secondaryColor,
    ),
    ProfileStatData(
      title: 'نقطة',
      value: '120',
      icon: Iconsax.bag_tick,
      color: primaryColor,
    ),
  ];

  static const addresses = [
    ProfileAddressData(
      title: 'المنصور - شارع 14 رمضان',
      badge: 'المنزل',
      details: 'عمارة 23 / الطابق 2 / شقة 5',
      icon: Iconsax.home,
      color: primaryColor,
    ),
    ProfileAddressData(
      title: 'الكرادة - ساحة بيروت',
      badge: 'العمل',
      details: 'مكتب 12 / الطابق 5',
      icon: Iconsax.briefcase,
      color: secondaryColor,
    ),
  ];

  static const options = [
    ProfileOptionData(title: 'معلومات الحساب', icon: Iconsax.user),
    ProfileOptionData(title: 'طرق الدفع', icon: Iconsax.card),
    ProfileOptionData(
      title: 'كوبوناتي',
      icon: Icons.confirmation_number_outlined,
    ),
    ProfileOptionData(title: 'المفضلة', icon: Iconsax.heart),
    ProfileOptionData(title: 'تواصل معنا', icon: Iconsax.headphone),
    ProfileOptionData(title: 'الأسئلة الشائعة', icon: Iconsax.message_question),
  ];
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/styles/themes.dart';

class RestaurantStatData {
  const RestaurantStatData({
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

class RestaurantQuickActionData {
  const RestaurantQuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class RestaurantDeliveryData {
  const RestaurantDeliveryData({
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.status,
    required this.rating,
  });

  final String name;
  final String phone;
  final String vehicle;
  final String status;
  final double rating;
}

class RestaurantCategoryData {
  const RestaurantCategoryData({
    required this.name,
    required this.itemsCount,
    required this.isActive,
  });

  final String name;
  final int itemsCount;
  final bool isActive;

  RestaurantCategoryData copyWith({
    String? name,
    int? itemsCount,
    bool? isActive,
  }) {
    return RestaurantCategoryData(
      name: name ?? this.name,
      itemsCount: itemsCount ?? this.itemsCount,
      isActive: isActive ?? this.isActive,
    );
  }
}

class RestaurantMealData {
  const RestaurantMealData({
    required this.name,
    required this.category,
    required this.price,
    required this.orders,
    required this.isAvailable,
    required this.imageUrl,
  });

  final String name;
  final String category;
  final int price;
  final int orders;
  final bool isAvailable;
  final String imageUrl;

  RestaurantMealData copyWith({
    String? name,
    String? category,
    int? price,
    int? orders,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return RestaurantMealData(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      orders: orders ?? this.orders,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class RestaurantDashboardData {
  const RestaurantDashboardData._();

  static const restaurantName = 'بيت الشاورما';
  static const restaurantSubtitle = 'شاورما، ساندويشات، عربي';
  static const coverUrl =
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80';

  static const stats = [
    RestaurantStatData(
      title: 'طلبات اليوم',
      value: '24',
      icon: Iconsax.receipt_text,
      color: primaryColor,
    ),
    RestaurantStatData(
      title: 'المبيعات',
      value: '168K',
      icon: Iconsax.wallet_3,
      color: secondaryColor,
    ),
    RestaurantStatData(
      title: 'التقييم',
      value: '4.8',
      icon: Iconsax.star,
      color: Color(0xFFFFA51E),
    ),
  ];

  static const quickActions = [
    RestaurantQuickActionData(
      title: 'إضافة دلفري',
      subtitle: 'دلفرية خاصة بالمطعم',
      icon: Icons.delivery_dining_rounded,
      color: primaryColor,
    ),
    RestaurantQuickActionData(
      title: 'إضافة أكلة',
      subtitle: 'وجبة جديدة للقائمة',
      icon: Iconsax.reserve,
      color: secondaryColor,
    ),
    RestaurantQuickActionData(
      title: 'إضافة قسم',
      subtitle: 'تنظيم قائمة الطعام',
      icon: Iconsax.category,
      color: Color(0xFF2D8AC8),
    ),
  ];

  static const deliveries = [
    RestaurantDeliveryData(
      name: 'أحمد علي',
      phone: '0770 123 4567',
      vehicle: 'دراجة',
      status: 'متاح',
      rating: 4.8,
    ),
    RestaurantDeliveryData(
      name: 'حسين كرار',
      phone: '0781 555 2211',
      vehicle: 'سيارة',
      status: 'في طلب',
      rating: 4.6,
    ),
  ];

  static const categories = [
    RestaurantCategoryData(name: 'شاورما', itemsCount: 8, isActive: true),
    RestaurantCategoryData(name: 'ساندويشات', itemsCount: 12, isActive: true),
    RestaurantCategoryData(name: 'مقبلات', itemsCount: 6, isActive: true),
  ];

  static const meals = [
    RestaurantMealData(
      name: 'صحن شاورما دجاج',
      category: 'شاورما',
      price: 7500,
      orders: 46,
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=700&q=80',
    ),
    RestaurantMealData(
      name: 'ساندويش شاورما لحم',
      category: 'ساندويشات',
      price: 6000,
      orders: 31,
      isAvailable: true,
      imageUrl:
          'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=700&q=80',
    ),
    RestaurantMealData(
      name: 'بطاطا مقلية',
      category: 'مقبلات',
      price: 3000,
      orders: 18,
      isAvailable: false,
      imageUrl:
          'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=700&q=80',
    ),
  ];
}

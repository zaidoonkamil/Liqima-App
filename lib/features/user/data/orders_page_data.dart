import 'package:flutter/material.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

enum UserOrderStatus {
  all,
  preparing,
  readyForPickup,
  onWay,
  delivered,
  canceled,
}

class OrderFilterData {
  const OrderFilterData({
    required this.title,
    required this.icon,
    required this.status,
  });

  final String title;
  final IconData icon;
  final UserOrderStatus status;
}

class RecentOrderData {
  const RecentOrderData({
    required this.name,
    required this.number,
    required this.logoUrl,
  });

  final String name;
  final String number;
  final String logoUrl;
}

class OrderCardData {
  const OrderCardData({
    required this.orderNumber,
    required this.restaurantName,
    required this.restaurantType,
    required this.logoUrl,
    required this.status,
    required this.statusText,
    required this.statusTitle,
    required this.statusDescription,
    required this.dateText,
    required this.timeText,
    required this.itemsText,
    required this.price,
    required this.sideIcon,
    required this.primaryAction,
    this.secondaryAction,
    this.rating,
    this.canceledText,
  });

  final String orderNumber;
  final String restaurantName;
  final String restaurantType;
  final String logoUrl;
  final UserOrderStatus status;
  final String statusText;
  final String statusTitle;
  final String statusDescription;
  final String dateText;
  final String timeText;
  final String itemsText;
  final int price;
  final IconData sideIcon;
  final String primaryAction;
  final String? secondaryAction;
  final double? rating;
  final String? canceledText;

  factory OrderCardData.fromJson(Map<String, dynamic> json) {
    final restaurant = _asMap(json['restaurant']);
    final profile = _asMap(restaurant['restaurantProfile']);
    final status = _mapStatus(json['status']);
    final statusText = _statusText(status);
    return OrderCardData(
      orderNumber:
          '#${_asString(json['orderNumber'], fallback: _asString(json['id'], fallback: ''))}',
      restaurantName: _asString(restaurant['name'], fallback: 'مطعم'),
      restaurantType: _restaurantType(json),
      logoUrl:
          _nullableAssetUrl(profile['logo'] ?? restaurant['image']) ??
          'https://liqima.napoltech.com/uploads/logo.png',
      status: status,
      statusText: statusText,
      statusTitle: _statusTitle(status),
      statusDescription: _statusDescription(status, json),
      dateText: _dateText(json['createdAt']),
      timeText: _timeText(status, json),
      itemsText: _asString(json['itemSummary'], fallback: _itemsText(json)),
      price: _asInt(json['total']),
      sideIcon: _sideIcon(status),
      primaryAction: _primaryAction(status),
      secondaryAction: status == UserOrderStatus.onWay ? 'اتصل بالمندوب' : null,
      canceledText: status == UserOrderStatus.canceled ? 'تم الإلغاء' : null,
    );
  }
}

class UserOrdersApiData {
  const UserOrdersApiData({required this.orders});

  final List<OrderCardData> orders;

  List<RecentOrderData> get recentOrders {
    return orders
        .take(8)
        .map(
          (order) => RecentOrderData(
            name: order.restaurantName,
            number: order.orderNumber,
            logoUrl: order.logoUrl,
          ),
        )
        .toList();
  }
}

class UserOrdersRepository {
  const UserOrdersRepository();

  Future<UserOrdersApiData> getOrders() async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    final response = await DioHelper.getData(
      url: '/orders',
      token: token,
      query: {'userId': userId, 'limit': 80},
    );
    final data = _asMap(response.data);
    final rawOrders =
        data['orders'] is List ? data['orders'] as List : const [];
    return UserOrdersApiData(
      orders:
          rawOrders
              .map((item) => OrderCardData.fromJson(_asMap(item)))
              .toList(),
    );
  }
}

class OrdersPageData {
  const OrdersPageData._();

  static const filters = [
    OrderFilterData(
      title: 'الكل',
      icon: Icons.receipt_long_outlined,
      status: UserOrderStatus.all,
    ),
    OrderFilterData(
      title: 'قيد التحضير',
      icon: Icons.takeout_dining_outlined,
      status: UserOrderStatus.preparing,
    ),
    OrderFilterData(
      title: 'جاهز',
      icon: Icons.inventory_2_outlined,
      status: UserOrderStatus.readyForPickup,
    ),
    OrderFilterData(
      title: 'في الطريق',
      icon: Icons.delivery_dining_rounded,
      status: UserOrderStatus.onWay,
    ),
    OrderFilterData(
      title: 'تم التوصيل',
      icon: Icons.check_circle_outline_rounded,
      status: UserOrderStatus.delivered,
    ),
    OrderFilterData(
      title: 'ملغي',
      icon: Icons.cancel_outlined,
      status: UserOrderStatus.canceled,
    ),
  ];

  static const orders = [
    OrderCardData(
      orderNumber: '#12458',
      restaurantName: 'بيت الشاورما',
      restaurantType: 'شاورما · ساندويشات · عربي',
      logoUrl:
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=300&q=80',
      status: UserOrderStatus.preparing,
      statusText: 'قيد التحضير',
      statusTitle: 'جاري تحضير طلبك',
      statusDescription: 'سيتم إشعارك عند تجهيز الطلب',
      dateText: 'اليوم، 9:20 م',
      timeText: '25-35 دقيقة',
      itemsText: '1x دجاج مشوي مع رز · 1x ساندويش شاورما لحم · 1x بطاطا',
      price: 16500,
      sideIcon: Icons.takeout_dining_outlined,
      primaryAction: 'عرض التفاصيل',
    ),
    OrderCardData(
      orderNumber: '#12420',
      restaurantName: 'برغر تايم',
      restaurantType: 'برغر · وجبات سريعة · بطاطا',
      logoUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=300&q=80',
      status: UserOrderStatus.onWay,
      statusText: 'في الطريق',
      statusTitle: 'الطلب في طريقه إليك',
      statusDescription: 'المندوب: أحمد',
      dateText: 'أمس، 8:15 م',
      timeText: '15-20 دقيقة',
      itemsText: '1x تشكن برغر · 1x بطاطا مقلية · 1x مشروب غازي',
      price: 12000,
      sideIcon: Icons.delivery_dining_rounded,
      primaryAction: 'تتبع الطلب',
      secondaryAction: 'اتصل بالمندوب',
      rating: 4.8,
    ),
    OrderCardData(
      orderNumber: '#12380',
      restaurantName: 'بيتزا روما',
      restaurantType: 'بيتزا · مكونات · سلطات',
      logoUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=300&q=80',
      status: UserOrderStatus.delivered,
      statusText: 'تم التوصيل',
      statusTitle: 'تم التوصيل',
      statusDescription: 'شكراً لاستخدامك لگمة',
      dateText: 'أمس، 7:30 م',
      timeText: 'تم التوصيل في 8:45 م',
      itemsText: '1x بيتزا مارجريتا · 1x خبز بالثوم · 1x مشروب غازي',
      price: 13000,
      sideIcon: Icons.check_rounded,
      primaryAction: 'إعادة الطلب',
    ),
    OrderCardData(
      orderNumber: '#12310',
      restaurantName: 'مشاوي الخليج',
      restaurantType: 'مشويات · كباب · عراقي',
      logoUrl:
          'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=300&q=80',
      status: UserOrderStatus.canceled,
      statusText: 'ملغي',
      statusTitle: 'تم إلغاء الطلب',
      statusDescription: 'تم إلغاء الطلب',
      dateText: 'السبت، 6:10 م',
      timeText: '',
      itemsText: '',
      price: 10000,
      sideIcon: Icons.close_rounded,
      primaryAction: 'طلب مرة أخرى',
      canceledText: 'تم الإلغاء',
    ),
  ];

  static const recentOrders = [
    RecentOrderData(
      name: 'برغر تايم',
      number: '#12420',
      logoUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=300&q=80',
    ),
    RecentOrderData(
      name: 'بيت الشاورما',
      number: '#12458',
      logoUrl:
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=300&q=80',
    ),
    RecentOrderData(
      name: 'بيتزا روما',
      number: '#12380',
      logoUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=300&q=80',
    ),
    RecentOrderData(
      name: 'مشاوي الخليج',
      number: '#12310',
      logoUrl:
          'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=300&q=80',
    ),
    RecentOrderData(
      name: 'شاورما الأمير',
      number: '#12220',
      logoUrl:
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=300&q=80',
    ),
  ];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return [];
}

String _asString(dynamic value, {required String fallback}) {
  if (value == null || value.toString().trim().isEmpty) return fallback;
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _nullableAssetUrl(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  if (text.startsWith('http')) return text;
  return 'https://liqima.napoltech.com/uploads/$text';
}

UserOrderStatus _mapStatus(dynamic value) {
  return switch (value?.toString()) {
    'ready_for_pickup' => UserOrderStatus.readyForPickup,
    'on_way' => UserOrderStatus.onWay,
    'delivered' => UserOrderStatus.delivered,
    'cancelled' || 'canceled' => UserOrderStatus.canceled,
    _ => UserOrderStatus.preparing,
  };
}

String _statusText(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.preparing => 'قيد التحضير',
    UserOrderStatus.readyForPickup => 'جاهز للاستلام',
    UserOrderStatus.onWay => 'في الطريق',
    UserOrderStatus.delivered => 'تم التوصيل',
    UserOrderStatus.canceled => 'ملغي',
    UserOrderStatus.all => 'الكل',
  };
}

String _statusTitle(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.preparing => 'جاري تحضير طلبك',
    UserOrderStatus.readyForPickup => 'طلبك جاهز للاستلام',
    UserOrderStatus.onWay => 'الطلب في طريقه إليك',
    UserOrderStatus.delivered => 'تم التوصيل',
    UserOrderStatus.canceled => 'تم إلغاء الطلب',
    UserOrderStatus.all => 'الطلب',
  };
}

String _statusDescription(UserOrderStatus status, Map<String, dynamic> json) {
  final delivery = _asMap(json['delivery']);
  return switch (status) {
    UserOrderStatus.preparing => 'سيتم إشعارك عند تجهيز الطلب',
    UserOrderStatus.readyForPickup =>
      delivery.isEmpty
          ? 'بانتظار توجيه الدلفري'
          : 'تم توجيهه إلى: ${_asString(delivery['name'], fallback: 'الدلفري')}',
    UserOrderStatus.onWay =>
      delivery.isEmpty
          ? 'المندوب في الطريق'
          : 'المندوب: ${_asString(delivery['name'], fallback: '')}',
    UserOrderStatus.delivered => 'شكراً لاستخدامك لگمة',
    UserOrderStatus.canceled => 'تم إلغاء الطلب',
    UserOrderStatus.all => '',
  };
}

String _primaryAction(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.onWay => 'تتبع الطلب',
    UserOrderStatus.delivered => 'إعادة الطلب',
    UserOrderStatus.canceled => 'طلب مرة أخرى',
    _ => 'عرض التفاصيل',
  };
}

IconData _sideIcon(UserOrderStatus status) {
  return switch (status) {
    UserOrderStatus.readyForPickup => Icons.inventory_2_outlined,
    UserOrderStatus.onWay => Icons.delivery_dining_rounded,
    UserOrderStatus.delivered => Icons.check_rounded,
    UserOrderStatus.canceled => Icons.close_rounded,
    _ => Icons.takeout_dining_outlined,
  };
}

String _restaurantType(Map<String, dynamic> json) {
  final items = _asList(json['items']);
  final names = <String>{};
  for (final item in items) {
    final product = _asMap(_asMap(item)['product']);
    final category = _asMap(product['category']);
    final name = _asString(category['name'], fallback: '');
    if (name.isNotEmpty) names.add(name);
  }
  return names.isEmpty ? 'مطعم' : names.take(3).join(' · ');
}

String _itemsText(Map<String, dynamic> json) {
  final items = _asList(json['items']);
  return items
      .map((item) {
        final map = _asMap(item);
        final product = _asMap(map['product']);
        return '${_asInt(map['quantity'])}x ${_asString(product['name'], fallback: 'وجبة')}';
      })
      .join(' · ');
}

String _dateText(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '';
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  final isYesterday =
      date.year == now.subtract(const Duration(days: 1)).year &&
      date.month == now.subtract(const Duration(days: 1)).month &&
      date.day == now.subtract(const Duration(days: 1)).day;
  final day =
      isToday ? 'اليوم' : (isYesterday ? 'أمس' : '${date.month}/${date.day}');
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'م' : 'ص';
  return '$day، $hour:$minute $suffix';
}

String _timeText(UserOrderStatus status, Map<String, dynamic> json) {
  if (status == UserOrderStatus.delivered) {
    final deliveredAt = _clockText(json['deliveredAt']);
    return deliveredAt.isEmpty ? 'تم التوصيل' : 'تم التوصيل في $deliveredAt';
  }
  if (status == UserOrderStatus.canceled) return '';
  if (status == UserOrderStatus.onWay) {
    final onWayAt = _clockText(json['onWayAt']);
    return onWayAt.isEmpty ? 'في الطريق' : 'انطلق في $onWayAt';
  }
  if (status == UserOrderStatus.readyForPickup) {
    final readyAt = _clockText(json['readyForPickupAt']);
    return readyAt.isEmpty ? 'جاهز للاستلام' : 'جاهز منذ $readyAt';
  }
  return '25-35 دقيقة';
}

String _clockText(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '';
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'م' : 'ص';
  return '$hour:$minute $suffix';
}

import 'package:flutter/material.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/constant.dart';

enum CouponStatus { available, expired }

class CouponsRepository {
  const CouponsRepository();

  Future<UserCouponsData> getCoupons() async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    final response = await DioHelper.getData(
      url: '/users/$userId/coupons',
      token: token,
    );
    return UserCouponsData.fromJson(_asMap(response.data));
  }
}

class UserCouponsData {
  const UserCouponsData({
    required this.total,
    required this.availableCount,
    required this.expiredCount,
    required this.totalSavings,
    required this.availableCoupons,
    required this.expiredCoupons,
  });

  final int total;
  final int availableCount;
  final int expiredCount;
  final int totalSavings;
  final List<CouponCardData> availableCoupons;
  final List<CouponCardData> expiredCoupons;

  factory UserCouponsData.fromJson(Map<String, dynamic> json) {
    final summary = _asMap(json['summary']);
    return UserCouponsData(
      total: _asInt(summary['total']),
      availableCount: _asInt(summary['available']),
      expiredCount: _asInt(summary['expired']),
      totalSavings: _asInt(summary['totalSavings']),
      availableCoupons:
          _asList(
            json['available'],
          ).map((item) => CouponCardData.fromJson(_asMap(item))).toList(),
      expiredCoupons:
          _asList(json['expired'])
              .map(
                (item) => CouponCardData.fromJson(
                  _asMap(item),
                  fallbackExpired: true,
                ),
              )
              .toList(),
    );
  }
}

class CouponCardData {
  const CouponCardData({
    required this.title,
    required this.subtitle,
    required this.minimumOrder,
    required this.code,
    required this.validUntil,
    required this.badge,
    required this.color,
    required this.status,
  });

  final String title;
  final String subtitle;
  final int minimumOrder;
  final String code;
  final String validUntil;
  final String badge;
  final Color color;
  final CouponStatus status;

  factory CouponCardData.fromJson(
    Map<String, dynamic> json, {
    bool fallbackExpired = false,
  }) {
    final type = _asString(json['type'], fallback: 'percentage');
    final isExpired = _asBool(json['isExpired'], fallback: fallbackExpired);
    final value = _asInt(json['value']);
    return CouponCardData(
      title: _asString(json['title'], fallback: _titleFor(type, value)),
      subtitle: _subtitleFor(json),
      minimumOrder: _asInt(json['minimumOrder']),
      code: _asString(json['code'], fallback: ''),
      validUntil: _validUntil(json['expiresAt'], isExpired: isExpired),
      badge: isExpired ? 'منتهي' : _badgeFor(type),
      color:
          isExpired
              ? const Color(0xFF8E908F)
              : type == 'percentage'
              ? secondaryColor
              : primaryColor,
      status: isExpired ? CouponStatus.expired : CouponStatus.available,
    );
  }
}

String _titleFor(String type, int value) {
  if (type == 'free_delivery') return 'توصيل مجاني';
  if (type == 'fixed') return 'خصم د.ع ${_formatPrice(value)}';
  return 'خصم $value%';
}

String _badgeFor(String type) {
  if (type == 'free_delivery') return 'توصيل مجاني';
  if (type == 'fixed') return 'خصم ثابت';
  return 'خصم على الطلب';
}

String _subtitleFor(Map<String, dynamic> json) {
  final restaurant = _asMap(json['restaurant']);
  final target = _asString(json['target'], fallback: 'all');
  if (target == 'restaurant') {
    return 'خاص بمطعم ${_asString(restaurant['name'], fallback: 'محدد')}';
  }
  return _asString(json['description'], fallback: 'على جميع المطاعم');
}

String _validUntil(dynamic value, {required bool isExpired}) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return isExpired ? 'منتهي' : 'بدون انتهاء';
  final text = '${date.year}/${date.month}/${date.day}';
  return isExpired ? 'انتهى في $text' : 'صالح حتى $text';
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

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  return value.toString() == 'true' || value.toString() == '1';
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

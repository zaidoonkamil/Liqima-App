class AdminCouponCategoryModel {
  const AdminCouponCategoryModel({
    required this.id,
    required this.name,
    required this.key,
    required this.isActive,
  });

  final int id;
  final String name;
  final String key;
  final bool isActive;

  factory AdminCouponCategoryModel.fromJson(Map<String, dynamic> json) {
    return AdminCouponCategoryModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'قسم'),
      key: _asString(json['key'], fallback: ''),
      isActive: _asBool(json['isActive'], fallback: true),
    );
  }
}

class AdminCouponModel {
  const AdminCouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.isActive,
    required this.minimumOrder,
    required this.maxDiscount,
    required this.totalUsageLimit,
    required this.perUserLimit,
    required this.usedCount,
    required this.target,
    required this.restaurantId,
    required this.categoryId,
    required this.startsAt,
    required this.expiresAt,
    required this.restaurantName,
    required this.categoryName,
  });

  final int id;
  final String code;
  final String title;
  final String description;
  final String type;
  final int value;
  final bool isActive;
  final int minimumOrder;
  final int? maxDiscount;
  final int? totalUsageLimit;
  final int perUserLimit;
  final int usedCount;
  final String target;
  final int? restaurantId;
  final int? categoryId;
  final String startsAt;
  final String expiresAt;
  final String restaurantName;
  final String categoryName;

  String get typeLabel {
    if (type == 'free_delivery') return 'توصيل مجاني';
    if (type == 'fixed') return 'خصم ثابت';
    return 'خصم نسبة';
  }

  String get valueText {
    if (type == 'free_delivery') return 'مجاني';
    if (type == 'fixed') return 'د.ع ${_formatPrice(value)}';
    return '$value%';
  }

  String get targetLabel =>
      target == 'restaurant' ? restaurantName : 'كل المطاعم';

  factory AdminCouponModel.fromJson(Map<String, dynamic> json) {
    final restaurant = _asMap(json['restaurant']);
    final category = _asMap(json['category']);
    return AdminCouponModel(
      id: _asInt(json['id']),
      code: _asString(json['code'], fallback: ''),
      title: _asString(json['title'], fallback: 'كوبون'),
      description: _asString(json['description'], fallback: ''),
      type: _asString(json['type'], fallback: 'percentage'),
      value: _asInt(json['value']),
      isActive: _asBool(json['isActive'], fallback: true),
      minimumOrder: _asInt(json['minimumOrder']),
      maxDiscount: _nullableInt(json['maxDiscount']),
      totalUsageLimit: _nullableInt(json['totalUsageLimit']),
      perUserLimit: _asInt(json['perUserLimit']),
      usedCount: _asInt(json['usedCount']),
      target: _asString(json['target'], fallback: 'all'),
      restaurantId: _nullableInt(json['restaurantId']),
      categoryId: _nullableInt(json['couponCategoryId']),
      startsAt: _dateInput(json['startsAt']),
      expiresAt: _dateInput(json['expiresAt']),
      restaurantName: _asString(restaurant['name'], fallback: 'مطعم محدد'),
      categoryName: _asString(category['name'], fallback: 'بدون قسم'),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
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

int? _nullableInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return _asInt(value);
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  return value.toString() == 'true' || value.toString() == '1';
}

String _dateInput(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '';
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatPrice(int price) {
  final value = price.toString();
  return value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

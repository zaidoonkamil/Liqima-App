class DeliveryDashboardModel {
  const DeliveryDashboardModel({
    required this.delivery,
    required this.stats,
    required this.recentOrders,
  });

  final DeliveryInfoModel delivery;
  final DeliveryStatsModel stats;
  final List<DeliveryOrderModel> recentOrders;

  factory DeliveryDashboardModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDashboardModel(
      delivery: DeliveryInfoModel.fromJson(_asMap(json['delivery'])),
      stats: DeliveryStatsModel.fromJson(_asMap(json['stats'])),
      recentOrders:
          _asList(
            json['recentOrders'],
          ).map((item) => DeliveryOrderModel.fromJson(_asMap(item))).toList(),
    );
  }
}

class DeliveryInfoModel {
  const DeliveryInfoModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.isAvailable,
    required this.status,
    required this.rating,
  });

  final int id;
  final String name;
  final String phone;
  final String vehicleType;
  final bool isAvailable;
  final String status;
  final double rating;

  factory DeliveryInfoModel.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['deliveryProfile']);
    return DeliveryInfoModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'دلفري'),
      phone: _asString(json['phone'], fallback: ''),
      vehicleType: _asString(profile['vehicleType'], fallback: 'دراجة'),
      isAvailable: _asBool(profile['isAvailable'], fallback: true),
      status: _asString(profile['status'], fallback: 'active'),
      rating: _asDouble(json['rating'] ?? profile['rating']),
    );
  }
}

class DeliveryStatsModel {
  const DeliveryStatsModel({
    required this.todayOrders,
    required this.activeOrders,
    required this.deliveredToday,
    required this.todayRevenue,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalTrips,
    required this.maxDistanceKm,
  });

  final int todayOrders;
  final int activeOrders;
  final int deliveredToday;
  final int todayRevenue;
  final int totalRevenue;
  final int totalOrders;
  final int totalTrips;
  final double maxDistanceKm;

  factory DeliveryStatsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryStatsModel(
      todayOrders: _asInt(json['todayOrders']),
      activeOrders: _asInt(json['activeOrders']),
      deliveredToday: _asInt(json['deliveredToday']),
      todayRevenue: _asInt(json['todayRevenue']),
      totalRevenue: _asInt(json['totalRevenue']),
      totalOrders: _asInt(json['totalOrders']),
      totalTrips: _asInt(json['totalTrips']),
      maxDistanceKm: _asDouble(json['maxDistanceKm']),
    );
  }
}

class DeliveryOrderModel {
  const DeliveryOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.deliveryFee,
    required this.itemSummary,
    required this.customerName,
    required this.restaurantName,
    required this.phone,
    required this.address,
    required this.createdAtText,
  });

  final int id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final int total;
  final int deliveryFee;
  final String itemSummary;
  final String customerName;
  final String restaurantName;
  final String phone;
  final String address;
  final String createdAtText;

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final restaurant = _asMap(json['restaurant']);
    final items =
        _asList(
          json['items'],
        ).map((item) => DeliveryOrderItemModel.fromJson(_asMap(item))).toList();
    final summary = _asString(json['itemSummary'], fallback: '');

    return DeliveryOrderModel(
      id: _asInt(json['id']),
      orderNumber: _asString(
        json['orderNumber'],
        fallback: '#${_asInt(json['id'])}',
      ),
      status: _asString(json['status'], fallback: 'ready_for_pickup'),
      statusLabel: _statusLabel(_asString(json['status'], fallback: '')),
      total: _asInt(json['total']),
      deliveryFee: _asInt(json['deliveryFee']),
      itemSummary:
          summary.isEmpty
              ? items
                  .map((item) => '${item.quantity}x ${item.name}')
                  .join(' · ')
              : summary,
      customerName: _asString(user['name'], fallback: 'زبون'),
      restaurantName: _asString(restaurant['name'], fallback: 'مطعم'),
      phone: _asString(json['phone'] ?? user['phone'], fallback: ''),
      address: _asString(json['address'], fallback: 'بدون عنوان'),
      createdAtText: _formatDateText(json['createdAt']),
    );
  }
}

class DeliveryOrderItemModel {
  const DeliveryOrderItemModel({required this.name, required this.quantity});

  final String name;
  final int quantity;

  factory DeliveryOrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    return DeliveryOrderItemModel(
      name: _asString(product['name'], fallback: 'أكلة'),
      quantity: _asInt(json['quantity']),
    );
  }
}

String _statusLabel(String status) {
  return switch (status) {
    'ready_for_pickup' => 'جاهز للاستلام',
    'on_way' => 'في الطريق',
    'delivered' => 'تم التوصيل',
    'cancelled' => 'ملغي',
    'pending' => 'طلب جديد',
    'accepted' => 'مقبول',
    'preparing' => 'قيد التحضير',
    _ => status,
  };
}

String _formatDateText(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '';
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}/${date.month}/${date.day} - $hour:$minute';
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

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  return value.toString() == 'true' || value.toString() == '1';
}

import 'dart:convert';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

class CartRepository {
  const CartRepository();

  Future<CartApiData> getCart() async {
    final userId = _userId();
    final response = await DioHelper.getData(
      url: '/users/$userId/cart',
      token: token,
    );
    return CartApiData.fromJson(_asMap(response.data));
  }

  Future<CartApiData> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    final userId = _userId();
    final response = await DioHelper.patchData(
      url: '/users/$userId/cart/items/$itemId',
      token: token,
      data: {'quantity': quantity},
    );
    return CartApiData.fromJson(_asMap(response.data));
  }

  Future<CartApiData> removeItem(int itemId) async {
    final userId = _userId();
    final response = await DioHelper.deleteData(
      url: '/users/$userId/cart/items/$itemId',
      token: token,
    );
    return CartApiData.fromJson(_asMap(response.data));
  }

  Future<CartApiData> applyCoupon(String code) async {
    final userId = _userId();
    final response = await DioHelper.postData(
      url: '/users/$userId/cart/apply-coupon',
      token: token,
      data: {'code': code.trim()},
    );
    return CartApiData.fromJson(_asMap(response.data));
  }

  Future<Map<String, dynamic>> checkout({
    required int addressId,
    String paymentMethod = 'cash',
    String? couponCode,
  }) async {
    final userId = _userId();
    final response = await DioHelper.postData(
      url: '/users/$userId/checkout',
      token: token,
      data: {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim(),
      },
    );
    return _asMap(response.data);
  }

  int _userId() {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');
    return userId;
  }
}

class CartApiData {
  const CartApiData({
    required this.items,
    required this.summary,
    this.restaurant,
  });

  final List<CartItemData> items;
  final CartSummaryData summary;
  final CartRestaurantData? restaurant;

  bool get isEmpty => items.isEmpty;

  CartApiData copyWith({
    List<CartItemData>? items,
    CartSummaryData? summary,
    CartRestaurantData? restaurant,
  }) {
    return CartApiData(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      restaurant: restaurant ?? this.restaurant,
    );
  }

  factory CartApiData.fromJson(Map<String, dynamic> json) {
    final basket = _asMap(json['basket']);
    final items =
        _asList(basket['items'])
            .map((item) => CartItemData.fromJson(_asMap(item)))
            .where((item) => item.id != 0)
            .toList();
    return CartApiData(
      items: items,
      summary: CartSummaryData.fromJson(_asMap(json['summary'])),
      restaurant:
          json['restaurant'] == null
              ? null
              : CartRestaurantData.fromJson(_asMap(json['restaurant'])),
    );
  }
}

class CartSummaryData {
  const CartSummaryData({
    required this.itemsCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.deliveryFeeBeforeDiscount,
    required this.discountAmount,
    required this.total,
    required this.minimumOrder,
    required this.remainingToMinimumOrder,
    required this.freeDelivery,
    required this.restaurantDeliveryFee,
    required this.appDeliveryFee,
    required this.deliveryDistanceKm,
    required this.freeDeliveryDistanceKm,
    required this.deliveryPricePerKm,
    required this.withinFreeDeliveryDistance,
    required this.canCheckout,
    this.couponCode,
  });

  final int itemsCount;
  final int subtotal;
  final int deliveryFee;
  final int deliveryFeeBeforeDiscount;
  final int discountAmount;
  final int total;
  final int minimumOrder;
  final int remainingToMinimumOrder;
  final bool freeDelivery;
  final int restaurantDeliveryFee;
  final int appDeliveryFee;
  final double? deliveryDistanceKm;
  final double freeDeliveryDistanceKm;
  final int deliveryPricePerKm;
  final bool withinFreeDeliveryDistance;
  final bool canCheckout;
  final String? couponCode;

  double get minimumProgress {
    if (minimumOrder <= 0) return 1;
    return (subtotal / minimumOrder).clamp(0, 1).toDouble();
  }

  CartSummaryData copyWith({
    int? itemsCount,
    int? subtotal,
    int? deliveryFee,
    int? deliveryFeeBeforeDiscount,
    int? discountAmount,
    int? total,
    int? minimumOrder,
    int? remainingToMinimumOrder,
    bool? freeDelivery,
    int? restaurantDeliveryFee,
    int? appDeliveryFee,
    double? deliveryDistanceKm,
    double? freeDeliveryDistanceKm,
    int? deliveryPricePerKm,
    bool? withinFreeDeliveryDistance,
    bool? canCheckout,
    String? couponCode,
  }) {
    return CartSummaryData(
      itemsCount: itemsCount ?? this.itemsCount,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryFeeBeforeDiscount:
          deliveryFeeBeforeDiscount ?? this.deliveryFeeBeforeDiscount,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      remainingToMinimumOrder:
          remainingToMinimumOrder ?? this.remainingToMinimumOrder,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      restaurantDeliveryFee:
          restaurantDeliveryFee ?? this.restaurantDeliveryFee,
      appDeliveryFee: appDeliveryFee ?? this.appDeliveryFee,
      deliveryDistanceKm: deliveryDistanceKm ?? this.deliveryDistanceKm,
      freeDeliveryDistanceKm:
          freeDeliveryDistanceKm ?? this.freeDeliveryDistanceKm,
      deliveryPricePerKm: deliveryPricePerKm ?? this.deliveryPricePerKm,
      withinFreeDeliveryDistance:
          withinFreeDeliveryDistance ?? this.withinFreeDeliveryDistance,
      canCheckout: canCheckout ?? this.canCheckout,
      couponCode: couponCode ?? this.couponCode,
    );
  }

  factory CartSummaryData.fromJson(Map<String, dynamic> json) {
    return CartSummaryData(
      itemsCount: _asInt(json['itemsCount']),
      subtotal: _asInt(json['subtotal']),
      deliveryFee: _asInt(json['deliveryFee']),
      deliveryFeeBeforeDiscount: _asInt(json['deliveryFeeBeforeDiscount']),
      discountAmount: _asInt(json['discountAmount']),
      total: _asInt(json['total']),
      minimumOrder: _asInt(json['minimumOrder']),
      remainingToMinimumOrder: _asInt(json['remainingToMinimumOrder']),
      freeDelivery: _asBool(json['freeDelivery']),
      restaurantDeliveryFee: _asInt(json['restaurantDeliveryFee']),
      appDeliveryFee: _asInt(json['appDeliveryFee']),
      deliveryDistanceKm: _nullableDouble(json['deliveryDistanceKm']),
      freeDeliveryDistanceKm: _asDouble(json['freeDeliveryDistanceKm']),
      deliveryPricePerKm: _asInt(json['deliveryPricePerKm']),
      withinFreeDeliveryDistance: _asBool(json['withinFreeDeliveryDistance']),
      canCheckout: _asBool(json['canCheckout']),
      couponCode: _nullableString(json['couponCode']),
    );
  }
}

class CartRestaurantData {
  const CartRestaurantData({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.distance,
    required this.deliveryTime,
    required this.minimumOrder,
    required this.freeDelivery,
  });

  final int id;
  final String name;
  final String logoUrl;
  final String distance;
  final String deliveryTime;
  final int minimumOrder;
  final bool freeDelivery;

  factory CartRestaurantData.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['restaurantProfile']);
    final min = _nullableInt(profile['deliveryTimeMin']);
    final max = _nullableInt(profile['deliveryTimeMax']);
    return CartRestaurantData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'مطعم'),
      logoUrl:
          _nullableAssetUrl(profile['logo'] ?? json['image']) ??
          'https://liqima.napoltech.com/uploads/logo.png',
      distance: 'قريب',
      deliveryTime: _timeText(min, max),
      minimumOrder: _asInt(profile['minimumOrder']),
      freeDelivery: _asBool(profile['freeDelivery']),
    );
  }
}

class CartItemData {
  const CartItemData({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.addonsTotal,
    this.oldPrice,
    this.selectedSize,
  });

  final int id;
  final int productId;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final int quantity;
  final int addonsTotal;
  final int? oldPrice;
  final String? selectedSize;

  int get lineTotal => (price + addonsTotal) * quantity;

  int get unitTotal => price + addonsTotal;

  CartItemData copyWith({int? quantity}) {
    return CartItemData(
      id: id,
      productId: productId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
      addonsTotal: addonsTotal,
      oldPrice: oldPrice,
      selectedSize: selectedSize,
    );
  }

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    final images = _asList(product['images']);
    final price = _asInt(product['discountPrice'] ?? product['price']);
    final oldPrice =
        product['discountPrice'] == null ? null : _asInt(product['price']);
    final addons = _asList(json['selectedAddons'])
        .map((item) => _asMap(item))
        .fold<int>(0, (sum, addon) => sum + _asInt(addon['price']));
    return CartItemData(
      id: _asInt(json['id']),
      productId: _asInt(json['productId']),
      name: _asString(product['name'], fallback: 'وجبة'),
      description: _asString(product['description'], fallback: ''),
      imageUrl:
          images.isEmpty
              ? 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=500&q=80'
              : _assetUrl(images.first),
      price: price,
      quantity: _asInt(json['quantity'], fallback: 1),
      addonsTotal: addons,
      oldPrice: oldPrice,
      selectedSize: _nullableString(json['selectedSize']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) return decoded;
    } catch (_) {
      return [];
    }
  }
  return [];
}

String _asString(dynamic value, {required String fallback}) {
  if (value == null || value.toString().trim().isEmpty) return fallback;
  return value.toString();
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return _asInt(value);
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableDouble(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return _asDouble(value);
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  return value.toString() == 'true' || value.toString() == '1';
}

String _timeText(int? min, int? max) {
  if (min == null && max == null) return '25-35 دقيقة';
  if (min != null && max != null) return '$min-$max دقيقة';
  return '${min ?? max} دقيقة';
}

String? _nullableAssetUrl(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.isEmpty) return null;
  return _assetUrl(text);
}

String _assetUrl(dynamic value) {
  final text = value.toString();
  if (text.startsWith('http')) return text;
  return 'https://liqima.napoltech.com/uploads/$text';
}

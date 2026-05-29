import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

class MealDetailsRepository {
  const MealDetailsRepository();

  Future<MealDetailsData> getMeal(int productId) async {
    final response = await DioHelper.getData(
      url: '/products/$productId',
      token: token,
      query: {if (id.isNotEmpty) 'userId': id},
    );
    return MealDetailsData.fromJson(_asMap(response.data));
  }

  Future<bool> toggleFavorite({
    required int productId,
    required bool isFavorite,
  }) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    if (isFavorite) {
      final response = await DioHelper.deleteData(
        url: '/users/$userId/favorites/products/$productId',
        token: token,
      );
      return _asBool(_asMap(response.data)['isFavorite']);
    }

    final response = await DioHelper.postData(
      url: '/users/$userId/favorites/products/$productId',
      token: token,
    );
    return _asBool(_asMap(response.data)['isFavorite'], fallback: true);
  }

  Future<void> addToCart({
    required int productId,
    required int quantity,
    String? selectedSize,
    required List<MealAddonData> selectedAddons,
  }) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    await DioHelper.postData(
      url: '/users/$userId/cart/items',
      token: token,
      data: {
        'productId': productId,
        'quantity': quantity,
        if (selectedSize != null && selectedSize.isNotEmpty)
          'selectedSize': selectedSize,
        'selectedAddons':
            selectedAddons
                .map(
                  (addon) => {
                    'id': addon.id,
                    'name': addon.name,
                    'price': addon.price,
                    'image': addon.image,
                  },
                )
                .toList(),
      },
    );
  }
}

class MealDetailsData {
  const MealDetailsData({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.ratingCount,
    required this.sizes,
    required this.addons,
    required this.isFavorite,
    required this.freeDelivery,
    required this.minimumOrder,
    required this.deliveryTime,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImageUrl,
  });

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final double rating;
  final int ratingCount;
  final List<MealSizeData> sizes;
  final List<MealAddonData> addons;
  final bool isFavorite;
  final bool freeDelivery;
  final int minimumOrder;
  final String deliveryTime;
  final int restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;

  factory MealDetailsData.fromSeed({
    required int id,
    required String name,
    required String imageUrl,
    required int price,
    required double rating,
    int ratingCount = 0,
    String description = '',
    bool isFavorite = false,
    String deliveryTime = '25-35 دقيقة',
    int restaurantId = 0,
    String restaurantName = 'مطعم',
    String? restaurantImageUrl,
  }) {
    return MealDetailsData(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      rating: rating,
      ratingCount: ratingCount,
      sizes: const [],
      addons: const [],
      isFavorite: isFavorite,
      freeDelivery: true,
      minimumOrder: 0,
      deliveryTime: deliveryTime,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantImageUrl: restaurantImageUrl,
    );
  }

  factory MealDetailsData.fromJson(Map<String, dynamic> json) {
    final images = _asList(json['images']);
    final seller = _asMap(json['seller']);
    final profile = _asMap(seller['restaurantProfile']);
    final productAddons =
        _asList(
          json['addons'],
        ).map((item) => MealAddonData.fromJson(_asMap(item))).toList();
    final globalAddons =
        _asList(
          json['globalAddons'],
        ).map((item) => MealAddonData.fromJson(_asMap(item))).toList();
    final min = _nullableInt(profile['deliveryTimeMin']);
    final max = _nullableInt(profile['deliveryTimeMax']);

    return MealDetailsData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'وجبة'),
      description: _asString(json['description'], fallback: ''),
      imageUrl:
          images.isEmpty
              ? 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=900&q=80'
              : _assetUrl(images.first),
      price: _asInt(json['discountPrice'] ?? json['price']),
      rating: _asDouble(json['rating']),
      ratingCount: _asInt(json['ratingsCount']),
      sizes:
          _asList(json['sizes'])
              .map(
                (item) => MealSizeData.fromJson(
                  item,
                  fallbackPrice: _asInt(json['discountPrice'] ?? json['price']),
                ),
              )
              .where((size) => size.name.isNotEmpty)
              .toList(),
      addons: [...productAddons, ...globalAddons],
      isFavorite: _asBool(json['isFavorite']),
      freeDelivery: _asBool(profile['freeDelivery']),
      minimumOrder: _asInt(profile['minimumOrder']),
      deliveryTime: _timeText(min, max),
      restaurantId: _asInt(
        seller['id'] ?? json['userId'] ?? json['restaurantId'],
      ),
      restaurantName: _asString(seller['name'], fallback: 'مطعم'),
      restaurantImageUrl: _nullableAssetUrl(profile['logo'] ?? seller['image']),
    );
  }
}

class MealSizeData {
  const MealSizeData({required this.name, required this.price});

  final String name;
  final int price;

  factory MealSizeData.fromJson(dynamic value, {required int fallbackPrice}) {
    if (value is String) return MealSizeData(name: value, price: fallbackPrice);
    final map = _asMap(value);
    return MealSizeData(
      name: _asString(
        map['name'] ?? map['label'] ?? map['title'],
        fallback: '',
      ),
      price: _asInt(map['price'] ?? fallbackPrice),
    );
  }
}

class MealAddonData {
  const MealAddonData({
    required this.id,
    required this.name,
    required this.price,
    this.image,
  });

  final int id;
  final String name;
  final int price;
  final String? image;

  factory MealAddonData.fromJson(Map<String, dynamic> json) {
    return MealAddonData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'إضافة'),
      price: _asInt(json['price']),
      image: _nullableAssetUrl(json['image']),
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

int? _nullableInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return _asInt(value);
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

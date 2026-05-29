import '../../../core/network/local/cache_helper.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

class RestaurantDetailsRepository {
  const RestaurantDetailsRepository();

  Future<RestaurantDetailsData> getRestaurant(int restaurantId) async {
    final latitude = CacheHelper.getData(key: 'latitude')?.toString();
    final longitude = CacheHelper.getData(key: 'longitude')?.toString();

    final response = await DioHelper.getData(
      url: '/restaurants/$restaurantId',
      token: token,
      query: {
        if (id.isNotEmpty) 'userId': id,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      },
    );

    return RestaurantDetailsData.fromJson(_asMap(response.data));
  }

  Future<bool> toggleFavorite({
    required int restaurantId,
    required bool isFavorite,
  }) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    if (isFavorite) {
      final response = await DioHelper.deleteData(
        url: '/users/$userId/favorites/restaurants/$restaurantId',
        token: token,
      );
      return _asBool(_asMap(response.data)['isFavorite']);
    }

    final response = await DioHelper.postData(
      url: '/users/$userId/favorites/restaurants/$restaurantId',
      token: token,
    );
    return _asBool(_asMap(response.data)['isFavorite'], fallback: true);
  }
}

class RestaurantDetailsData {
  const RestaurantDetailsData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.address,
    required this.area,
    required this.rating,
    required this.ratingCount,
    required this.distance,
    required this.deliveryTime,
    required this.freeDelivery,
    required this.deliveryFee,
    required this.restaurantDeliveryFee,
    required this.appDeliveryFee,
    required this.freeDeliveryDistanceKm,
    required this.deliveryPricePerKm,
    required this.withinFreeDeliveryDistance,
    required this.minimumOrder,
    required this.discountPercent,
    required this.discountMinOrder,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.coverUrl,
    required this.logoUrl,
    required this.categories,
    required this.items,
    required this.isFavorite,
  });

  final int id;
  final String name;
  final String subtitle;
  final String description;
  final String address;
  final String area;
  final double rating;
  final int ratingCount;
  final String distance;
  final String deliveryTime;
  final bool freeDelivery;
  final int deliveryFee;
  final int restaurantDeliveryFee;
  final int appDeliveryFee;
  final double freeDeliveryDistanceKm;
  final int deliveryPricePerKm;
  final bool withinFreeDeliveryDistance;
  final int minimumOrder;
  final double discountPercent;
  final int discountMinOrder;
  final bool isOpen;
  final String openingTime;
  final String closingTime;
  final String coverUrl;
  final String logoUrl;
  final List<RestaurantCategoryDetailsData> categories;
  final List<RestaurantMenuItemApiData> items;
  final bool isFavorite;

  List<RestaurantMenuItemApiData> itemsForCategory(int? categoryId) {
    if (categoryId == null) return items;
    return items.where((item) => item.categoryId == categoryId).toList();
  }

  factory RestaurantDetailsData.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['restaurantProfile']);
    final deliveryPolicy = _asMap(json['deliveryPolicy']);
    final products =
        _asList(json['products'])
            .map((item) => RestaurantMenuItemApiData.fromJson(_asMap(item)))
            .where((item) => item.isAvailable)
            .toList();
    final categoryMap = <int, RestaurantCategoryDetailsData>{};
    for (final item in products) {
      if (item.categoryId == null) continue;
      categoryMap[item.categoryId!] = RestaurantCategoryDetailsData(
        id: item.categoryId!,
        title: item.categoryName,
        imageUrl: item.categoryImageUrl,
      );
    }

    final cuisineTypes = _asList(
      profile['cuisineTypes'],
    ).map((item) => item.toString()).where((item) => item.isNotEmpty);
    final min = _nullableInt(profile['deliveryTimeMin']);
    final max = _nullableInt(profile['deliveryTimeMax']);
    final cover =
        _nullableAssetUrl(profile['coverImage']) ??
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=85';
    final logo =
        _nullableAssetUrl(profile['logo'] ?? json['image']) ??
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80';

    return RestaurantDetailsData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'مطعم'),
      subtitle:
          cuisineTypes.isEmpty
              ? _asString(profile['description'], fallback: '')
              : cuisineTypes.join('، '),
      description: _asString(profile['description'], fallback: ''),
      address: _asString(profile['address'], fallback: ''),
      area: _asString(profile['area'], fallback: ''),
      rating: _asDouble(json['rating'] ?? profile['rating']),
      ratingCount: _asInt(json['ratingsCount'] ?? profile['ratingsCount']),
      distance: _distanceText(_asDouble(json['distanceKm'])),
      deliveryTime: _timeText(min, max),
      freeDelivery:
          deliveryPolicy.isEmpty
              ? _asBool(profile['freeDelivery'])
              : _asInt(deliveryPolicy['deliveryFee']) == 0,
      deliveryFee: _asInt(deliveryPolicy['deliveryFee']),
      restaurantDeliveryFee: _asInt(deliveryPolicy['restaurantDeliveryFee']),
      appDeliveryFee: _asInt(deliveryPolicy['appDeliveryFee']),
      freeDeliveryDistanceKm: _asDouble(
        deliveryPolicy['freeDeliveryDistanceKm'] ??
            profile['freeDeliveryDistanceKm'],
      ),
      deliveryPricePerKm: _asInt(
        deliveryPolicy['deliveryPricePerKm'] ?? profile['deliveryPricePerKm'],
      ),
      withinFreeDeliveryDistance: _asBool(
        deliveryPolicy['withinFreeDeliveryDistance'],
      ),
      minimumOrder: _asInt(profile['minimumOrder']),
      discountPercent: _asDouble(profile['discountPercent']),
      discountMinOrder: _asInt(profile['discountMinOrder']),
      isOpen: _asBool(profile['isOpen'], fallback: true),
      openingTime: _asString(profile['openingTime'], fallback: ''),
      closingTime: _asString(profile['closingTime'], fallback: ''),
      coverUrl: cover,
      logoUrl: logo,
      categories: categoryMap.values.toList(),
      items: products,
      isFavorite: _asBool(json['isFavorite']),
    );
  }
}

class RestaurantCategoryDetailsData {
  const RestaurantCategoryDetailsData({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  final int id;
  final String title;
  final String? imageUrl;
}

class RestaurantMenuItemApiData {
  const RestaurantMenuItemApiData({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.description,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    this.categoryId,
    this.categoryName = 'بدون قسم',
    this.categoryImageUrl,
  });

  final int id;
  final String name;
  final int restaurantId;
  final String description;
  final double rating;
  final int price;
  final String imageUrl;
  final bool isAvailable;
  final int? categoryId;
  final String categoryName;
  final String? categoryImageUrl;

  factory RestaurantMenuItemApiData.fromJson(Map<String, dynamic> json) {
    final category = _asMap(json['category']);
    final images = _asList(json['images']);
    return RestaurantMenuItemApiData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'وجبة'),
      restaurantId: _asInt(json['userId'] ?? json['restaurantId']),
      description: _asString(json['description'], fallback: ''),
      rating: _asDouble(json['rating']),
      price: _asInt(json['discountPrice'] ?? json['price']),
      imageUrl:
          images.isEmpty
              ? 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=700&q=80'
              : _assetUrl(images.first),
      isAvailable: _asBool(json['isAvailable'], fallback: true),
      categoryId: _nullableInt(json['categoryId']),
      categoryName: _asString(category['name'], fallback: 'بدون قسم'),
      categoryImageUrl: _nullableAssetUrl(category['image']),
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
  if (min == null && max == null) return '25-35 د';
  if (min != null && max != null) return '$min-$max د';
  return '${min ?? max} د';
}

String _distanceText(double value) {
  if (value <= 0) return 'قريب';
  return '${value.toStringAsFixed(1)} كم';
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

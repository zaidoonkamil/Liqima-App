import '../../../core/network/local/cache_helper.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

class HomeApiData {
  const HomeApiData({
    required this.ads,
    required this.categories,
    required this.popularMeals,
    required this.nearbyRestaurants,
  });

  final List<HomeAdData> ads;
  final List<CategoryData> categories;
  final List<MealCardData> popularMeals;
  final List<RestaurantCardData> nearbyRestaurants;

  factory HomeApiData.fromJson(Map<String, dynamic> json) {
    return HomeApiData(
      ads:
          _asList(
            json['ads'],
          ).map((item) => HomeAdData.fromJson(_asMap(item))).toList(),
      categories:
          _asList(
            json['categories'],
          ).map((item) => CategoryData.fromJson(_asMap(item))).toList(),
      popularMeals:
          _asList(
            json['popularProducts'],
          ).map((item) => MealCardData.fromJson(_asMap(item))).toList(),
      nearbyRestaurants:
          _asList(
            json['restaurants'],
          ).map((item) => RestaurantCardData.fromJson(_asMap(item))).toList(),
    );
  }
}

class HomeRepository {
  const HomeRepository();

  Future<HomeApiData> getHome() async {
    final latitude = CacheHelper.getData(key: 'latitude')?.toString();
    final longitude = CacheHelper.getData(key: 'longitude')?.toString();

    final response = await DioHelper.getData(
      url: '/home',
      token: token,
      query: {
        if (id.isNotEmpty) 'userId': id,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      },
    );

    return HomeApiData.fromJson(_asMap(response.data));
  }
}

class MealsListRepository {
  const MealsListRepository();

  Future<List<MealCardData>> getMeals({int? categoryId}) async {
    final latitude = CacheHelper.getData(key: 'latitude')?.toString();
    final longitude = CacheHelper.getData(key: 'longitude')?.toString();

    final response = await DioHelper.getData(
      url: '/products',
      token: token,
      query: {
        'nearby': true,
        'radiusKm': 10,
        'limit': 80,
        if (id.isNotEmpty) 'userId': id,
        if (categoryId != null && categoryId > 0) 'categoryId': categoryId,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      },
    );

    return _asList(
      response.data,
    ).map((item) => MealCardData.fromJson(_asMap(item))).toList();
  }
}

class NearbyRestaurantsRepository {
  const NearbyRestaurantsRepository();

  Future<List<RestaurantCardData>> getRestaurants() async {
    final latitude = CacheHelper.getData(key: 'latitude')?.toString();
    final longitude = CacheHelper.getData(key: 'longitude')?.toString();

    final response = await DioHelper.getData(
      url: '/restaurants',
      token: token,
      query: {
        'nearby': true,
        'radiusKm': 10,
        'limit': 80,
        if (id.isNotEmpty) 'userId': id,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      },
    );

    return _asList(
      response.data,
    ).map((item) => RestaurantCardData.fromJson(_asMap(item))).toList();
  }
}

class HomeAdData {
  const HomeAdData({required this.imageUrls});

  final List<String> imageUrls;

  factory HomeAdData.fromJson(Map<String, dynamic> json) {
    final images =
        _asList(json['images'])
            .map((image) => image.toString())
            .where((image) => image.isNotEmpty)
            .map(_assetUrl)
            .toList();

    return HomeAdData(imageUrls: images);
  }
}

class CategoryData {
  const CategoryData({required this.id, required this.title, this.imageUrl});

  final int id;
  final String title;
  final String? imageUrl;

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: _asInt(json['id']),
      title: _asString(json['name'], fallback: 'قسم'),
      imageUrl: _nullableAssetUrl(json['image']),
    );
  }
}

class MealCardData {
  const MealCardData({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.restaurant,
    required this.rating,
    required this.price,
    required this.time,
    required this.imageUrl,
    required this.isFavorite,
  });

  final int id;
  final String name;
  final int restaurantId;
  final String restaurant;
  final double rating;
  final int price;
  final String time;
  final String imageUrl;
  final bool isFavorite;

  MealCardData copyWith({bool? isFavorite}) {
    return MealCardData(
      id: id,
      name: name,
      restaurantId: restaurantId,
      restaurant: restaurant,
      rating: rating,
      price: price,
      time: time,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory MealCardData.fromJson(Map<String, dynamic> json) {
    final seller = _asMap(json['seller']);
    final profile = _asMap(seller['restaurantProfile']);
    final images = _asList(json['images']);
    final min = _nullableInt(profile['deliveryTimeMin']);
    final max = _nullableInt(profile['deliveryTimeMax']);

    return MealCardData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'وجبة'),
      restaurantId: _asInt(
        seller['id'] ?? json['userId'] ?? json['restaurantId'],
      ),
      restaurant: _asString(seller['name'], fallback: 'مطعم'),
      rating: _asDouble(json['rating']),
      price: _asInt(json['discountPrice'] ?? json['price']),
      time: _timeText(min, max),
      imageUrl:
          images.isEmpty
              ? 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=700&q=80'
              : _assetUrl(images.first),
      isFavorite: _asBool(json['isFavorite']),
    );
  }
}

class RestaurantCardData {
  const RestaurantCardData({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.distance,
    required this.time,
    required this.imageUrl,
    required this.logoText,
    required this.isFavorite,
    required this.ratingCount,
    required this.minimumOrder,
  });

  final int id;
  final String name;
  final String type;
  final double rating;
  final String distance;
  final String time;
  final String imageUrl;
  final String logoText;
  final bool isFavorite;
  final String ratingCount;
  final int minimumOrder;

  RestaurantCardData copyWith({bool? isFavorite}) {
    return RestaurantCardData(
      id: id,
      name: name,
      type: type,
      rating: rating,
      distance: distance,
      time: time,
      imageUrl: imageUrl,
      logoText: logoText,
      isFavorite: isFavorite ?? this.isFavorite,
      ratingCount: ratingCount,
      minimumOrder: minimumOrder,
    );
  }

  factory RestaurantCardData.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['restaurantProfile']);
    final cuisineTypes =
        _asList(
          profile['cuisineTypes'],
        ).map((item) => item.toString()).toList();
    final min = _nullableInt(profile['deliveryTimeMin']);
    final max = _nullableInt(profile['deliveryTimeMax']);

    return RestaurantCardData(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'مطعم'),
      type:
          cuisineTypes.isEmpty
              ? _asString(profile['description'], fallback: '')
              : cuisineTypes.join('، '),
      rating: _asDouble(json['rating'] ?? profile['rating']),
      ratingCount: _shortCount(
        _asInt(json['ratingsCount'] ?? profile['ratingsCount']),
      ),
      distance: _distanceText(_asDouble(json['distanceKm'])),
      time: _timeText(min, max),
      minimumOrder: _asInt(profile['minimumOrder']),
      logoText: _asString(json['name'], fallback: 'مطعم'),
      imageUrl:
          _nullableAssetUrl(profile['coverImage']) ??
          _nullableAssetUrl(profile['logo'] ?? json['image']) ??
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      isFavorite: _asBool(json['isFavorite']),
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

String _shortCount(int value) {
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toString();
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

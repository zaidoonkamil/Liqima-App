import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

class FavoritesRepository {
  const FavoritesRepository();

  Future<FavoritesApiData> getFavorites() async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    final response = await DioHelper.getData(
      url: '/users/$userId/favorites',
      token: token,
    );

    return FavoritesApiData.fromJson(_asMap(response.data));
  }

  Future<void> removeMeal(int productId) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    await DioHelper.deleteData(
      url: '/users/$userId/favorites/products/$productId',
      token: token,
    );
  }

  Future<bool> toggleMeal({
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

  Future<void> removeRestaurant(int restaurantId) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    await DioHelper.deleteData(
      url: '/users/$userId/favorites/restaurants/$restaurantId',
      token: token,
    );
  }

  Future<bool> toggleRestaurant({
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

class FavoritesApiData {
  const FavoritesApiData({
    required this.meals,
    required this.restaurants,
    required this.productsCount,
    required this.restaurantsCount,
  });

  final List<FavoriteMealData> meals;
  final List<FavoriteRestaurantData> restaurants;
  final int productsCount;
  final int restaurantsCount;

  factory FavoritesApiData.fromJson(Map<String, dynamic> json) {
    final counts = _asMap(json['counts']);
    return FavoritesApiData(
      productsCount: _asInt(counts['products']),
      restaurantsCount: _asInt(counts['restaurants']),
      meals:
          _asList(
            json['products'],
          ).map((item) => FavoriteMealData.fromJson(_asMap(item))).toList(),
      restaurants:
          _asList(json['restaurants'])
              .map((item) => FavoriteRestaurantData.fromJson(_asMap(item)))
              .toList(),
    );
  }
}

class FavoriteMealData {
  const FavoriteMealData({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.restaurant,
    required this.logoText,
    required this.rating,
    required this.ratingCount,
    required this.price,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final int restaurantId;
  final String restaurant;
  final String logoText;
  final double rating;
  final String ratingCount;
  final int price;
  final String imageUrl;

  factory FavoriteMealData.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    final seller = _asMap(product['seller']);
    final images = _asList(product['images']);

    return FavoriteMealData(
      id: _asInt(product['id']),
      name: _asString(product['name'], fallback: 'وجبة'),
      restaurantId: _asInt(
        seller['id'] ?? product['userId'] ?? product['restaurantId'],
      ),
      restaurant: _asString(seller['name'], fallback: 'مطعم'),
      logoText: _asString(seller['name'], fallback: 'مطعم'),
      rating: _asDouble(product['rating']),
      ratingCount: _shortCount(_asInt(product['ratingsCount'])),
      price: _asInt(product['discountPrice'] ?? product['price']),
      imageUrl:
          images.isEmpty
              ? 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=700&q=80'
              : _assetUrl(images.first),
    );
  }
}

class FavoriteRestaurantData {
  const FavoriteRestaurantData({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.ratingCount,
    required this.distance,
    required this.time,
    required this.minimumOrder,
    required this.logoText,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String type;
  final double rating;
  final String ratingCount;
  final String distance;
  final String time;
  final int minimumOrder;
  final String logoText;
  final String imageUrl;

  factory FavoriteRestaurantData.fromJson(Map<String, dynamic> json) {
    final restaurant = _asMap(json['restaurant']);
    final profile = _asMap(restaurant['restaurantProfile']);
    final cuisineTypes = _asList(
      profile['cuisineTypes'],
    ).map((item) => item.toString()).where((item) => item.isNotEmpty);
    final min = _nullableInt(profile['deliveryTimeMin']);
    final max = _nullableInt(profile['deliveryTimeMax']);

    return FavoriteRestaurantData(
      id: _asInt(restaurant['id'] ?? json['restaurantId']),
      name: _asString(restaurant['name'], fallback: 'مطعم'),
      type:
          cuisineTypes.isEmpty
              ? _asString(profile['description'], fallback: '')
              : cuisineTypes.join('، '),
      rating: _asDouble(profile['rating'] ?? restaurant['rating']),
      ratingCount: _shortCount(
        _asInt(profile['ratingsCount'] ?? restaurant['ratingsCount']),
      ),
      distance: _distanceText(_asDouble(restaurant['distanceKm'])),
      time: _timeText(min, max),
      minimumOrder: _asInt(profile['minimumOrder']),
      logoText: _asString(restaurant['name'], fallback: 'مطعم'),
      imageUrl:
          _nullableAssetUrl(profile['coverImage']) ??
          _nullableAssetUrl(profile['logo'] ?? restaurant['image']) ??
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
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

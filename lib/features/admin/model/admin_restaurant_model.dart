class AdminRestaurantModel {
  const AdminRestaurantModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.logo,
    required this.coverImage,
    required this.description,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.cuisineTypes,
    required this.deliveryTimeMin,
    required this.deliveryTimeMax,
    required this.deliveryFee,
    required this.freeDeliveryDistanceKm,
    required this.deliveryPricePerKm,
    required this.appDeliveryFee,
    required this.minimumOrder,
    required this.discountPercent,
    required this.discountMinOrder,
    required this.rating,
    required this.ratingsCount,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.isFeatured,
    required this.freeDelivery,
    required this.status,
  });

  final int id;
  final String name;
  final String phone;
  final String? logo;
  final String? coverImage;
  final String description;
  final String address;
  final String area;
  final String latitude;
  final String longitude;
  final List<String> cuisineTypes;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final int deliveryFee;
  final double freeDeliveryDistanceKm;
  final int deliveryPricePerKm;
  final int appDeliveryFee;
  final int minimumOrder;
  final int discountPercent;
  final int discountMinOrder;
  final double rating;
  final int ratingsCount;
  final bool isOpen;
  final String openingTime;
  final String closingTime;
  final bool isFeatured;
  final bool freeDelivery;
  final String status;

  String get cuisineText => cuisineTypes.join('، ');

  factory AdminRestaurantModel.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['restaurantProfile']);
    final cuisines =
        _asList(profile['cuisineTypes'])
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList();

    return AdminRestaurantModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      logo: _assetUrl(profile['logo'] ?? json['image']),
      coverImage: _assetUrl(profile['coverImage']),
      description: _asString(profile['description']),
      address: _asString(profile['address']),
      area: _asString(profile['area']),
      latitude: _asString(profile['latitude']),
      longitude: _asString(profile['longitude']),
      cuisineTypes: cuisines,
      deliveryTimeMin: _asInt(profile['deliveryTimeMin']),
      deliveryTimeMax: _asInt(profile['deliveryTimeMax']),
      deliveryFee: _asInt(profile['deliveryFee']),
      freeDeliveryDistanceKm: _asDouble(profile['freeDeliveryDistanceKm']),
      deliveryPricePerKm: _asInt(profile['deliveryPricePerKm']),
      appDeliveryFee: _asInt(profile['appDeliveryFee']),
      minimumOrder: _asInt(profile['minimumOrder']),
      discountPercent: _asInt(profile['discountPercent']),
      discountMinOrder: _asInt(profile['discountMinOrder']),
      rating: _asDouble(profile['rating'] ?? json['rating']),
      ratingsCount: _asInt(profile['ratingsCount'] ?? json['ratingsCount']),
      isOpen: _asBool(profile['isOpen'], fallback: true),
      openingTime: _asString(profile['openingTime']),
      closingTime: _asString(profile['closingTime']),
      isFeatured: _asBool(profile['isFeatured']),
      freeDelivery: _asBool(profile['freeDelivery']),
      status: _asString(profile['status'], fallback: 'pending'),
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

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
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

String? _assetUrl(dynamic value) {
  final text = _asString(value);
  if (text.isEmpty) return null;
  if (text.startsWith('http')) return text;
  return 'https://liqima.napoltech.com/uploads/$text';
}

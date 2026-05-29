class RestaurantDashboardModel {
  const RestaurantDashboardModel({
    required this.restaurant,
    required this.stats,
    required this.products,
    required this.categories,
    required this.generalAddons,
    required this.deliveries,
  });

  final RestaurantInfoModel restaurant;
  final RestaurantStatsModel stats;
  final List<RestaurantProductModel> products;
  final List<RestaurantCategoryModel> categories;
  final List<RestaurantAddonModel> generalAddons;
  final List<RestaurantDeliveryModel> deliveries;

  factory RestaurantDashboardModel.fromJson(Map<String, dynamic> json) {
    return RestaurantDashboardModel(
      restaurant: RestaurantInfoModel.fromJson(_asMap(json['restaurant'])),
      stats: RestaurantStatsModel.fromJson(_asMap(json['stats'])),
      products:
          _asList(json['products'])
              .map((item) => RestaurantProductModel.fromJson(_asMap(item)))
              .toList(),
      categories:
          _asList(json['categories'])
              .map((item) => RestaurantCategoryModel.fromJson(_asMap(item)))
              .toList(),
      generalAddons:
          _asList(
            json['generalAddons'],
          ).map((item) => RestaurantAddonModel.fromJson(_asMap(item))).toList(),
      deliveries:
          _asList(json['deliveries'])
              .map((item) => RestaurantDeliveryModel.fromJson(_asMap(item)))
              .toList(),
    );
  }
}

class RestaurantInfoModel {
  const RestaurantInfoModel({
    required this.id,
    required this.name,
    required this.rating,
    this.subtitle,
    this.coverImage,
    this.logo,
    this.freeDelivery = false,
    this.minimumOrder = 0,
    this.deliveryTimeMin,
    this.deliveryTimeMax,
    this.isOpen = true,
  });

  final int id;
  final String name;
  final String? subtitle;
  final String? coverImage;
  final String? logo;
  final double rating;
  final bool freeDelivery;
  final int minimumOrder;
  final int? deliveryTimeMin;
  final int? deliveryTimeMax;
  final bool isOpen;

  factory RestaurantInfoModel.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['restaurantProfile']);
    final cuisineTypes = _asList(profile['cuisineTypes']);
    return RestaurantInfoModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'مطعم'),
      subtitle:
          cuisineTypes.isEmpty
              ? _asString(profile['description'], fallback: '')
              : cuisineTypes.join('، '),
      coverImage: _assetUrl(profile['coverImage']),
      logo: _assetUrl(profile['logo'] ?? json['image']),
      rating: _asDouble(json['rating'] ?? profile['rating']),
      freeDelivery: _asBool(profile['freeDelivery']),
      minimumOrder: _asInt(profile['minimumOrder']),
      deliveryTimeMin: _nullableInt(profile['deliveryTimeMin']),
      deliveryTimeMax: _nullableInt(profile['deliveryTimeMax']),
      isOpen: _asBool(profile['isOpen'], fallback: true),
    );
  }
}

class RestaurantStatsModel {
  const RestaurantStatsModel({
    required this.todayOrders,
    required this.activeOrders,
    required this.deliveredToday,
    required this.todayRevenue,
    required this.productsCount,
    required this.categoriesCount,
    required this.deliveriesCount,
    required this.rating,
  });

  final int todayOrders;
  final int activeOrders;
  final int deliveredToday;
  final int todayRevenue;
  final int productsCount;
  final int categoriesCount;
  final int deliveriesCount;
  final double rating;

  factory RestaurantStatsModel.fromJson(Map<String, dynamic> json) {
    return RestaurantStatsModel(
      todayOrders: _asInt(json['todayOrders']),
      activeOrders: _asInt(json['activeOrders']),
      deliveredToday: _asInt(json['deliveredToday']),
      todayRevenue: _asInt(json['todayRevenue']),
      productsCount: _asInt(json['productsCount']),
      categoriesCount: _asInt(json['categoriesCount']),
      deliveriesCount: _asInt(json['deliveriesCount']),
      rating: _asDouble(json['rating']),
    );
  }
}

class RestaurantProductModel {
  const RestaurantProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.isAvailable,
    required this.ordersCount,
    required this.rating,
    required this.ratingsCount,
    this.description,
    this.imageUrl,
  });

  final int id;
  final String name;
  final int price;
  final int? categoryId;
  final String categoryName;
  final bool isAvailable;
  final int ordersCount;
  final double rating;
  final int ratingsCount;
  final String? description;
  final String? imageUrl;

  factory RestaurantProductModel.fromJson(Map<String, dynamic> json) {
    final images = _asList(json['images']);
    final category = _asMap(json['category']);
    final orderItems = _asList(json['orderItems']);
    return RestaurantProductModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'أكلة'),
      price: _asInt(json['price']),
      categoryId: _nullableInt(json['categoryId']),
      categoryName: _asString(category['name'], fallback: 'بدون قسم'),
      isAvailable: _asBool(json['isAvailable'], fallback: true),
      ordersCount: orderItems.length,
      rating: _asDouble(json['rating']),
      ratingsCount: _asInt(json['ratingsCount']),
      description: _asString(json['description'], fallback: ''),
      imageUrl: images.isEmpty ? null : _assetUrl(images.first),
    );
  }
}

class RestaurantAddonModel {
  const RestaurantAddonModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
    this.imageUrl,
  });

  final int id;
  final String name;
  final int price;
  final bool isAvailable;
  final String? imageUrl;

  factory RestaurantAddonModel.fromJson(Map<String, dynamic> json) {
    return RestaurantAddonModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'إضافة'),
      price: _asInt(json['price']),
      isAvailable: _asBool(json['isAvailable'], fallback: true),
      imageUrl: _assetUrl(json['image']),
    );
  }
}

class RestaurantCategoryModel {
  const RestaurantCategoryModel({
    required this.id,
    required this.name,
    required this.itemsCount,
    required this.isActive,
    required this.showInSearchSuggestions,
  });

  final int id;
  final String name;
  final int itemsCount;
  final bool isActive;
  final bool showInSearchSuggestions;

  factory RestaurantCategoryModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCategoryModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'قسم'),
      itemsCount: _asList(json['products']).length,
      isActive: _asBool(json['isActive'], fallback: true),
      showInSearchSuggestions: _asBool(json['showInSearchSuggestions']),
    );
  }
}

class RestaurantDeliveryModel {
  const RestaurantDeliveryModel({
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

  factory RestaurantDeliveryModel.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['deliveryProfile']);
    return RestaurantDeliveryModel(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'دلفري'),
      phone: _asString(json['phone'], fallback: ''),
      vehicleType: _asString(profile['vehicleType'], fallback: 'دراجة'),
      isAvailable: _asBool(profile['isAvailable']),
      status: _asString(profile['status'], fallback: 'active'),
      rating: _asDouble(json['rating'] ?? profile['rating']),
    );
  }
}

class RestaurantOrderModel {
  const RestaurantOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.itemSummary,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.createdAtText,
    required this.deliveryUserId,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final int total;
  final String itemSummary;
  final String customerName;
  final String phone;
  final String address;
  final String createdAtText;
  final int? deliveryUserId;
  final List<RestaurantOrderItemModel> items;

  factory RestaurantOrderModel.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final items =
        _asList(json['items'])
            .map((item) => RestaurantOrderItemModel.fromJson(_asMap(item)))
            .toList();

    return RestaurantOrderModel(
      id: _asInt(json['id']),
      orderNumber: _asString(
        json['orderNumber'],
        fallback: '#${_asInt(json['id'])}',
      ),
      status: _asString(json['status'], fallback: 'pending'),
      statusLabel: _asString(json['statusLabel'], fallback: 'قيد التحضير'),
      total: _asInt(json['total']),
      itemSummary:
          _asString(json['itemSummary'], fallback: '').isEmpty
              ? items
                  .map((item) => '${item.quantity}x ${item.name}')
                  .join(' · ')
              : _asString(json['itemSummary'], fallback: ''),
      customerName: _asString(user['name'], fallback: 'زبون'),
      phone: _asString(json['phone'] ?? user['phone'], fallback: ''),
      address: _asString(json['address'], fallback: 'بدون عنوان'),
      createdAtText: _formatDateText(json['createdAt']),
      deliveryUserId: _nullableInt(json['deliveryUserId']),
      items: items,
    );
  }
}

class RestaurantOrderItemModel {
  const RestaurantOrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  final String name;
  final int quantity;
  final int price;
  final String? imageUrl;

  factory RestaurantOrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = _asMap(json['product']);
    final images = _asList(product['images']);
    return RestaurantOrderItemModel(
      name: _asString(product['name'], fallback: 'أكلة'),
      quantity: _asInt(json['quantity']),
      price: _asInt(json['price']),
      imageUrl: images.isEmpty ? null : _assetUrl(images.first),
    );
  }
}

String? _assetUrl(dynamic value) {
  final text = _asString(value, fallback: '');
  if (text.isEmpty) return null;
  if (text.startsWith('http')) return text;
  return 'https://liqima.napoltech.com/uploads/$text';
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
  if (value == null) return fallback;
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
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

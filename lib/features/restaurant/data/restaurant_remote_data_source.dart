import 'package:dio/dio.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';
import '../model/restaurant_models.dart';

class RestaurantRemoteDataSource {
  const RestaurantRemoteDataSource();

  int get restaurantId => int.tryParse(id) ?? 0;

  Future<RestaurantDashboardModel> getDashboard() async {
    final response = await DioHelper.getData(
      url: '/restaurants/$restaurantId/dashboard',
      token: token,
    );
    return RestaurantDashboardModel.fromJson(response.data);
  }

  Future<List<RestaurantOrderModel>> getOrders({String status = 'all'}) async {
    final response = await DioHelper.getData(
      url: '/restaurants/$restaurantId/orders',
      token: token,
      query: {'status': status, 'limit': 80},
    );
    return (response.data as List)
        .map((item) => RestaurantOrderModel.fromJson(item))
        .toList();
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await DioHelper.patchData(
      url: '/orders/$orderId/restaurant-status',
      token: token,
      data: {'restaurantId': restaurantId, 'status': status},
    );
  }

  Future<void> assignDelivery({
    required int orderId,
    required int deliveryUserId,
  }) async {
    await DioHelper.patchData(
      url: '/orders/$orderId/assign-delivery',
      token: token,
      data: {'restaurantId': restaurantId, 'deliveryUserId': deliveryUserId},
    );
  }

  Future<void> createDelivery({
    required String name,
    required String phone,
    required String password,
    required String vehicleType,
  }) async {
    await DioHelper.postData(
      url: '/deliveries',
      token: token,
      data: {
        'restaurantId': restaurantId,
        'name': name,
        'phone': phone,
        'password': password,
        'vehicleType': vehicleType,
        'isAvailable': true,
        'status': 'active',
      },
    );
  }

  Future<void> updateDelivery({
    required int deliveryId,
    required String name,
    required String phone,
    required String vehicleType,
    required bool isAvailable,
  }) async {
    await DioHelper.patchData(
      url: '/deliveries/$deliveryId',
      token: token,
      data: {
        'restaurantId': restaurantId,
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        'isAvailable': isAvailable,
      },
    );
  }

  Future<void> deleteDelivery(int deliveryId) async {
    await DioHelper.deleteData(
      url: '/deliveries/$deliveryId',
      token: token,
      data: {'restaurantId': restaurantId},
    );
  }

  Future<void> createCategory(String name, {String? imagePath}) async {
    final data = FormData.fromMap({
      'restaurantId': restaurantId,
      'name': name,
      'type': 'food',
      if (imagePath != null) 'images': await MultipartFile.fromFile(imagePath),
    });

    await DioHelper.postData(
      url: '/categories',
      token: token,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required bool isActive,
  }) async {
    await DioHelper.patchData(
      url: '/categories/$categoryId',
      token: token,
      data: {'restaurantId': restaurantId, 'name': name, 'isActive': isActive},
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    await DioHelper.deleteData(
      url: '/categories/$categoryId',
      token: token,
      data: {'restaurantId': restaurantId},
    );
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required int price,
    required double rating,
    required int ratingsCount,
    required int? categoryId,
    String? imagePath,
  }) async {
    final data = FormData.fromMap({
      'userId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'rating': rating,
      'ratingsCount': ratingsCount,
      if (categoryId != null) 'categoryId': categoryId,
      if (imagePath != null) 'images': await MultipartFile.fromFile(imagePath),
    });

    await DioHelper.postData(
      url: '/products',
      token: token,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required int price,
    required double rating,
    required int ratingsCount,
    required int? categoryId,
    required bool isAvailable,
  }) async {
    await DioHelper.patchData(
      url: '/products/$productId',
      token: token,
      data: {
        'restaurantId': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'rating': rating,
        'ratingsCount': ratingsCount,
        'categoryId': categoryId,
        'isAvailable': isAvailable,
      },
    );
  }

  Future<void> createGeneralAddon({
    required String name,
    required int price,
    String? imagePath,
  }) async {
    if (imagePath == null) {
      await DioHelper.postData(
        url: '/restaurants/$restaurantId/general-addons',
        token: token,
        data: {'name': name, 'price': price},
      );
      return;
    }

    final data = FormData.fromMap({
      'name': name,
      'price': price,
      'images': await MultipartFile.fromFile(imagePath),
    });

    await DioHelper.postData(
      url: '/restaurants/$restaurantId/general-addons',
      token: token,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> updateGeneralAddon({
    required int addonId,
    required String name,
    required int price,
    required bool isAvailable,
  }) async {
    await DioHelper.patchData(
      url: '/restaurants/$restaurantId/general-addons/$addonId',
      token: token,
      data: {'name': name, 'price': price, 'isAvailable': isAvailable},
    );
  }

  Future<void> deleteGeneralAddon(int addonId) async {
    await DioHelper.deleteData(
      url: '/restaurants/$restaurantId/general-addons/$addonId',
      token: token,
    );
  }

  Future<void> deleteProduct(int productId) async {
    await DioHelper.deleteData(
      url: '/products/$productId',
      token: token,
      data: {'restaurantId': restaurantId},
    );
  }
}

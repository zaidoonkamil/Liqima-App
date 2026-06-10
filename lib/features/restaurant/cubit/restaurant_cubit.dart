import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../user/data/notifications_page_data.dart';
import '../data/restaurant_remote_data_source.dart';
import '../model/restaurant_models.dart';
import 'restaurant_states.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit({RestaurantRemoteDataSource? remoteDataSource})
    : remoteDataSource = remoteDataSource ?? const RestaurantRemoteDataSource(),
      super(const RestaurantInitial());

  final RestaurantRemoteDataSource remoteDataSource;
  RestaurantDashboardModel? dashboard;
  List<RestaurantOrderModel> orders = [];
  UserNotificationsData? notificationsData;
  String selectedOrderStatus = 'all';
  bool loadingNotificationsData = false;

  Future<void> loadDashboard() async {
    emit(const RestaurantLoading());
    await _reload();
  }

  Future<void> refreshDashboard() async {
    await _reload();
  }

  Future<void> loadOrders({String status = 'all'}) async {
    selectedOrderStatus = status;
    emit(const RestaurantOrdersLoading());
    await _reloadOrders(status: status);
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    emit(RestaurantActionLoading(dashboard));
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      await _reloadOrders(status: selectedOrderStatus);
      await _reload(silent: true);
    } catch (error) {
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  Future<void> assignDelivery({
    required int orderId,
    required int deliveryUserId,
  }) async {
    emit(RestaurantActionLoading(dashboard));
    try {
      await remoteDataSource.assignDelivery(
        orderId: orderId,
        deliveryUserId: deliveryUserId,
      );
      await _reloadOrders(status: selectedOrderStatus);
      await _reload(silent: true);
    } catch (error) {
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  Future<void> getNotificationsData({bool refresh = false}) async {
    if (loadingNotificationsData) return;
    loadingNotificationsData = true;
    if (notificationsData == null || refresh) {
      emit(const RestaurantNotificationsLoading());
    }
    try {
      notificationsData =
          await const UserNotificationsRepository().getNotifications();
      loadingNotificationsData = false;
      emit(const RestaurantNotificationsLoaded());
    } catch (error) {
      loadingNotificationsData = false;
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  Future<void> markNotificationsRead() async {
    try {
      await const UserNotificationsRepository().markAllRead();
      notificationsData =
          await const UserNotificationsRepository().getNotifications();
      emit(const RestaurantNotificationsRead());
    } catch (error) {
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  Future<void> createDelivery({
    required String name,
    required String phone,
    required String password,
    required String vehicleType,
  }) async {
    await _runAction(
      () => remoteDataSource.createDelivery(
        name: name,
        phone: phone,
        password: password,
        vehicleType: vehicleType,
      ),
    );
  }

  Future<void> updateDelivery({
    required int deliveryId,
    required String name,
    required String phone,
    required String vehicleType,
    required bool isAvailable,
  }) async {
    await _runAction(
      () => remoteDataSource.updateDelivery(
        deliveryId: deliveryId,
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        isAvailable: isAvailable,
      ),
    );
  }

  Future<void> deleteDelivery(int deliveryId) async {
    await _runAction(() => remoteDataSource.deleteDelivery(deliveryId));
  }

  Future<void> createCategory(String name, {String? imagePath}) async {
    await _runAction(
      () => remoteDataSource.createCategory(name, imagePath: imagePath),
    );
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required bool isActive,
  }) async {
    await _runAction(
      () => remoteDataSource.updateCategory(
        categoryId: categoryId,
        name: name,
        isActive: isActive,
      ),
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    await _runAction(() => remoteDataSource.deleteCategory(categoryId));
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
    await _runAction(
      () => remoteDataSource.createProduct(
        name: name,
        description: description,
        price: price,
        rating: rating,
        ratingsCount: ratingsCount,
        categoryId: categoryId,
        imagePath: imagePath,
      ),
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
    await _runAction(
      () => remoteDataSource.updateProduct(
        productId: productId,
        name: name,
        description: description,
        price: price,
        rating: rating,
        ratingsCount: ratingsCount,
        categoryId: categoryId,
        isAvailable: isAvailable,
      ),
    );
  }

  Future<void> deleteProduct(int productId) async {
    await _runAction(() => remoteDataSource.deleteProduct(productId));
  }

  Future<void> createGeneralAddon({
    required String name,
    required int price,
    String? imagePath,
  }) async {
    await _runAction(
      () => remoteDataSource.createGeneralAddon(
        name: name,
        price: price,
        imagePath: imagePath,
      ),
    );
  }

  Future<void> updateGeneralAddon({
    required int addonId,
    required String name,
    required int price,
    required bool isAvailable,
  }) async {
    await _runAction(
      () => remoteDataSource.updateGeneralAddon(
        addonId: addonId,
        name: name,
        price: price,
        isAvailable: isAvailable,
      ),
    );
  }

  Future<void> deleteGeneralAddon(int addonId) async {
    await _runAction(() => remoteDataSource.deleteGeneralAddon(addonId));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    emit(RestaurantActionLoading(dashboard));
    try {
      await action();
      await _reload();
    } catch (error) {
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  Future<void> _reload({bool silent = false}) async {
    try {
      dashboard = await remoteDataSource.getDashboard();
      if (!silent) emit(RestaurantLoaded(dashboard!));
    } catch (error) {
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  Future<void> _reloadOrders({required String status}) async {
    try {
      orders = await remoteDataSource.getOrders(status: status);
      emit(const RestaurantOrdersLoaded());
    } catch (error) {
      emit(RestaurantError(_errorMessage(error), dashboard));
    }
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      if (data != null) return data.toString();
      return error.message ?? error.toString();
    }
    return error.toString();
  }
}

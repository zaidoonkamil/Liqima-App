import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/delivery_remote_data_source.dart';
import '../model/delivery_models.dart';
import 'delivery_states.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  DeliveryCubit({DeliveryRemoteDataSource? remoteDataSource})
    : remoteDataSource = remoteDataSource ?? const DeliveryRemoteDataSource(),
      super(const DeliveryInitial());

  final DeliveryRemoteDataSource remoteDataSource;
  DeliveryDashboardModel? dashboard;
  List<DeliveryOrderModel> orders = [];
  String selectedStatus = 'all';

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) emit(const DeliveryDashboardLoading());
    try {
      dashboard = await remoteDataSource.getDashboard();
      if (!silent) emit(const DeliveryDashboardLoaded());
    } catch (error) {
      emit(DeliveryError(_errorMessage(error)));
    }
  }

  Future<void> loadOrders({String status = 'all'}) async {
    selectedStatus = status;
    emit(const DeliveryOrdersLoading());
    try {
      orders = await remoteDataSource.getOrders(status: status);
      emit(const DeliveryOrdersLoaded());
    } catch (error) {
      emit(DeliveryError(_errorMessage(error)));
    }
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    emit(const DeliveryActionLoading());
    try {
      await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      await loadOrders(status: selectedStatus);
      await loadDashboard(silent: true);
      emit(const DeliveryActionSuccess());
    } catch (error) {
      emit(DeliveryError(_errorMessage(error)));
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

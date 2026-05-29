import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';
import '../model/delivery_models.dart';

class DeliveryRemoteDataSource {
  const DeliveryRemoteDataSource();

  int get deliveryUserId => int.tryParse(id) ?? 0;

  Future<DeliveryDashboardModel> getDashboard() async {
    final response = await DioHelper.getData(
      url: '/deliveries/$deliveryUserId/dashboard',
      token: token,
    );
    return DeliveryDashboardModel.fromJson(response.data);
  }

  Future<List<DeliveryOrderModel>> getOrders({String status = 'all'}) async {
    final response = await DioHelper.getData(
      url: '/deliveries/$deliveryUserId/orders',
      token: token,
      query: {'status': status, 'limit': 80},
    );
    return (response.data as List)
        .map((item) => DeliveryOrderModel.fromJson(item))
        .toList();
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await DioHelper.patchData(
      url: '/orders/$orderId/delivery-status',
      token: token,
      data: {'deliveryUserId': deliveryUserId, 'status': status},
    );
  }
}

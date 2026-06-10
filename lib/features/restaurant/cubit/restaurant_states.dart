import '../model/restaurant_models.dart';

abstract class RestaurantState {
  const RestaurantState();
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

class RestaurantLoaded extends RestaurantState {
  const RestaurantLoaded(this.dashboard);

  final RestaurantDashboardModel dashboard;
}

class RestaurantActionLoading extends RestaurantState {
  const RestaurantActionLoading(this.dashboard);

  final RestaurantDashboardModel? dashboard;
}

class RestaurantOrdersLoading extends RestaurantState {
  const RestaurantOrdersLoading();
}

class RestaurantOrdersLoaded extends RestaurantState {
  const RestaurantOrdersLoaded();
}

class RestaurantNotificationsLoading extends RestaurantState {
  const RestaurantNotificationsLoading();
}

class RestaurantNotificationsLoaded extends RestaurantState {
  const RestaurantNotificationsLoaded();
}

class RestaurantNotificationsRead extends RestaurantState {
  const RestaurantNotificationsRead();
}

class RestaurantError extends RestaurantState {
  const RestaurantError(this.message, this.dashboard);

  final String message;
  final RestaurantDashboardModel? dashboard;
}

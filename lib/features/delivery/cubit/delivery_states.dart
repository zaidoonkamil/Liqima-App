abstract class DeliveryState {
  const DeliveryState();
}

class DeliveryInitial extends DeliveryState {
  const DeliveryInitial();
}

class DeliveryDashboardLoading extends DeliveryState {
  const DeliveryDashboardLoading();
}

class DeliveryDashboardLoaded extends DeliveryState {
  const DeliveryDashboardLoaded();
}

class DeliveryOrdersLoading extends DeliveryState {
  const DeliveryOrdersLoading();
}

class DeliveryOrdersLoaded extends DeliveryState {
  const DeliveryOrdersLoaded();
}

class DeliveryActionLoading extends DeliveryState {
  const DeliveryActionLoading();
}

class DeliveryActionSuccess extends DeliveryState {
  const DeliveryActionSuccess();
}

class DeliveryError extends DeliveryState {
  const DeliveryError(this.message);

  final String message;
}

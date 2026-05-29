abstract class AdminState {
  const AdminState();
}

class AdminInitialState extends AdminState {
  const AdminInitialState();
}

class AdminWhatsAppLoadingState extends AdminState {
  const AdminWhatsAppLoadingState();
}

class AdminWhatsAppStatusSuccessState extends AdminState {
  const AdminWhatsAppStatusSuccessState();
}

class AdminWhatsAppQrSuccessState extends AdminState {
  const AdminWhatsAppQrSuccessState();
}

class AdminWhatsAppInitSuccessState extends AdminState {
  const AdminWhatsAppInitSuccessState();
}

class AdminWhatsAppLogoutSuccessState extends AdminState {
  const AdminWhatsAppLogoutSuccessState();
}

class AdminWhatsAppSendSuccessState extends AdminState {
  const AdminWhatsAppSendSuccessState();
}

class AdminWhatsAppErrorState extends AdminState {
  const AdminWhatsAppErrorState(this.message);

  final String message;
}

class AdminCategoriesLoadingState extends AdminState {
  const AdminCategoriesLoadingState();
}

class AdminCategoriesSuccessState extends AdminState {
  const AdminCategoriesSuccessState();
}

class AdminCategoryActionSuccessState extends AdminState {
  const AdminCategoryActionSuccessState();
}

class AdminCategoriesErrorState extends AdminState {
  const AdminCategoriesErrorState(this.message);

  final String message;
}

class AdminRestaurantsLoadingState extends AdminState {
  const AdminRestaurantsLoadingState();
}

class AdminRestaurantsSuccessState extends AdminState {
  const AdminRestaurantsSuccessState();
}

class AdminRestaurantActionSuccessState extends AdminState {
  const AdminRestaurantActionSuccessState();
}

class AdminRestaurantsErrorState extends AdminState {
  const AdminRestaurantsErrorState(this.message);

  final String message;
}

class AdminAdsLoadingState extends AdminState {
  const AdminAdsLoadingState();
}

class AdminAdsSuccessState extends AdminState {
  const AdminAdsSuccessState();
}

class AdminAdActionSuccessState extends AdminState {
  const AdminAdActionSuccessState();
}

class AdminAdsErrorState extends AdminState {
  const AdminAdsErrorState(this.message);

  final String message;
}

class AdminCouponsLoadingState extends AdminState {
  const AdminCouponsLoadingState();
}

class AdminCouponsSuccessState extends AdminState {
  const AdminCouponsSuccessState();
}

class AdminCouponActionSuccessState extends AdminState {
  const AdminCouponActionSuccessState();
}

class AdminCouponsErrorState extends AdminState {
  const AdminCouponsErrorState(this.message);

  final String message;
}

abstract class UserStates {}

class UserInitialState extends UserStates {}

class UserHomeLoadingState extends UserStates {}

class UserHomeSuccessState extends UserStates {}

class UserHomeErrorState extends UserStates {
  UserHomeErrorState(this.message);

  final String message;
}

class UserMealsListLoadingState extends UserStates {}

class UserMealsListSuccessState extends UserStates {}

class UserMealsListErrorState extends UserStates {
  UserMealsListErrorState(this.message);

  final String message;
}

class UserNearbyRestaurantsLoadingState extends UserStates {}

class UserNearbyRestaurantsSuccessState extends UserStates {}

class UserNearbyRestaurantsErrorState extends UserStates {
  UserNearbyRestaurantsErrorState(this.message);

  final String message;
}

class UserFavoritesLoadingState extends UserStates {}

class UserFavoritesSuccessState extends UserStates {}

class UserFavoritesErrorState extends UserStates {
  UserFavoritesErrorState(this.message);

  final String message;
}

class UserCouponsLoadingState extends UserStates {}

class UserCouponsSuccessState extends UserStates {}

class UserCouponsErrorState extends UserStates {
  UserCouponsErrorState(this.message);

  final String message;
}

class UserFavoriteRemovingState extends UserStates {}

class UserFavoriteRemovedState extends UserStates {}

class UserHomeFavoriteLoadingState extends UserStates {}

class UserHomeFavoriteSuccessState extends UserStates {}

class UserProfileLoadingState extends UserStates {}

class UserProfileSuccessState extends UserStates {}

class UserProfileErrorState extends UserStates {
  UserProfileErrorState(this.message);

  final String message;
}

class UserProfileUpdatingState extends UserStates {}

class UserProfileUpdatedState extends UserStates {}

class UserProfileUpdateErrorState extends UserStates {
  UserProfileUpdateErrorState(this.message);

  final String message;
}

class UserAddressSavingState extends UserStates {}

class UserAddressSavedState extends UserStates {}

class UserAddressErrorState extends UserStates {
  UserAddressErrorState(this.message);

  final String message;
}

class UserMealDetailsLoadingState extends UserStates {}

class UserMealDetailsSuccessState extends UserStates {}

class UserMealDetailsErrorState extends UserStates {
  UserMealDetailsErrorState(this.message);

  final String message;
}

class UserMealSelectionState extends UserStates {}

class UserRestaurantDetailsLoadingState extends UserStates {}

class UserRestaurantDetailsSuccessState extends UserStates {}

class UserRestaurantDetailsErrorState extends UserStates {
  UserRestaurantDetailsErrorState(this.message);

  final String message;
}

class UserRestaurantCategorySelectionState extends UserStates {}

class UserRestaurantFavoriteLoadingState extends UserStates {}

class UserRestaurantFavoriteSuccessState extends UserStates {}

class UserRestaurantFavoriteErrorState extends UserStates {
  UserRestaurantFavoriteErrorState(this.message);

  final String message;
}

class UserFavoriteLoadingState extends UserStates {}

class UserFavoriteSuccessState extends UserStates {}

class UserFavoriteErrorState extends UserStates {
  UserFavoriteErrorState(this.message);

  final String message;
}

class UserCartLoadingState extends UserStates {}

class UserCartSuccessState extends UserStates {}

class UserCartActionLoadingState extends UserStates {}

class UserCartActionSuccessState extends UserStates {}

class UserCartCouponAppliedState extends UserStates {}

class UserCartErrorState extends UserStates {
  UserCartErrorState(this.message);

  final String message;
}

class UserOrdersLoadingState extends UserStates {}

class UserOrdersSuccessState extends UserStates {}

class UserOrdersErrorState extends UserStates {
  UserOrdersErrorState(this.message);

  final String message;
}

class UserSearchLoadingState extends UserStates {}

class UserSearchSuccessState extends UserStates {}

class UserSearchErrorState extends UserStates {
  UserSearchErrorState(this.message);

  final String message;
}

class UserNotificationsLoadingState extends UserStates {}

class UserNotificationsSuccessState extends UserStates {}

class UserNotificationsReadState extends UserStates {}

class UserNotificationsErrorState extends UserStates {
  UserNotificationsErrorState(this.message);

  final String message;
}

class UserCheckoutLoadingState extends UserStates {}

class UserCheckoutSuccessState extends UserStates {}

class UserCheckoutErrorState extends UserStates {
  UserCheckoutErrorState(this.message);

  final String message;
}

class AddOrderLoadingState extends UserStates {}

class AddOrderSuccessState extends UserStates {}

class AddOrderErrorState extends UserStates {}

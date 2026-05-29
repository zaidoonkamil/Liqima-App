import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/home_page_data.dart';
import '../data/meal_details_api_data.dart';
import '../data/restaurant_details_api_data.dart';
import '../data/favorites_page_data.dart';
import '../data/coupons_page_data.dart';
import '../data/cart_page_data.dart';
import '../data/notifications_page_data.dart';
import '../data/orders_page_data.dart';
import '../data/search_page_data.dart';
import '../data/user_profile_api_data.dart';
import 'states.dart';

class UserCubit extends Cubit<UserStates> {
  UserCubit({
    HomeRepository? homeRepository,
    MealsListRepository? mealsListRepository,
    NearbyRestaurantsRepository? nearbyRestaurantsRepository,
    FavoritesRepository? favoritesRepository,
    CouponsRepository? couponsRepository,
    CartRepository? cartRepository,
    UserNotificationsRepository? notificationsRepository,
    UserOrdersRepository? ordersRepository,
    SearchRepository? searchRepository,
    MealDetailsRepository? mealDetailsRepository,
    RestaurantDetailsRepository? restaurantDetailsRepository,
    UserProfileRepository? userProfileRepository,
  }) : homeRepository = homeRepository ?? const HomeRepository(),
       mealsListRepository = mealsListRepository ?? const MealsListRepository(),
       nearbyRestaurantsRepository =
           nearbyRestaurantsRepository ?? const NearbyRestaurantsRepository(),
       favoritesRepository = favoritesRepository ?? const FavoritesRepository(),
       _couponsRepository = couponsRepository ?? const CouponsRepository(),
       _cartRepository = cartRepository ?? const CartRepository(),
       _notificationsRepository =
           notificationsRepository ?? const UserNotificationsRepository(),
       _ordersRepository = ordersRepository ?? const UserOrdersRepository(),
       _searchRepository = searchRepository ?? const SearchRepository(),
       mealDetailsRepository =
           mealDetailsRepository ?? const MealDetailsRepository(),
       restaurantDetailsRepository =
           restaurantDetailsRepository ?? const RestaurantDetailsRepository(),
       _userProfileRepository =
           userProfileRepository ?? const UserProfileRepository(),
       super(UserInitialState());

  static UserCubit get(context) => BlocProvider.of(context);

  final HomeRepository homeRepository;
  final MealsListRepository mealsListRepository;
  final NearbyRestaurantsRepository nearbyRestaurantsRepository;
  final FavoritesRepository favoritesRepository;
  final CouponsRepository? _couponsRepository;
  final CartRepository? _cartRepository;
  final UserNotificationsRepository? _notificationsRepository;
  final UserOrdersRepository? _ordersRepository;
  final SearchRepository? _searchRepository;
  final MealDetailsRepository mealDetailsRepository;
  final RestaurantDetailsRepository restaurantDetailsRepository;
  final UserProfileRepository? _userProfileRepository;

  CouponsRepository get couponsRepository =>
      _couponsRepository ?? const CouponsRepository();

  CartRepository get cartRepository =>
      _cartRepository ?? const CartRepository();

  UserNotificationsRepository get notificationsRepository =>
      _notificationsRepository ?? const UserNotificationsRepository();

  UserOrdersRepository get ordersRepository =>
      _ordersRepository ?? const UserOrdersRepository();

  SearchRepository get searchRepository =>
      _searchRepository ?? const SearchRepository();

  UserProfileRepository get userProfileRepository =>
      _userProfileRepository ?? const UserProfileRepository();

  HomeApiData? homeData;
  List<MealCardData> mealsList = [];
  int? mealsListCategoryId;
  String mealsListTitle = 'أشهر الوجبات';
  List<RestaurantCardData> nearbyRestaurantsList = [];
  FavoritesApiData? favoritesData;
  UserCouponsData? couponsData;
  CartApiData? cartData;
  UserNotificationsData? notificationsData;
  UserOrdersApiData? ordersData;
  List<SearchSuggestionData> searchSuggestions = [];
  List<SearchHistoryData> searchHistory = [];
  List<MealCardData> searchMeals = [];
  List<RestaurantCardData> searchRestaurants = [];
  String searchQuery = '';
  SearchMode searchMode = SearchMode.meals;
  UserProfileData? profileData;
  MealDetailsData? mealDetails;
  RestaurantDetailsData? restaurantDetails;
  int mealQuantity = 1;
  int selectedSizeIndex = 0;
  int? selectedRestaurantCategoryId;
  final Set<int> selectedAddonIds = {};
  bool mealFavorite = false;
  bool restaurantFavorite = false;
  bool addingMealToCart = false;
  bool loadingCartData = false;
  bool loadingNotificationsData = false;
  bool updatingCart = false;

  Future<void> getHomeData({bool refresh = false}) async {
    if (homeData == null || refresh) emit(UserHomeLoadingState());
    try {
      homeData = await homeRepository.getHome();
      emit(UserHomeSuccessState());
    } catch (error) {
      emit(UserHomeErrorState(error.toString()));
    }
  }

  Future<void> getMealsList({
    int? categoryId,
    String? title,
    bool refresh = false,
  }) async {
    final sameFilter = mealsListCategoryId == categoryId;
    if (mealsList.isNotEmpty && sameFilter && !refresh) return;
    mealsListCategoryId = categoryId;
    mealsListTitle = title ?? 'أشهر الوجبات';
    emit(UserMealsListLoadingState());
    try {
      mealsList = await mealsListRepository.getMeals(categoryId: categoryId);
      emit(UserMealsListSuccessState());
    } catch (error) {
      emit(UserMealsListErrorState(error.toString()));
    }
  }

  Future<void> getNearbyRestaurantsList({bool refresh = false}) async {
    if (nearbyRestaurantsList.isNotEmpty && !refresh) return;
    emit(UserNearbyRestaurantsLoadingState());
    try {
      nearbyRestaurantsList =
          await nearbyRestaurantsRepository.getRestaurants();
      emit(UserNearbyRestaurantsSuccessState());
    } catch (error) {
      emit(UserNearbyRestaurantsErrorState(error.toString()));
    }
  }

  Future<void> getProfileData({bool refresh = false}) async {
    if (profileData == null || refresh) emit(UserProfileLoadingState());
    try {
      profileData = await userProfileRepository.getProfile();
      emit(UserProfileSuccessState());
    } catch (error) {
      emit(UserProfileErrorState(error.toString()));
    }
  }

  Future<void> getFavoritesData({bool refresh = false}) async {
    if (favoritesData == null || refresh) emit(UserFavoritesLoadingState());
    try {
      favoritesData = await favoritesRepository.getFavorites();
      emit(UserFavoritesSuccessState());
    } catch (error) {
      emit(UserFavoritesErrorState(error.toString()));
    }
  }

  Future<void> getCouponsData({bool refresh = false}) async {
    if (couponsData == null || refresh) emit(UserCouponsLoadingState());
    try {
      couponsData = await couponsRepository.getCoupons();
      emit(UserCouponsSuccessState());
    } catch (error) {
      emit(UserCouponsErrorState(error.toString()));
    }
  }

  Future<void> getCartData({bool refresh = false}) async {
    if (loadingCartData) return;
    loadingCartData = true;
    if (cartData == null || refresh) emit(UserCartLoadingState());
    try {
      cartData = await cartRepository.getCart();
      loadingCartData = false;
      emit(UserCartSuccessState());
    } catch (error) {
      loadingCartData = false;
      emit(UserCartErrorState(error.toString()));
    }
  }

  Future<void> getNotificationsData({bool refresh = false}) async {
    if (loadingNotificationsData) return;
    loadingNotificationsData = true;
    if (notificationsData == null || refresh) {
      emit(UserNotificationsLoadingState());
    }
    try {
      notificationsData = await notificationsRepository.getNotifications();
      loadingNotificationsData = false;
      emit(UserNotificationsSuccessState());
    } catch (error) {
      loadingNotificationsData = false;
      emit(UserNotificationsErrorState(error.toString()));
    }
  }

  Future<void> markNotificationsRead() async {
    try {
      await notificationsRepository.markAllRead();
      notificationsData = await notificationsRepository.getNotifications();
      emit(UserNotificationsReadState());
    } catch (error) {
      emit(UserNotificationsErrorState(error.toString()));
    }
  }

  Future<void> getOrdersData({bool refresh = false}) async {
    if (ordersData == null || refresh) emit(UserOrdersLoadingState());
    try {
      ordersData = await ordersRepository.getOrders();
      emit(UserOrdersSuccessState());
    } catch (error) {
      emit(UserOrdersErrorState(error.toString()));
    }
  }

  Future<void> loadSearchInitialData() async {
    emit(UserSearchLoadingState());
    try {
      final results = await Future.wait([
        searchRepository.getSuggestions(),
        searchRepository.getHistory(),
        if (homeData == null)
          homeRepository.getHome()
        else
          Future.value(homeData),
      ]);
      searchSuggestions = results[0] as List<SearchSuggestionData>;
      searchHistory = results[1] as List<SearchHistoryData>;
      homeData = results[2] as HomeApiData;
      searchMeals = homeData?.popularMeals ?? [];
      searchRestaurants = homeData?.nearbyRestaurants ?? [];
      emit(UserSearchSuccessState());
    } catch (error) {
      emit(UserSearchErrorState(error.toString()));
    }
  }

  Future<void> runSearch({
    required String query,
    required SearchMode mode,
  }) async {
    searchQuery = query.trim();
    searchMode = mode;

    if (searchQuery.length < 3) {
      searchMeals = homeData?.popularMeals ?? [];
      searchRestaurants = homeData?.nearbyRestaurants ?? [];
      emit(UserSearchSuccessState());
      return;
    }

    emit(UserSearchLoadingState());
    try {
      final result = await searchRepository.search(
        query: searchQuery,
        mode: searchMode,
      );
      searchMeals = result.meals;
      searchRestaurants = result.restaurants;
      emit(UserSearchSuccessState());
    } catch (error) {
      emit(UserSearchErrorState(error.toString()));
    }
  }

  Future<void> saveCurrentSearch() async {
    if (searchQuery.length < 3) return;
    try {
      await searchRepository.saveHistory(query: searchQuery, mode: searchMode);
      searchHistory = await searchRepository.getHistory();
      emit(UserSearchSuccessState());
    } catch (error) {
      emit(UserSearchErrorState(error.toString()));
    }
  }

  Future<void> changeSearchMode(SearchMode mode) async {
    searchMode = mode;
    await runSearch(query: searchQuery, mode: mode);
  }

  Future<void> changeCartItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    if (quantity < 1) return;
    final previous = cartData;
    _optimisticCartQuantity(itemId: itemId, quantity: quantity);
    updatingCart = true;
    emit(UserCartActionLoadingState());
    try {
      cartData = await cartRepository.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );
      updatingCart = false;
      emit(UserCartActionSuccessState());
    } catch (error) {
      cartData = previous;
      updatingCart = false;
      emit(UserCartErrorState(error.toString()));
    }
  }

  Future<void> removeCartItem(int itemId) async {
    if (cartData?.items.any((item) => item.id == itemId) != true) return;
    final previous = cartData;
    _optimisticRemoveCartItem(itemId);
    updatingCart = true;
    emit(UserCartActionLoadingState());
    try {
      cartData = await cartRepository.removeItem(itemId);
      updatingCart = false;
      emit(UserCartActionSuccessState());
    } catch (error) {
      cartData = previous;
      updatingCart = false;
      emit(UserCartErrorState(error.toString()));
    }
  }

  void _optimisticCartQuantity({required int itemId, required int quantity}) {
    final cart = cartData;
    if (cart == null) return;
    CartItemData? oldItem;
    for (final item in cart.items) {
      if (item.id == itemId) oldItem = item;
    }
    if (oldItem == null) return;
    final diffQuantity = quantity - oldItem.quantity;
    final diffSubtotal = oldItem.unitTotal * diffQuantity;
    final items =
        cart.items
            .map(
              (item) =>
                  item.id == itemId ? item.copyWith(quantity: quantity) : item,
            )
            .toList();
    cartData = cart.copyWith(
      items: items,
      summary: _optimisticSummary(cart, diffSubtotal, diffQuantity),
    );
  }

  void _optimisticRemoveCartItem(int itemId) {
    final cart = cartData;
    if (cart == null) return;
    CartItemData? oldItem;
    for (final item in cart.items) {
      if (item.id == itemId) oldItem = item;
    }
    if (oldItem == null) return;
    final items = cart.items.where((item) => item.id != itemId).toList();
    cartData = cart.copyWith(
      items: items,
      summary: _optimisticSummary(
        cart,
        -oldItem.lineTotal,
        -oldItem.quantity,
        canCheckout: items.isNotEmpty,
      ),
    );
  }

  CartSummaryData _optimisticSummary(
    CartApiData cart,
    int subtotalDiff,
    int itemsDiff, {
    bool? canCheckout,
  }) {
    final summary = cart.summary;
    final subtotal =
        (summary.subtotal + subtotalDiff).clamp(0, 1 << 31).toInt();
    final itemsCount =
        (summary.itemsCount + itemsDiff).clamp(0, 1 << 31).toInt();
    final total =
        (subtotal + summary.deliveryFee - summary.discountAmount)
            .clamp(0, 1 << 31)
            .toInt();
    return summary.copyWith(
      itemsCount: itemsCount,
      subtotal: subtotal,
      total: total,
      remainingToMinimumOrder: 0,
      canCheckout: canCheckout ?? itemsCount > 0,
    );
  }

  Future<void> applyCartCoupon(String code) async {
    if (code.trim().isEmpty || updatingCart) return;
    updatingCart = true;
    emit(UserCartActionLoadingState());
    try {
      cartData = await cartRepository.applyCoupon(code);
      updatingCart = false;
      emit(UserCartCouponAppliedState());
    } catch (error) {
      updatingCart = false;
      emit(UserCartErrorState(error.toString()));
    }
  }

  Future<void> confirmCheckout({required int addressId}) async {
    if (updatingCart || cartData?.isEmpty == true) return;
    updatingCart = true;
    emit(UserCheckoutLoadingState());
    try {
      await cartRepository.checkout(
        addressId: addressId,
        couponCode: cartData?.summary.couponCode,
      );
      cartData = await cartRepository.getCart();
      ordersData = null;
      updatingCart = false;
      emit(UserCheckoutSuccessState());
    } catch (error) {
      updatingCart = false;
      emit(UserCheckoutErrorState(error.toString()));
    }
  }

  Future<void> removeFavoriteMeal(int productId) async {
    emit(UserFavoriteRemovingState());
    try {
      await favoritesRepository.removeMeal(productId);
      favoritesData = await favoritesRepository.getFavorites();
      _updateHomeMealFavorite(productId, false);
      emit(UserFavoriteRemovedState());
    } catch (error) {
      emit(UserFavoritesErrorState(error.toString()));
    }
  }

  Future<void> removeFavoriteRestaurant(int restaurantId) async {
    emit(UserFavoriteRemovingState());
    try {
      await favoritesRepository.removeRestaurant(restaurantId);
      favoritesData = await favoritesRepository.getFavorites();
      _updateHomeRestaurantFavorite(restaurantId, false);
      emit(UserFavoriteRemovedState());
    } catch (error) {
      emit(UserFavoritesErrorState(error.toString()));
    }
  }

  Future<void> toggleHomeMealFavorite(MealCardData meal) async {
    final oldValue = meal.isFavorite;
    _updateHomeMealFavorite(meal.id, !oldValue);
    emit(UserHomeFavoriteLoadingState());

    try {
      final newValue = await favoritesRepository.toggleMeal(
        productId: meal.id,
        isFavorite: oldValue,
      );
      _updateHomeMealFavorite(meal.id, newValue);
      favoritesData = null;
      emit(UserHomeFavoriteSuccessState());
    } catch (error) {
      _updateHomeMealFavorite(meal.id, oldValue);
      emit(UserFavoritesErrorState(error.toString()));
    }
  }

  Future<void> toggleHomeRestaurantFavorite(
    RestaurantCardData restaurant,
  ) async {
    final oldValue = restaurant.isFavorite;
    _updateHomeRestaurantFavorite(restaurant.id, !oldValue);
    emit(UserHomeFavoriteLoadingState());

    try {
      final newValue = await favoritesRepository.toggleRestaurant(
        restaurantId: restaurant.id,
        isFavorite: oldValue,
      );
      _updateHomeRestaurantFavorite(restaurant.id, newValue);
      favoritesData = null;
      emit(UserHomeFavoriteSuccessState());
    } catch (error) {
      _updateHomeRestaurantFavorite(restaurant.id, oldValue);
      emit(UserFavoritesErrorState(error.toString()));
    }
  }

  void _updateHomeMealFavorite(int mealId, bool isFavorite) {
    mealsList =
        mealsList
            .map(
              (meal) =>
                  meal.id == mealId
                      ? meal.copyWith(isFavorite: isFavorite)
                      : meal,
            )
            .toList();
    final home = homeData;
    if (home == null) return;
    homeData = HomeApiData(
      ads: home.ads,
      categories: home.categories,
      popularMeals:
          home.popularMeals
              .map(
                (meal) =>
                    meal.id == mealId
                        ? meal.copyWith(isFavorite: isFavorite)
                        : meal,
              )
              .toList(),
      nearbyRestaurants: home.nearbyRestaurants,
    );
  }

  void _updateHomeRestaurantFavorite(int restaurantId, bool isFavorite) {
    nearbyRestaurantsList =
        nearbyRestaurantsList
            .map(
              (restaurant) =>
                  restaurant.id == restaurantId
                      ? restaurant.copyWith(isFavorite: isFavorite)
                      : restaurant,
            )
            .toList();
    final home = homeData;
    if (home == null) return;
    homeData = HomeApiData(
      ads: home.ads,
      categories: home.categories,
      popularMeals: home.popularMeals,
      nearbyRestaurants:
          home.nearbyRestaurants
              .map(
                (restaurant) =>
                    restaurant.id == restaurantId
                        ? restaurant.copyWith(isFavorite: isFavorite)
                        : restaurant,
              )
              .toList(),
    );
  }

  Future<void> saveUserAddress({
    int? addressId,
    required String type,
    required String title,
    required String addressText,
    required String details,
    required double latitude,
    required double longitude,
  }) async {
    emit(UserAddressSavingState());
    try {
      await userProfileRepository.saveAddress(
        addressId: addressId,
        type: type,
        title: title,
        addressText: addressText,
        details: details,
        latitude: latitude,
        longitude: longitude,
      );
      profileData = await userProfileRepository.getProfile();
      emit(UserAddressSavedState());
    } catch (error) {
      emit(UserAddressErrorState(error.toString()));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? password,
    String? imagePath,
  }) async {
    emit(UserProfileUpdatingState());
    try {
      profileData = await userProfileRepository.updateProfile(
        name: name,
        phone: phone,
        password: password,
        imagePath: imagePath,
      );
      emit(UserProfileUpdatedState());
    } catch (error) {
      emit(UserProfileUpdateErrorState(error.toString()));
    }
  }

  Future<void> getMealDetails(
    int productId, {
    MealDetailsData? initialMeal,
  }) async {
    mealDetails = initialMeal;
    if (initialMeal != null) {
      mealQuantity = 1;
      selectedSizeIndex = 0;
      selectedAddonIds.clear();
      mealFavorite = initialMeal.isFavorite;
      addingMealToCart = false;
    }
    emit(UserMealDetailsLoadingState());
    try {
      mealDetails = await mealDetailsRepository.getMeal(productId);
      mealQuantity = 1;
      selectedSizeIndex = 0;
      selectedAddonIds.clear();
      mealFavorite = mealDetails?.isFavorite ?? false;
      addingMealToCart = false;
      emit(UserMealDetailsSuccessState());
    } catch (error) {
      emit(UserMealDetailsErrorState(error.toString()));
    }
  }

  void showPreviewMealDetails() {
    mealDetails = const MealDetailsData(
      id: 0,
      name: 'دجاج مشوي مع رز',
      description: 'دجاج مشوي على الفحم بتتبيلة خاصة يقدم مع رز بسمتي.',
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?auto=format&fit=crop&w=900&q=80',
      price: 7500,
      rating: 4.7,
      ratingCount: 0,
      sizes: [],
      addons: [],
      isFavorite: false,
      freeDelivery: true,
      minimumOrder: 15000,
      deliveryTime: '25-35 دقيقة',
      restaurantId: 0,
      restaurantName: 'مطعم لقمة',
      restaurantImageUrl: null,
    );
    mealQuantity = 1;
    selectedSizeIndex = 0;
    selectedAddonIds.clear();
    mealFavorite = false;
    addingMealToCart = false;
    emit(UserMealDetailsSuccessState());
  }

  Future<void> getRestaurantDetails(int restaurantId) async {
    restaurantDetails = null;
    selectedRestaurantCategoryId = null;
    restaurantFavorite = false;
    emit(UserRestaurantDetailsLoadingState());
    try {
      restaurantDetails = await restaurantDetailsRepository.getRestaurant(
        restaurantId,
      );
      restaurantFavorite = restaurantDetails?.isFavorite ?? false;
      emit(UserRestaurantDetailsSuccessState());
    } catch (error) {
      emit(UserRestaurantDetailsErrorState(error.toString()));
    }
  }

  void selectRestaurantCategory(int? categoryId) {
    selectedRestaurantCategoryId = categoryId;
    emit(UserRestaurantCategorySelectionState());
  }

  Future<void> toggleRestaurantFavorite() async {
    final restaurant = restaurantDetails;
    if (restaurant == null) return;

    final oldValue = restaurantFavorite;
    restaurantFavorite = !restaurantFavorite;
    emit(UserRestaurantFavoriteLoadingState());
    try {
      restaurantFavorite = await restaurantDetailsRepository.toggleFavorite(
        restaurantId: restaurant.id,
        isFavorite: oldValue,
      );
      _updateHomeRestaurantFavorite(restaurant.id, restaurantFavorite);
      favoritesData = null;
      emit(UserRestaurantFavoriteSuccessState());
    } catch (error) {
      restaurantFavorite = oldValue;
      emit(UserRestaurantFavoriteErrorState(error.toString()));
    }
  }

  void changeMealSize(int index) {
    selectedSizeIndex = index;
    emit(UserMealSelectionState());
  }

  void toggleMealAddon(MealAddonData addon) {
    if (!selectedAddonIds.add(addon.id)) {
      selectedAddonIds.remove(addon.id);
    }
    emit(UserMealSelectionState());
  }

  void increaseMealQuantity() {
    mealQuantity += 1;
    emit(UserMealSelectionState());
  }

  void decreaseMealQuantity() {
    if (mealQuantity > 1) mealQuantity -= 1;
    emit(UserMealSelectionState());
  }

  int mealUnitPrice() {
    final meal = mealDetails;
    if (meal == null) return 0;
    if (meal.sizes.isEmpty) return meal.price;
    final index = selectedSizeIndex.clamp(0, meal.sizes.length - 1);
    return meal.sizes[index].price;
  }

  int mealAddonsTotal() {
    final meal = mealDetails;
    if (meal == null) return 0;
    return meal.addons
        .where((addon) => selectedAddonIds.contains(addon.id))
        .fold<int>(0, (sum, addon) => sum + addon.price);
  }

  int mealTotal() => (mealUnitPrice() + mealAddonsTotal()) * mealQuantity;

  Future<void> toggleMealFavorite() async {
    final meal = mealDetails;
    if (meal == null) return;
    if (meal.id == 0) {
      emit(UserFavoriteErrorState('preview meal'));
      return;
    }

    final oldValue = mealFavorite;
    mealFavorite = !mealFavorite;
    emit(UserFavoriteLoadingState());
    try {
      mealFavorite = await mealDetailsRepository.toggleFavorite(
        productId: meal.id,
        isFavorite: oldValue,
      );
      _updateHomeMealFavorite(meal.id, mealFavorite);
      favoritesData = null;
      emit(UserFavoriteSuccessState());
    } catch (error) {
      mealFavorite = oldValue;
      emit(UserFavoriteErrorState(error.toString()));
    }
  }

  Future<void> addMealToCart() async {
    final meal = mealDetails;
    if (meal == null || addingMealToCart) return;
    if (meal.id == 0) {
      emit(UserCartErrorState('preview meal'));
      return;
    }

    addingMealToCart = true;
    emit(UserCartLoadingState());

    final selectedSize =
        meal.sizes.isEmpty
            ? null
            : meal
                .sizes[selectedSizeIndex.clamp(0, meal.sizes.length - 1)]
                .name;
    final selectedAddons =
        meal.addons
            .where((addon) => selectedAddonIds.contains(addon.id))
            .toList();

    try {
      await mealDetailsRepository.addToCart(
        productId: meal.id,
        quantity: mealQuantity,
        selectedSize: selectedSize,
        selectedAddons: selectedAddons,
      );
      cartData = await cartRepository.getCart();
      addingMealToCart = false;
      emit(UserCartSuccessState());
    } catch (error) {
      addingMealToCart = false;
      emit(UserCartErrorState(error.toString()));
    }
  }
}

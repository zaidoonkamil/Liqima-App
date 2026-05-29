import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';
import '../../restaurant/model/restaurant_models.dart';
import '../model/admin_ad_model.dart';
import '../model/admin_coupon_model.dart';
import '../model/admin_restaurant_model.dart';
import 'admin_states.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(const AdminInitialState());

  static AdminCubit get(context) => BlocProvider.of(context);

  Map<String, dynamic>? whatsAppStatus;
  String? whatsAppQrImage;
  List<RestaurantCategoryModel> categories = [];
  List<AdminRestaurantModel> restaurants = [];
  List<AdminAdModel> ads = [];
  List<AdminCouponModel> coupons = [];
  List<AdminCouponCategoryModel> couponCategories = [];

  String get whatsAppConnectionStatus =>
      whatsAppStatus?['status']?.toString() ?? 'idle';

  bool get isWhatsAppReady => whatsAppConnectionStatus == 'ready';

  bool get isWhatsAppTransitioning => const {
    'initializing',
    'authenticated',
    'qr_ready',
    'reconnecting',
    'connecting',
  }.contains(whatsAppConnectionStatus);

  String normalizePhone(String phone) {
    final value = phone.trim();
    if (value.startsWith('964')) return value;
    if (value.startsWith('0')) return '964${value.substring(1)}';
    if (value.length == 10) return '964$value';
    return value;
  }

  Map<String, dynamic> _normalizeMap(Map value) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  String resolveApiError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['error'] ?? data['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!;
      }
    }
    return error.toString();
  }

  Future<void> getWhatsAppStatus() async {
    emit(const AdminWhatsAppLoadingState());
    try {
      final response = await DioHelper.getData(
        url: '/whatsapp/status',
        token: token,
      );
      whatsAppStatus =
          response.data is Map ? _normalizeMap(response.data as Map) : {};
      emit(const AdminWhatsAppStatusSuccessState());
    } catch (error) {
      emit(AdminWhatsAppErrorState(resolveApiError(error)));
    }
  }

  Future<void> initWhatsApp() async {
    emit(const AdminWhatsAppLoadingState());
    try {
      final response = await DioHelper.postData(
        url: '/whatsapp/init',
        token: token,
        data: {},
      );
      whatsAppStatus =
          response.data is Map ? _normalizeMap(response.data as Map) : {};
      emit(const AdminWhatsAppInitSuccessState());
    } catch (error) {
      emit(AdminWhatsAppErrorState(resolveApiError(error)));
    }
  }

  Future<void> getWhatsAppQr() async {
    emit(const AdminWhatsAppLoadingState());
    try {
      final response = await DioHelper.getData(
        url: '/whatsapp/qr',
        token: token,
      );
      final Map<String, dynamic> data =
          response.data is Map ? _normalizeMap(response.data as Map) : {};
      whatsAppStatus = data;
      whatsAppQrImage = data['qrImage']?.toString();
      emit(const AdminWhatsAppQrSuccessState());
    } catch (error) {
      emit(AdminWhatsAppErrorState(resolveApiError(error)));
    }
  }

  Future<void> logoutWhatsApp() async {
    emit(const AdminWhatsAppLoadingState());
    try {
      final response = await DioHelper.postData(
        url: '/whatsapp/logout',
        token: token,
        data: {},
      );
      whatsAppStatus =
          response.data is Map ? _normalizeMap(response.data as Map) : {};
      whatsAppQrImage = null;
      emit(const AdminWhatsAppLogoutSuccessState());
    } catch (error) {
      emit(AdminWhatsAppErrorState(resolveApiError(error)));
    }
  }

  Future<void> sendWhatsAppTest({
    required String phone,
    required String message,
  }) async {
    emit(const AdminWhatsAppLoadingState());
    try {
      await DioHelper.postData(
        url: '/whatsapp/send',
        token: token,
        data: {'phone': normalizePhone(phone), 'message': message.trim()},
      );
      emit(const AdminWhatsAppSendSuccessState());
    } catch (error) {
      emit(AdminWhatsAppErrorState(resolveApiError(error)));
    }
  }

  Future<void> loadCategories() async {
    emit(const AdminCategoriesLoadingState());
    try {
      final response = await DioHelper.getData(
        url: '/categories',
        token: token,
        query: {'type': 'food', 'includeInactive': 'true'},
      );
      categories =
          (response.data as List)
              .map((item) => RestaurantCategoryModel.fromJson(item))
              .toList();
      emit(const AdminCategoriesSuccessState());
    } catch (error) {
      emit(AdminCategoriesErrorState(resolveApiError(error)));
    }
  }

  Future<void> createCategory(
    String name, {
    String? imagePath,
    bool showInSearchSuggestions = false,
  }) async {
    emit(const AdminCategoriesLoadingState());
    try {
      final data = FormData.fromMap({
        'name': name.trim(),
        'type': 'food',
        'showInSearchSuggestions': showInSearchSuggestions,
        if (imagePath != null)
          'images': await MultipartFile.fromFile(imagePath),
      });
      await DioHelper.postData(
        url: '/categories',
        token: token,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      await loadCategories();
      emit(const AdminCategoryActionSuccessState());
    } catch (error) {
      emit(AdminCategoriesErrorState(resolveApiError(error)));
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required bool isActive,
    required bool showInSearchSuggestions,
    String? imagePath,
  }) async {
    emit(const AdminCategoriesLoadingState());
    try {
      if (imagePath == null) {
        await DioHelper.patchData(
          url: '/categories/$categoryId',
          token: token,
          data: {
            'name': name.trim(),
            'type': 'food',
            'isActive': isActive,
            'showInSearchSuggestions': showInSearchSuggestions,
          },
        );
      } else {
        final data = FormData.fromMap({
          'name': name.trim(),
          'type': 'food',
          'isActive': isActive,
          'showInSearchSuggestions': showInSearchSuggestions,
          'images': await MultipartFile.fromFile(imagePath),
        });
        DioHelper.dio!.options.headers = {
          'Authorization': token,
          'Accept': 'application/json',
        };
        await DioHelper.dio!.patch(
          '/categories/$categoryId',
          data: data,
          options: Options(contentType: 'multipart/form-data'),
        );
      }
      await loadCategories();
      emit(const AdminCategoryActionSuccessState());
    } catch (error) {
      emit(AdminCategoriesErrorState(resolveApiError(error)));
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    emit(const AdminCategoriesLoadingState());
    try {
      await DioHelper.deleteData(url: '/categories/$categoryId', token: token);
      await loadCategories();
      emit(const AdminCategoryActionSuccessState());
    } catch (error) {
      emit(AdminCategoriesErrorState(resolveApiError(error)));
    }
  }

  Future<void> loadRestaurants() async {
    emit(const AdminRestaurantsLoadingState());
    try {
      final response = await DioHelper.getData(
        url: '/restaurants',
        token: token,
      );
      restaurants =
          (response.data as List)
              .map((item) => AdminRestaurantModel.fromJson(item))
              .toList();
      emit(const AdminRestaurantsSuccessState());
    } catch (error) {
      emit(AdminRestaurantsErrorState(resolveApiError(error)));
    }
  }

  Future<void> createRestaurant({
    required Map<String, dynamic> fields,
    required String logoPath,
    String? coverPath,
  }) async {
    emit(const AdminRestaurantsLoadingState());
    try {
      final data = FormData.fromMap({
        ...fields,
        'logo': await MultipartFile.fromFile(logoPath),
        if (coverPath != null)
          'coverImage': await MultipartFile.fromFile(coverPath),
      });
      await DioHelper.postData(
        url: '/restaurants',
        token: token,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      await loadRestaurants();
      emit(const AdminRestaurantActionSuccessState());
    } catch (error) {
      emit(AdminRestaurantsErrorState(resolveApiError(error)));
    }
  }

  Future<void> updateRestaurant({
    required int restaurantId,
    required Map<String, dynamic> fields,
    String? logoPath,
    String? coverPath,
  }) async {
    emit(const AdminRestaurantsLoadingState());
    try {
      if (logoPath == null && coverPath == null) {
        await DioHelper.patchData(
          url: '/restaurants/$restaurantId/profile',
          token: token,
          data: fields,
        );
      } else {
        final data = FormData.fromMap({
          ...fields,
          if (logoPath != null) 'logo': await MultipartFile.fromFile(logoPath),
          if (coverPath != null)
            'coverImage': await MultipartFile.fromFile(coverPath),
        });
        DioHelper.dio!.options.headers = {
          'Authorization': token,
          'Accept': 'application/json',
        };
        await DioHelper.dio!.patch(
          '/restaurants/$restaurantId/profile',
          data: data,
          options: Options(contentType: 'multipart/form-data'),
        );
      }
      await loadRestaurants();
      emit(const AdminRestaurantActionSuccessState());
    } catch (error) {
      emit(AdminRestaurantsErrorState(resolveApiError(error)));
    }
  }

  Future<void> loadAds() async {
    emit(const AdminAdsLoadingState());
    try {
      final response = await DioHelper.getData(url: '/ads', token: token);
      ads =
          (response.data as List)
              .map((item) => AdminAdModel.fromJson(item))
              .toList();
      emit(const AdminAdsSuccessState());
    } catch (error) {
      emit(AdminAdsErrorState(resolveApiError(error)));
    }
  }

  Future<void> loadCoupons() async {
    emit(const AdminCouponsLoadingState());
    try {
      final responses = await Future.wait([
        DioHelper.getData(
          url: '/coupons',
          token: token,
          query: {'active': 'all'},
        ),
        DioHelper.getData(
          url: '/coupon-categories',
          token: token,
          query: {'all': 'true'},
        ),
        DioHelper.getData(url: '/restaurants', token: token),
      ]);

      coupons =
          (responses[0].data as List)
              .map((item) => AdminCouponModel.fromJson(item))
              .toList();
      couponCategories =
          (responses[1].data as List)
              .map((item) => AdminCouponCategoryModel.fromJson(item))
              .toList();
      restaurants =
          (responses[2].data as List)
              .map((item) => AdminRestaurantModel.fromJson(item))
              .toList();
      emit(const AdminCouponsSuccessState());
    } catch (error) {
      emit(AdminCouponsErrorState(resolveApiError(error)));
    }
  }

  Future<void> createCouponCategory({required String name}) async {
    emit(const AdminCouponsLoadingState());
    try {
      await DioHelper.postData(
        url: '/coupon-categories',
        token: token,
        data: {
          'name': name.trim(),
          'key': name.trim().toLowerCase().replaceAll(' ', '_'),
          'isActive': true,
        },
      );
      await loadCoupons();
      emit(const AdminCouponActionSuccessState());
    } catch (error) {
      emit(AdminCouponsErrorState(resolveApiError(error)));
    }
  }

  Future<void> createCoupon(Map<String, dynamic> fields) async {
    emit(const AdminCouponsLoadingState());
    try {
      await DioHelper.postData(url: '/coupons', token: token, data: fields);
      await loadCoupons();
      emit(const AdminCouponActionSuccessState());
    } catch (error) {
      emit(AdminCouponsErrorState(resolveApiError(error)));
    }
  }

  Future<void> updateCoupon({
    required int couponId,
    required Map<String, dynamic> fields,
  }) async {
    emit(const AdminCouponsLoadingState());
    try {
      await DioHelper.patchData(
        url: '/coupons/$couponId',
        token: token,
        data: fields,
      );
      await loadCoupons();
      emit(const AdminCouponActionSuccessState());
    } catch (error) {
      emit(AdminCouponsErrorState(resolveApiError(error)));
    }
  }

  Future<void> deleteCoupon(int couponId) async {
    emit(const AdminCouponsLoadingState());
    try {
      await DioHelper.deleteData(url: '/coupons/$couponId', token: token);
      await loadCoupons();
      emit(const AdminCouponActionSuccessState());
    } catch (error) {
      emit(AdminCouponsErrorState(resolveApiError(error)));
    }
  }

  Future<void> createAd({required String imagePath}) async {
    emit(const AdminAdsLoadingState());
    try {
      final data = FormData.fromMap({
        'images': await MultipartFile.fromFile(imagePath),
      });
      await DioHelper.postData(
        url: '/ads',
        token: token,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      await loadAds();
      emit(const AdminAdActionSuccessState());
    } catch (error) {
      emit(AdminAdsErrorState(resolveApiError(error)));
    }
  }

  Future<void> deleteAd(int adId) async {
    emit(const AdminAdsLoadingState());
    try {
      await DioHelper.deleteData(url: '/ads/$adId', token: token);
      await loadAds();
      emit(const AdminAdActionSuccessState());
    } catch (error) {
      emit(AdminAdsErrorState(resolveApiError(error)));
    }
  }
}

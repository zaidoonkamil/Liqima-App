import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/network/remote/dio_helper.dart';
import '../../../core/styles/themes.dart';
import '../../../core/widgets/constant.dart';

class UserProfileRepository {
  const UserProfileRepository();

  Future<UserProfileData> getProfile() async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    final response = await DioHelper.getData(
      url: '/users/$userId/info',
      token: token,
    );
    return UserProfileData.fromJson(_asMap(response.data));
  }

  Future<void> saveAddress({
    int? addressId,
    required String type,
    required String title,
    required String addressText,
    required String details,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  }) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    final data = {
      'type': type,
      'title': title,
      'addressText': addressText,
      'details': details,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };

    if (addressId == null) {
      await DioHelper.postData(
        url: '/users/$userId/addresses',
        token: token,
        data: data,
      );
      return;
    }

    await DioHelper.patchData(
      url: '/users/$userId/addresses/$addressId',
      token: token,
      data: data,
    );
  }

  Future<UserProfileData> updateProfile({
    required String name,
    required String phone,
    String? password,
    String? imagePath,
  }) async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) throw Exception('user id is missing');

    final data = FormData.fromMap({
      'name': name.trim(),
      'phone': phone.trim(),
      if (password != null && password.trim().isNotEmpty)
        'password': password.trim(),
      if (imagePath != null && imagePath.trim().isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath),
    });

    await DioHelper.patchData(
      url: '/users/$userId/profile',
      token: token,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );

    return getProfile();
  }
}

class UserProfileData {
  const UserProfileData({
    required this.name,
    required this.phone,
    this.avatarUrl,
    required this.memberSince,
    required this.rating,
    required this.couponsCount,
    required this.points,
    required this.walletBalance,
    required this.addresses,
  });

  final String name;
  final String phone;
  final String? avatarUrl;
  final String memberSince;
  final double rating;
  final int couponsCount;
  final int points;
  final int walletBalance;
  final List<UserAddressData> addresses;

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final stats = _asMap(json['stats']);
    return UserProfileData(
      name: _asString(user['name'], fallback: 'مستخدم'),
      phone: _asString(user['phone'], fallback: ''),
      avatarUrl: _nullableAssetUrl(user['image']),
      memberSince: _memberSince(user['createdAt']),
      rating: _asDouble(stats['rating']),
      couponsCount: _asInt(stats['couponsCount']),
      points: _asInt(stats['points']),
      walletBalance: _asInt(stats['walletBalance']),
      addresses:
          _asList(
            json['addresses'],
          ).map((item) => UserAddressData.fromJson(_asMap(item))).toList(),
    );
  }
}

class UserAddressData {
  const UserAddressData({
    required this.id,
    required this.type,
    required this.title,
    required this.addressText,
    required this.details,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String type;
  final String title;
  final String addressText;
  final String details;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  String get typeLabel {
    return switch (type) {
      'work' => 'العمل',
      'other' => 'آخر',
      _ => 'المنزل',
    };
  }

  IconData get icon {
    return switch (type) {
      'work' => Iconsax.briefcase,
      'other' => Iconsax.location,
      _ => Iconsax.home,
    };
  }

  Color get color {
    return switch (type) {
      'work' => secondaryColor,
      'other' => const Color(0xFF667085),
      _ => primaryColor,
    };
  }

  factory UserAddressData.fromJson(Map<String, dynamic> json) {
    return UserAddressData(
      id: _asInt(json['id']),
      type: _asString(json['type'], fallback: 'home'),
      title: _asString(json['title'], fallback: ''),
      addressText: _asString(json['addressText'], fallback: ''),
      details: _asString(json['details'], fallback: ''),
      isDefault: _asBool(json['isDefault']),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return [];
}

String _asString(dynamic value, {required String fallback}) {
  if (value == null || value.toString().trim().isEmpty) return fallback;
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableDouble(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return _asDouble(value);
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  return value.toString() == 'true' || value.toString() == '1';
}

String _memberSince(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return 'عضو جديد';
  return 'عضو منذ ${date.year}/${date.month}';
}

String? _nullableAssetUrl(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.isEmpty) return null;
  if (text.startsWith('http')) return text;
  return 'https://liqima.napoltech.com/uploads/$text';
}

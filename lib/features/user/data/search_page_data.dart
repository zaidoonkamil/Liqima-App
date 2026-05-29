import '../../../core/network/local/cache_helper.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';
import 'home_page_data.dart';

enum SearchMode { meals, restaurants }

class SearchSuggestionData {
  const SearchSuggestionData({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String? imageUrl;

  factory SearchSuggestionData.fromJson(Map<String, dynamic> json) {
    return SearchSuggestionData(
      id: _asInt(json['id']),
      title: _asString(json['name'], fallback: 'قسم'),
      imageUrl: _nullableAssetUrl(json['image']),
    );
  }
}

class SearchHistoryData {
  const SearchHistoryData({required this.id, required this.query});

  final int id;
  final String query;

  factory SearchHistoryData.fromJson(Map<String, dynamic> json) {
    return SearchHistoryData(
      id: _asInt(json['id']),
      query: _asString(json['query'], fallback: ''),
    );
  }
}

class SearchResultData {
  const SearchResultData({required this.meals, required this.restaurants});

  final List<MealCardData> meals;
  final List<RestaurantCardData> restaurants;

  factory SearchResultData.fromJson(Map<String, dynamic> json) {
    return SearchResultData(
      meals:
          _asList(
            json['products'],
          ).map((item) => MealCardData.fromJson(_asMap(item))).toList(),
      restaurants:
          _asList(
            json['restaurants'],
          ).map((item) => RestaurantCardData.fromJson(_asMap(item))).toList(),
    );
  }
}

class SearchRepository {
  const SearchRepository();

  Future<List<SearchSuggestionData>> getSuggestions({String query = ''}) async {
    final response = await DioHelper.getData(
      url: '/search/suggestions',
      token: token,
      query: {if (query.trim().isNotEmpty) 'q': query.trim()},
    );
    final data = _asMap(response.data);
    return _asList(
      data['categories'],
    ).map((item) => SearchSuggestionData.fromJson(_asMap(item))).toList();
  }

  Future<List<SearchHistoryData>> getHistory() async {
    final userId = int.tryParse(id) ?? 0;
    if (userId == 0) return const [];

    final response = await DioHelper.getData(
      url: '/users/$userId/search-history',
      token: token,
      query: {'limit': 10},
    );
    return _asList(response.data)
        .map((item) => SearchHistoryData.fromJson(_asMap(item)))
        .where((item) => item.query.isNotEmpty)
        .toList();
  }

  Future<void> saveHistory({
    required String query,
    required SearchMode mode,
  }) async {
    final userId = int.tryParse(id) ?? 0;
    final cleanQuery = query.trim();
    if (userId == 0 || cleanQuery.isEmpty) return;

    await DioHelper.postData(
      url: '/users/$userId/search-history',
      token: token,
      data: {
        'query': cleanQuery,
        'type': mode == SearchMode.meals ? 'products' : 'restaurants',
      },
    );
  }

  Future<SearchResultData> search({
    required String query,
    required SearchMode mode,
  }) async {
    final latitude = CacheHelper.getData(key: 'latitude')?.toString();
    final longitude = CacheHelper.getData(key: 'longitude')?.toString();

    final response = await DioHelper.getData(
      url: '/search',
      token: token,
      query: {
        'q': query.trim(),
        'type': mode == SearchMode.meals ? 'products' : 'restaurants',
        'remember': 'false',
        'sort': mode == SearchMode.meals ? 'rating' : 'nearest',
        'limit': 40,
        if (id.isNotEmpty) 'userId': id,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      },
    );

    return SearchResultData.fromJson(_asMap(response.data));
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

String? _nullableAssetUrl(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  if (text.startsWith('http')) return text;
  return 'https://liqima.napoltech.com/uploads/$text';
}

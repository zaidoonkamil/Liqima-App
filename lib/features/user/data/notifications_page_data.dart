import '../../../core/network/local/cache_helper.dart';
import '../../../core/network/remote/dio_helper.dart';
import '../../../core/widgets/constant.dart';

class UserNotificationsRepository {
  const UserNotificationsRepository();

  String get _readKey => 'notifications_read_at_${adminOrUser}_$id';

  Future<UserNotificationsData> getNotifications() async {
    final response = await DioHelper.getData(
      url: '/notifications-log',
      token: token,
      query: {
        'user_id': id,
        if (adminOrUser.isNotEmpty) 'role': adminOrUser,
        'limit': 80,
      },
    );

    final data = _asMap(response.data);
    final notifications =
        _asList(
          data['logs'],
        ).map((item) => UserNotificationData.fromJson(_asMap(item))).toList();
    final lastReadAt = _lastReadAt();

    return UserNotificationsData(
      notifications: notifications,
      lastReadAt: lastReadAt,
    );
  }

  Future<void> markAllRead() async {
    await CacheHelper.saveData(
      key: _readKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  DateTime? _lastReadAt() {
    final raw = CacheHelper.getData(key: _readKey)?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

class UserNotificationsData {
  const UserNotificationsData({
    required this.notifications,
    required this.lastReadAt,
  });

  final List<UserNotificationData> notifications;
  final DateTime? lastReadAt;

  int get unreadCount {
    final readAt = lastReadAt;
    if (readAt == null) return notifications.length;
    return notifications
        .where((notification) => notification.createdAt.isAfter(readAt))
        .length;
  }
}

class UserNotificationData {
  const UserNotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final DateTime createdAt;

  factory UserNotificationData.fromJson(Map<String, dynamic> json) {
    return UserNotificationData(
      id: _asInt(json['id']),
      title: _asString(json['title'], fallback: 'إشعار جديد'),
      message: _asString(json['message'], fallback: ''),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
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
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

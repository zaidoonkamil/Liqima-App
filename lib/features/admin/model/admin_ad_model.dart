class AdminAdModel {
  const AdminAdModel({
    required this.id,
    required this.images,
    required this.createdAt,
  });

  final int id;
  final List<String> images;
  final String createdAt;

  String? get imageUrl => images.isEmpty ? null : _assetUrl(images.first);

  factory AdminAdModel.fromJson(Map<String, dynamic> json) {
    return AdminAdModel(
      id: _asInt(json['id']),
      images: _asList(json['images']).map((item) => item.toString()).toList(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return [];
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _assetUrl(String value) {
  if (value.startsWith('http')) return value;
  return 'https://liqima.napoltech.com/uploads/$value';
}

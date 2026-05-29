import 'dart:convert';

List<GetAds> getAdsFromJson(String str) => List<GetAds>.from(json.decode(str).map((x) => GetAds.fromJson(x)));

String getAdsToJson(List<GetAds> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAds {
  int id;
  List<String> images;
  String title;
  String description;
  DateTime createdAt;
  DateTime updatedAt;

  GetAds({
    required this.id,
    required this.images,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GetAds.fromJson(Map<String, dynamic> json) => GetAds(
    id: json["id"],
    images: List<String>.from(json["images"].map((x) => x)),
    title: json["title"],
    description: json["description"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "images": List<dynamic>.from(images.map((x) => x)),
    "title": title,
    "description": description,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

import 'dart:convert';

List<CatModel> catModelFromJson(String str) => List<CatModel>.from(json.decode(str).map((x) => CatModel.fromJson(x)));

String catModelToJson(List<CatModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CatModel {
  int id;
  String name;
  List<String> images;
  DateTime createdAt;
  DateTime updatedAt;

  CatModel({
    required this.id,
    required this.name,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CatModel.fromJson(Map<String, dynamic> json) => CatModel(
    id: json["id"],
    name: json["name"],
    images: List<String>.from(json["images"].map((x) => x)),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "images": List<dynamic>.from(images.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

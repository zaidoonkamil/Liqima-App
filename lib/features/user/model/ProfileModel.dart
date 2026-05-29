import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  int id;
  String name;
  String phone;
  String password;
  String role;
  DateTime createdAt;
  DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    password: json["password"],
    role: json["role"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "password": password,
    "role": role,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

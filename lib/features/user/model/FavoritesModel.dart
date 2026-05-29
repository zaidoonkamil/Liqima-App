import 'dart:convert';

FavoritesModel favoritesModelFromJson(String str) => FavoritesModel.fromJson(json.decode(str));

String favoritesModelToJson(FavoritesModel data) => json.encode(data.toJson());

class FavoritesModel {
  List<ProductFavorites> productsFavorites;

  FavoritesModel({
    required this.productsFavorites,
  });

  factory FavoritesModel.fromJson(Map<String, dynamic> json) => FavoritesModel(
    productsFavorites: List<ProductFavorites>.from(json["products"].map((x) => ProductFavorites.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "products": List<dynamic>.from(productsFavorites.map((x) => x.toJson())),
  };
}

class ProductFavorites {
  int id;
  String title;
  String description;
  int price;
  List<String> images;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;
  int categoryId;
  Seller seller;

  ProductFavorites({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.categoryId,
    required this.seller,
  });

  factory ProductFavorites.fromJson(Map<String, dynamic> json) => ProductFavorites(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    price: json["price"],
    images: List<String>.from(json["images"].map((x) => x)),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    userId: json["userId"],
    categoryId: json["categoryId"],
    seller: Seller.fromJson(json["seller"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "price": price,
    "images": List<dynamic>.from(images.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "userId": userId,
    "categoryId": categoryId,
    "seller": seller.toJson(),
  };
}

class Seller {
  int id;
  String name;
  String phone;
  String location;
  String role;
  bool isVerified;
  String image;

  Seller({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.role,
    required this.isVerified,
    required this.image,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    location: json["location"],
    role: json["role"],
    isVerified: json["isVerified"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "location": location,
    "role": role,
    "isVerified": isVerified,
    "image": image,
  };
}

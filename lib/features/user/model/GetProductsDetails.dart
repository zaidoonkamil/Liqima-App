import 'dart:convert';

GetProductsDetails getProductsDetailsFromJson(String str) => GetProductsDetails.fromJson(json.decode(str));

String getProductsDetailsToJson(GetProductsDetails data) => json.encode(data.toJson());

class GetProductsDetails {
  int totalItems;
  int totalPages;
  int currentPage;
  List<ProductDetails> productsDetails;

  GetProductsDetails({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.productsDetails,
  });

  factory GetProductsDetails.fromJson(Map<String, dynamic> json) => GetProductsDetails(
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
    currentPage: json["currentPage"],
    productsDetails: List<ProductDetails>.from(json["products"].map((x) => ProductDetails.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "currentPage": currentPage,
    "products": List<dynamic>.from(productsDetails.map((x) => x.toJson())),
  };
}

class ProductDetails {
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
  bool isFavorite;

  ProductDetails({
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
    required this.isFavorite,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
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
    isFavorite: json["isFavorite"],
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
    "isFavorite": isFavorite,
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

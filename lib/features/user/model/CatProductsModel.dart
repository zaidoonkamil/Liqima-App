import 'dart:convert';

CatProductsModel catProductsModelFromJson(String str) =>
    CatProductsModel.fromJson(json.decode(str));

String catProductsModelToJson(CatProductsModel data) =>
    json.encode(data.toJson());

class CatProductsModel {
  PaginationCatProducts paginationCatProducts;
  List<ProductCat> products;

  CatProductsModel({
    required this.paginationCatProducts,
    required this.products,
  });

  factory CatProductsModel.fromJson(Map<String, dynamic> json) =>
      CatProductsModel(
        paginationCatProducts: PaginationCatProducts(
          totalItems: json["totalItems"] ?? 0,
          totalPages: json["totalPages"] ?? 0,
          currentPage: json["currentPage"] ?? 1,
        ),
        products: List<ProductCat>.from(
          (json["products"] ?? []).map((x) => ProductCat.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "totalItems": paginationCatProducts.totalItems,
    "totalPages": paginationCatProducts.totalPages,
    "currentPage": paginationCatProducts.currentPage,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class ProductCat {
  int id;
  String title;
  String description;
  int price;
  List<String> images;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;
  int categoryId;
  bool isFavorite;
  Seller seller;

  ProductCat({
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

  factory ProductCat.fromJson(Map<String, dynamic> json) => ProductCat(
    id: json["id"] ?? 0,
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    price: json["price"] ?? 0,
    images: List<String>.from(json["images"]?.map((x) => x) ?? []),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    userId: json["userId"] ?? 0,
    categoryId: json["categoryId"] ?? 0,
    seller: Seller.fromJson(json["seller"] ?? {}),
    isFavorite: json["isFavorite"] ?? false,
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
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    location: json["location"] ?? "",
    role: json["role"] ?? "",
    isVerified: json["isVerified"] ?? false,
    image: json["image"] ?? "",
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

class PaginationCatProducts {
  int totalItems;
  int totalPages;
  int currentPage;

  PaginationCatProducts({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationCatProducts.fromJson(Map<String, dynamic> json) =>
      PaginationCatProducts(
        totalItems: json["totalItems"] ?? 0,
        totalPages: json["totalPages"] ?? 0,
        currentPage: json["currentPage"] ?? 1,
      );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "currentPage": currentPage,
  };
}

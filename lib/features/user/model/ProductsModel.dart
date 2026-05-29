import 'dart:convert';

ProductsModel productsModelFromJson(String str) => ProductsModel.fromJson(json.decode(str));

String productsModelToJson(ProductsModel data) => json.encode(data.toJson());

class ProductsModel {
  PaginationProducts paginationProducts;
  List<Product> products;

  ProductsModel({
    required this.paginationProducts,
    required this.products,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    paginationProducts: PaginationProducts(
      totalItems: json["totalItems"],
      totalPages: json["totalPages"],
      currentPage: json["currentPage"],
    ),
    products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalItems": paginationProducts.totalItems,
    "totalPages": paginationProducts.totalPages,
    "currentPage": paginationProducts.currentPage,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Product {
  int id;
  String title;
  String description;
  int price;
  List<String> images;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;
  Seller seller;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.seller,
    required this.isFavorite,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    price: json["price"],
    images: List<String>.from(json["images"].map((x) => x)),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    userId: json["userId"],
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

class PaginationProducts {
  int totalItems;
  int totalPages;
  int currentPage;

  PaginationProducts({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationProducts.fromJson(Map<String, dynamic> json) => PaginationProducts(
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
    currentPage: json["currentPage"],
  );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "currentPage": currentPage,
  };
}

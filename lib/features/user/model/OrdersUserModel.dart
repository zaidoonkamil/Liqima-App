import 'dart:convert';

OrdersUserModel ordersUserModelFromJson(String str) => OrdersUserModel.fromJson(json.decode(str));

String ordersUserModelToJson(OrdersUserModel data) => json.encode(data.toJson());

class OrdersUserModel {
  PaginationOrdersUser paginationOrdersUser;
  List<Order> orders;

  OrdersUserModel({
    required this.paginationOrdersUser,
    required this.orders,
  });

  factory OrdersUserModel.fromJson(Map<String, dynamic> json) => OrdersUserModel(
    paginationOrdersUser: PaginationOrdersUser.fromJson(
        json["paginationOrdersUser"] ?? {}),
    orders: List<Order>.from(
        (json["orders"] ?? []).map((x) => Order.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "paginationOrdersUser": paginationOrdersUser.toJson(),
    "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
  };
}

class PaginationOrdersUser {
  int totalItems;
  int totalPages;
  int currentPage;

  PaginationOrdersUser({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationOrdersUser.fromJson(Map<String, dynamic> json) => PaginationOrdersUser(
    totalItems: json["totalItems"] ?? 0,
    totalPages: json["totalPages"] ?? 0,
    currentPage: json["currentPage"] ?? 1, // القيمة الافتراضية 1
  );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "currentPage": currentPage,
  };
}

class Order {
  int id;
  DateTime createdAt;
  int totalItems;
  int totalPrice;
  String status;

  Order({
    required this.id,
    required this.createdAt,
    required this.totalItems,
    required this.totalPrice,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"] ?? 0,
    createdAt: DateTime.parse(json["createdAt"] ?? DateTime.now().toIso8601String()),
    totalItems: json["totalItems"] ?? 0,
    totalPrice: json["totalPrice"] ?? 0,
    status: json["status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt.toIso8601String(),
    "totalItems": totalItems,
    "totalPrice": totalPrice,
    "status": status,
  };
}

import 'dart:convert';
import 'package:uuid/uuid.dart';

// Function to convert JSON string to a List of Users
List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

// Function to convert List of Users to JSON string
String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Function to convert JSON string to a List of Products
List<Product> productsFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

// Function to convert List of Products to JSON string
String productsToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Class for User data
class Users {
  String? id;
  String? fullname;
  String? email;
  String? password;
  String? imageUrl;
  double money; // Made non-nullable with a default value
  int follower; // Made non-nullable with a default value
  int following; // Made non-nullable with a default value
  List<String> favoriteProducts; // Made non-nullable with a default value
  List<String> cartItems; // Made non-nullable with a default value

  Users({
    this.id,
    this.fullname,
    this.email,
    this.password,
    this.imageUrl,
    double? money,
    int? follower,
    int? following,
    List<String>? favoriteProducts,
    List<String>? cartItems,
  })  : money = money ?? 0.0,
        follower = follower ?? 0,
        following = following ?? 0,
        favoriteProducts = favoriteProducts ?? [],
        cartItems = cartItems ?? [];

  // Convert JSON to Users object
  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json["id"],
        fullname: json["fullname"],
        email: json["email"],
        password: json["password"],
        imageUrl: json["imageUrl"],
        money: (json["money"] is String)
            ? double.tryParse(json["money"]) ?? 0.0
            : json["money"]?.toDouble() ?? 0.0,
        follower: (json["follower"] is String)
            ? int.tryParse(json["follower"]) ?? 0
            : json["follower"] ?? 0,
        following: (json["following"] is String)
            ? int.tryParse(json["following"]) ?? 0
            : json["following"] ?? 0,
        favoriteProducts: json["favoriteProducts"] != null
            ? List<String>.from(json["favoriteProducts"].map((x) => x.toString()))
            : [],
        cartItems: json["cartItems"] != null
            ? List<String>.from(json["cartItems"].map((x) => x.toString()))
            : [],
      );

  // Convert Users object to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "email": email,
        "password": password,
        "imageUrl": imageUrl,
        "money": money,
        "follower": follower,
        "following": following,
        "favoriteProducts": favoriteProducts,
        "cartItems": cartItems,
      };

  // Method to create a new User
  static Users createNew(
    String fullname,
    String email,
    String password, [
    String? imageUrl,
    double? money,
    int? follower,
    int? following,
    List<String>? favoriteProducts,
    List<String>? cartItems,
  ]) {
    // Validate essential fields
    if (fullname.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Fullname, email, and password cannot be empty.');
    }
    const Uuid uuid = Uuid();
    return Users(
      id: uuid.v4(),
      fullname: fullname,
      email: email,
      password: password,
      imageUrl: imageUrl,
      money: money,
      follower: follower,
      following: following,
      favoriteProducts: favoriteProducts,
      cartItems: cartItems,
    );
  }
}

// Class for Product data
class Product {
  String? id;
  String? name;
  double price; // Made non-nullable with a default value
  String detail; // Made non-nullable with a default value
  String imageUrl; // Made non-nullable with a default value

  Product({
    this.id,
    this.name,
    double? price,
    String? detail,
    String? imageUrl,
  })  : price = price ?? 0.0,
        detail = detail ?? '',
        imageUrl = imageUrl ?? '';

  // Convert JSON to Product object
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        price: json["price"]?.toDouble() ?? 0.0,
        detail: json["detail"] ?? '',
        imageUrl: json["imageUrl"] ?? '',
      );

  // Convert Product object to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "detail": detail,
        "imageUrl": imageUrl,
      };
}

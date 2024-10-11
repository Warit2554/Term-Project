import 'package:flutter/material.dart';
import 'package:flutter1/afterlogin.dart';
import 'package:flutter1/cart.dart';
import 'package:http/http.dart' as http; // สำหรับการเรียก API
import 'dart:convert'; // สำหรับการแปลง JSON
import '/config/users.dart'; // นำเข้าคลาส Product
import '/config/config.dart'; // สำหรับการตั้งค่า API


class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // ฟังก์ชันในการดึงข้อมูลสินค้าโปรด
  Future<List<Product>> fetchFavoriteProducts() async {
    final Uri apiUrl = Uri.http(Configure.server, '/users/${Configure.login.id}'); // ปรับ endpoint ให้ตรง

    final response = await http.get(apiUrl);

    // print(response.body); // Print the response body
    
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      List<String> favoriteIds = List<String>.from(userData['favoriteProducts']);

      // Now fetch the product details based on favoriteIds
      return await fetchProductsByIds(favoriteIds);
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  // ฟังก์ชันในการดึงข้อมูลผลิตภัณฑ์จาก ID
  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    List<Product> products = [];

    // Loop through each ID and fetch product details
    for (String id in ids) {
      final Uri productApiUrl = Uri.http(Configure.server, '/products/$id'); // Adjust the endpoint as necessary
      final response = await http.get(productApiUrl);

      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        products.add(Product.fromJson(productData)); // Assuming you have a fromJson method in your Product class
      } else {
        print('Failed to load product with id $id'); // Handle errors appropriately
      }
    }

    return products;
  }

  // ฟังก์ชันเปลี่ยนสถานะสินค้าโปรด
  Future<void> toggleFavorite(Product product) async {
    final Uri apiUrl = Uri.http(Configure.server, '/users/${Configure.login.id}'); // ปรับ endpoint ให้ตรง

    // สร้างรายการ favoriteProducts ใหม่
    List<String> updatedFavorites = List.from(Configure.login.favoriteProducts);

    // ตรวจสอบว่าผลิตภัณฑ์อยู่ในรายการโปรดแล้วหรือไม่
    if (updatedFavorites.contains(product.id)) {
      updatedFavorites.remove(product.id); // ลบถ้าอยู่ในรายการโปรด
    } else {
      updatedFavorites.add(product.id!); // เพิ่มถ้าไม่อยู่ในรายการโปรด
    }

    // ส่งข้อมูลที่อัปเดตไปยังเซิร์ฟเวอร์
    final response = await http.patch(
      apiUrl,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"favoriteProducts": updatedFavorites}),
    );

    if (response.statusCode == 200) {
      // อัปเดตสำเร็จ
      setState(() {
        Configure.login.favoriteProducts = updatedFavorites; // อัปเดตสถานะในแอปพลิเคชัน
      });
    } else {
      throw Exception('Failed to update favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Products'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchFavoriteProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite products found.'));
          }

          final favoriteProducts = snapshot.data!;

          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
  contentPadding: const EdgeInsets.all(8.0),
  leading: Image.network(
    product.imageUrl, // รูปภาพผลิตภัณฑ์
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      // แสดงภาพแทนที่เมื่อโหลดภาพไม่สำเร็จ
      return Image.network(
        'https://i.imgur.com/NFEBrWK.jpeg', // รูปภาพแทนที่ถ้ามีข้อผิดพลาด
        fit: BoxFit.cover,
        width: 50,
        height: 50,
      );
    },
  ),
                    title: Text(product.name ?? 'Unnamed Product'),
                    subtitle: Text('${product.price} ฿'),
                    trailing: IconButton(
                      icon: Icon(
                        Configure.login.favoriteProducts.contains(product.id) // ตรวจสอบสถานะโปรด
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => toggleFavorite(product), // เรียกใช้ฟังก์ชัน toggleFavorite
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
     bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Action for home
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProductScreen(), // Pass loggedInUserId
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyCartScreen(userId: Configure.loggedInUserId!), // Pass loggedInUserId
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite,color:Colors.orange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritePage(), // Navigate to favorite page
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action to add a new product
      //   },
      //   backgroundColor: Colors.orange,
      //   child: Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
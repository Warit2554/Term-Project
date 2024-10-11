import 'package:flutter/material.dart';
import 'package:flutter1/addproduct.dart';
import 'package:flutter1/cart.dart';
import 'package:flutter1/editproduct.dart';
import 'package:flutter1/favorite.dart';
import 'package:flutter1/productdetail.dart';
import 'package:flutter1/topup.dart';
import 'dart:async'; // นำเข้า Timer
import 'package:http/http.dart' as http; // สำหรับการเรียก API
import 'dart:convert'; // สำหรับการแปลง JSON
import '/config/users.dart'; // นำเข้าคลาส Product
import '/config/config.dart'; // สำหรับการตั้งค่า API

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({super.key});

  @override
  _MyProductScreenState createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> {

// fix Money don't right eiei
  // late Timer _timer;
  
   @override
   void initState() {
     super.initState();
     // ดึงข้อมูลผู้ใช้เมื่อเริ่มต้น
     fetchUserData();

 
    //  _timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
    //    fetchUserData();
    //  });
   }

  // @override
  // void dispose() {
  //   _timer.cancel(); 
  //   super.dispose();
  // }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก API
  Future<void> fetchUserData() async {
    final Uri apiUrl = Uri.http(Configure.server, '/users/${Configure.login.id}');
    final response = await http.get(apiUrl);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        Configure.login = Users.fromJson(data); // อัปเดตข้อมูลใน Configure.login  ว่าจะดึงมาจาก id นี้้
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // ฟังก์ชันในการดึงข้อมูลสินค้า
  Future<List<Product>> fetchProducts() async {
    final Uri apiUrl = Uri.http(Configure.server, '/products');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      return productsFromJson(response.body); // แปลง JSON เป็น List
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> updateProductInDatabase(Product product) async {
    final updatedProductJson = product.toJson();

    final response = await http.put(
      Uri.parse('http://${Configure.server}/products/${product.id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedProductJson),
    );

    if (response.statusCode == 200) {
      print('Product updated successfully!');
    } else {
      print('Failed to update product: ${response.body}');
    }

    // For demonstration purposes, print the updated product
    print('Updated Product: $updatedProductJson');
  }

  // ฟังก์ชันในการลบสินค้า
  Future<void> deleteProduct(String productId) async {
    final Uri apiUrl = Uri.http(Configure.server, '/products/$productId');

    final response = await http.delete(apiUrl);

    if (response.statusCode == 200) {
      // Refresh product list after deletion
      setState(() {
        fetchProducts();
      });
    } else {
      throw Exception('Failed to delete product');
    }
  }

  // ฟังก์ชันในการสลับสถานะรายการโปรด
  Future<void> toggleFavorite(Product product) async {
    final Uri apiUrl = Uri.http(Configure.server, '/users/${Configure.login.id}');

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

  // ฟังก์ชันเพื่อเปิดหน้าต่างค้นหา
  void _showSearch() {
    showSearch(
      context: context,
      delegate: MySearchDelegate(), // Create a search delegate class for search functionality
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch, // Call search when the icon is tapped
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวที่มีรายละเอียดของผู้ใช้
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: AssetImage(Configure.login.imageUrl ??
                      'assets/images/placeholder.jpeg'), // รูปภาพแทนที่เป็นค่าเริ่มต้น
                 
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Configure.login.fullname ?? 'Username',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total ${Configure.login.money.toString()} ฿',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TopUpScreen()),
                    );
                  },
                  child: const Text('Top up', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // FutureBuilder เพื่อดึงและแสดงสินค้า
            Expanded(
              //listbox
              child: FutureBuilder<List<Product>>(
                future: fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }

                  final products = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 5,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        // ตรวจสอบว่าผลิตภัณฑ์อยู่ในรายการโปรดหรือไม่
                        final isFavorited = Configure.login.favoriteProducts.contains(product.id);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Wrap the Image.network with GestureDetector
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to ProductDetailPage
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailPage(product: product),
                                        ),
                                      );
                                    },
                                    child: product.imageUrl.isNotEmpty
                                        ? Image.network(
                                            product.imageUrl,
                                            fit: BoxFit.cover,
                                            height: 160,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/placeholder.jpeg',
                                                fit: BoxFit.cover,
                                                height: 160,
                                                width: double.infinity,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/placeholder.jpeg', // Default placeholder
                                            fit: BoxFit.cover,
                                            height: 160,
                                            width: double.infinity,
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name ?? 'Product name',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text('${product.price} ฿'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 9,
                                bottom: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProductScreen(
                                              productName: product.name ?? 'Unnamed Product',
                                              productDescription: product.detail,
                                              productPrice: product.price.toString(),
                                              productImageUrl: product.imageUrl,
                                              product: product,
                                              onSave: (updatedProduct) {
                                                updateProductInDatabase(updatedProduct);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        // Confirm deletion
                                        final confirmation = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Delete Product'),
                                              content: const Text('Are you sure you want to delete this product?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('YESSS !!Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmation == true) {
                                          try {
                                            await deleteProduct(product.id!); // Call delete product function
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Failed to delete product')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorited ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await toggleFavorite(product); // Update favorite status on the server
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Failed to update favorite')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home,color: Colors.orange,),
              onPressed: () {
                // Action for home
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const MyProductScreen(), // Pass loggedInUserId
                //   ),
                // );
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
              icon: const Icon(Icons.favorite),
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
            floatingActionButton: FloatingActionButton(
        onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Create a search delegate class for search functionality
class MySearchDelegate extends SearchDelegate {
  // สร้างฟังก์ชันดึงข้อมูลผลิตภัณฑ์เพื่อค้นหา
  Future<List<Product>> fetchAllProducts() async {
    final Uri apiUrl = Uri.http(Configure.server, '/products');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      return productsFromJson(response.body); // แปลง JSON เป็น List<Product>
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search
      },
    );
  }

  @override
@override
Widget buildResults(BuildContext context) {
  return FutureBuilder<List<Product>>(
    future: fetchAllProducts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      final products = snapshot.data!.where((product) {
        return product.name!.toLowerCase().contains(query.toLowerCase());
      }).toList();

      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.jpeg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/placeholder.jpeg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
            title: Text(product.name ?? 'Product name'),
            subtitle: Text('${product.price} ฿'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
          );
        },
      );
    },
  );
}

@override
Widget buildSuggestions(BuildContext context) {
  return FutureBuilder<List<Product>>(
    future: fetchAllProducts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No products available'));
      }

      final products = snapshot.data!.where((product) {
        return product.name!.toLowerCase().contains(query.toLowerCase());
      }).toList();

      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            leading: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.jpeg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/placeholder.jpeg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
            title: Text(product.name ?? 'Product name'),
            subtitle: Text('${product.price} ฿'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
          );
        },
      );
    },
  );
  
}
}
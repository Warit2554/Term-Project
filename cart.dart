import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter1/afterlogin.dart';
import 'package:flutter1/buycomplete.dart';
import 'package:flutter1/favorite.dart';
import 'package:http/http.dart' as http;
import 'config/config.dart';
import 'config/users.dart';

class MyCartScreen extends StatefulWidget {
  final String userId;

  const MyCartScreen({super.key, required this.userId});

  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  List<Product> products = [];
  Users? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://${Configure.server}/products');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        products = productsFromJson(response.body);
        fetchUser();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchUser() async {
    final url = Uri.parse('http://${Configure.server}/users');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final users = usersFromJson(response.body);
        currentUser = users.firstWhere((u) => u.id == widget.userId, orElse: () => Users());
        if (currentUser != null) {
          setState(() {
            isLoading = false;
          });
        } else {
          throw Exception('User not found');
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteCartItem(int index) async {
    final url = Uri.parse('http://${Configure.server}/users/${currentUser!.id}');

    try {
      setState(() {
        currentUser!.cartItems.removeAt(index);
      });

      final updateResponse = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(currentUser!.toJson()),
      );

      if (updateResponse.statusCode == 200) {
        print('Cart updated successfully');
      } else {
        throw Exception('Failed to update cart on server');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> purchaseItems() async {
    double total = calculateTotal();
    
    if (currentUser!.money >= total) {
      // If sufficient funds
      setState(() {
        currentUser!.money -= total; // Deduct the amount
        currentUser!.cartItems.clear(); // Clear the cart
      });

      // Update user data in the database
      final url = Uri.parse('http://${Configure.server}/users/${currentUser!.id}');
      final updateResponse = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(currentUser!.toJson()),
      );

      if (updateResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const buycomplete()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update user money')),
        );
      }
    } else {
      // If insufficient funds
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient funds to complete the purchase.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: currentUser!.cartItems.isEmpty
                      ? const Center(child: Text('No product in cart found...')) // Message for empty cart
                      : ListView.builder(
                          itemCount: currentUser!.cartItems.length,
                          itemBuilder: (context, index) {
                            //filter ID which Userid
                            final itemId = currentUser!.cartItems[index];
                            final product = products.firstWhere(
                              (prod) => prod.id == itemId,
                              orElse: () => Product(name: 'Unknown', price: 0, imageUrl: ''),
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8.0),
                                  leading: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          height: 80,
                                          width: 80,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/placeholder.jpeg',
                                              fit: BoxFit.cover,
                                              height: 80,
                                              width: 80,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/placeholder.jpeg',
                                          fit: BoxFit.cover,
                                          height: 80,
                                          width: 80,
                                        ),
                                  title: Text(product.name ?? ''),
                                  subtitle: Text('${product.price} ฿'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteCartItem(index),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (currentUser!.cartItems.isNotEmpty) // Only show this when there are items in the cart
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Deliverly fee 50 ฿', style: TextStyle(fontSize: 16)),
                            Text(
                              'Total ${calculateTotal()} ฿',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            purchaseItems(); // Call purchase function
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'ซื้อสินค้า',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
              ],
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
              icon: const Icon(Icons.shopping_cart, color: Colors.orange),
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
    );
  }

  double calculateTotal() {
    double total = 0.0;
    for (var itemId in currentUser!.cartItems) {
      final product = products.firstWhere((prod) => prod.id == itemId, orElse: () => Product(price: 0));
      total += product.price;
    }
    return total + 50; // Add shipping cost
  }
}
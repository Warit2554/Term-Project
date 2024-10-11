import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/users.dart';
import 'config/config.dart'; // For accessing user details from Configure

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isAddingToCart = false; // State variable to track adding to cart
  late Users currentUser;

  @override
  void initState() {
    super.initState();
    // Load current user from the database (mocking the loading here)
    currentUser = Configure.login; // Assuming this contains the user data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User profile section
            // Row(
            //   children: [
            //     CircleAvatar(
            //       radius: 30,
            //       backgroundColor: Colors.grey[300],
            //       child: const Icon(Icons.person, size: 40),
            //     ),
            //     const SizedBox(width: 10),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           currentUser.fullname ?? 'Seller Name',
            //           style: const TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),

            // Product Image
            Center(
              child: Image.network(
                widget.product.imageUrl.isNotEmpty
                    ? widget.product.imageUrl
                    : '',
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 250);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Product Name
            Text(
              widget.product.name ?? 'Product Name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Price Display
            Text(
              '${widget.product.price} ฿',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            // Description
            ListTile(
              leading: const Icon(Icons.description_sharp, color: Colors.orange),
              title: Text(widget.product.detail,style: const TextStyle(fontSize: 14),),
            ),
            const ListTile(
              leading: Icon(Icons.local_shipping, color: Colors.orange),
              title: Text(
                  'Shipping fee: 50฿',style: TextStyle(fontSize: 14),),
            ),
            const SizedBox(height: 20),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isAddingToCart ? null : () async {
                  setState(() {
                    isAddingToCart = true; // Disable the button
                  });

                  // Handle add to cart functionality
                  await addToCart(widget.product.id);

                  setState(() {
                    isAddingToCart = false; // Enable the button again
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  isAddingToCart ? 'Adding...' : 'Add to Cart',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    //  bottomNavigationBar: BottomAppBar(
    //     shape: const CircularNotchedRectangle(),
    //     notchMargin: 10,
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: [
    //         IconButton(
    //           icon: const Icon(Icons.home),
    //           onPressed: () {
    //             // Action for home
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => const MyProductScreen(), // Pass loggedInUserId
    //               ),
    //             );
    //           },
    //         ),
    //         IconButton(
    //           icon: const Icon(Icons.shopping_cart),
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => MyCartScreen(userId: Configure.loggedInUserId!), // Pass loggedInUserId
    //               ),
    //             );
    //           },
    //         ),
    //         IconButton(
    //           icon: const Icon(Icons.favorite),
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => const FavoritePage(), // Navigate to favorite page
    //               ),
    //             );
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    );
  }

Future<void> addToCart(String? productId) async {
  // Check if productId is not null before proceeding
  if (productId != null && Configure.loggedInUserId != null) {
    // Fetch the latest user data from the database
    Users updatedUser = await fetchUserData(currentUser.id!); // Use '!' to assert non-null

    // Check if the product is already in the cart
    // if (updatedUser.cartItems.contains(productId)) {
    //   print('Product is already in the cart: $productId');
    //   return; // Do nothing if it's already in the cart
    // }

    // Add product ID to cartItems
    updatedUser.cartItems.add(productId);

    // Construct the URL for updating the user data
    final url = Uri.parse('http://${Configure.server}/users/${updatedUser.id}');

    // Convert user data to JSON and send a PUT request
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedUser.toJson()),
    );

    if (response.statusCode == 200) {
      print('User updated successfully: ${updatedUser.fullname}');
      setState(() {
        currentUser = updatedUser; // Update the local user state
      });
    } else {
      print('Failed to update user: ${response.statusCode} ${response.body}');
    }

    print('Current User: ${updatedUser.fullname}');
    print('Added Product ID: $productId to Cart');
  } else {
    print('Product ID or User ID is null');
  }
}


  Future<Users> fetchUserData(String userId) async {
    final url = Uri.parse('http://${Configure.server}/users/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Users.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user data');
    }
  }
}

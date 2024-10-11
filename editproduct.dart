import 'package:flutter/material.dart';
import 'package:flutter1/afterlogin.dart';
import 'package:flutter1/config/users.dart';

class EditProductScreen extends StatelessWidget {
  final String productName;
  final String productDescription;
  final String productPrice;
  final String productImageUrl;
  final Product product;
  final Function(Product) onSave; // Callback to save the updated product

  const EditProductScreen({super.key, 
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productImageUrl,
    required this.product,
    required this.onSave, // Initialize the callback
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: productName);
    final TextEditingController descriptionController = TextEditingController(text: productDescription);
    final TextEditingController priceController = TextEditingController(text: productPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
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
            //       child: Icon(Icons.person, size: 40),
            //     ),
            //     SizedBox(width: 10),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         // Display user's name from Configure
            //         Text(
            //           Configure.login.fullname ?? 'Username',
            //           style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),

            // Product image
            Image.network(
              productImageUrl,
              height: 200,
            ),
            const SizedBox(height: 40),

            // Product name input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Product Name',
              ),
            ),
            const SizedBox(height: 20),

            // Product description input
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 20),

            // Product price input
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: '฿', // Thai Baht currency symbol
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                labelText: 'Price',
              ),
            ),
            const SizedBox(height: 20),

            // OK button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Create a new Product object with updated values
                  Product updatedProduct = Product(
                    id: product.id,
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    detail: descriptionController.text,
                    imageUrl: product.imageUrl, // Keeping the same image URL for now
                  );

                  // Call the onSave callback with the updated product
                  onSave(updatedProduct);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyProductScreen()), // Go back to the previous screen after saving
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
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
}
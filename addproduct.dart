import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter1/afterlogin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'config/config.dart'; // Import your configuration file


class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDetailController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  File? _image; // Variable to hold the selected image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  // Function to upload image to Imgur and handle product submission
  Future<void> _submitProduct() async {
    if (_image == null ||
        _productNameController.text.isEmpty ||
        _productDetailController.text.isEmpty ||
        _productPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    try {
      // Upload image to Imgur
      String? imageUrl = await _uploadImageToImgur();

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image to Imgur')),
        );
        return;
      }
//UUID
      // Generate a new product ID using UUID
      const Uuid uuid = Uuid();
      String newProductId = uuid.v4();

      // Create a product object ObJECt
      final productData = {
        "id": newProductId,
        "name": _productNameController.text,
        "detail": _productDetailController.text,
        "price": int.parse(_productPriceController.text),
        "imageUrl": imageUrl, // Save the image URL
      };
//UUID

      // Specify the URL for adding the product
      final Uri apiUrl = Uri.http(Configure.server, '/products');

      // Send a POST request to the API
      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(productData), // Convert the product data to JSON
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProductScreen()), // Navigate to MyProductScreen
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add product')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to upload image to Imgur
  Future<String?> _uploadImageToImgur() async {
    final uri = Uri.parse('https://api.imgur.com/3/image');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Client-ID ccd8a8239cb27dd' // Your Imgur Client ID
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final result = json.decode(String.fromCharCodes(responseData));

      // Return the link of the uploaded image
      return result['data']['link'];
    } else {
      return null; // Return null if the upload failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
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
            // Upload photo button
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    'Upload Photo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            if (_image != null) ...[
              const SizedBox(height: 10),
              Image.file(
                _image!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 20),

            // Product name input
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                hintText: 'Product Name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product detail input
            TextField(
              controller: _productDetailController,
              decoration: InputDecoration(
                hintText: 'Detail',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Price input
            TextField(
              controller: _productPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Price',
                suffixText: '฿', // Thai Baht currency symbol
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Add Product',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   shape: const CircularNotchedRectangle(),
      //   notchMargin: 10,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       IconButton(
      //         icon: const Icon(Icons.home),
      //         onPressed: () {
      //           // Action for home
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const MyProductScreen(), // Pass loggedInUserId
      //             ),
      //           );
      //         },
      //       ),
      //       IconButton(
      //         icon: const Icon(Icons.shopping_cart),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => MyCartScreen(userId: Configure.loggedInUserId!), // Pass loggedInUserId
      //             ),
      //           );
      //         },
      //       ),
      //       IconButton(
      //         icon: const Icon(Icons.favorite),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const FavoritePage(), // Navigate to favorite page
      //             ),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter1/afterlogin.dart';
import 'package:http/http.dart' as http; // For API calls
import 'config/config.dart'; // Import config.dart for API info
import 'config/users.dart'; // Import Users model

void main() => runApp(const LoginApp());

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loginFailed = false;

  Future<void> _handleLogin() async {
    // Get input values from the user
    String inputEmail = _emailController.text;
    String inputPassword = _passwordController.text;

    // Construct the API endpoint
    final Uri apiUrl = Uri.http(Configure.server, '/users');

    try {
      // Make an API call to fetch users data
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        // Parse the response body
        List<Users> users = usersFromJson(response.body);

        // Find user that matches the email and password
var user = users.firstWhere(
  (user) => user.email == inputEmail && user.password == inputPassword,
);

// Successful login
setState(() {
  _loginFailed = false;
  Configure.login = user; // Set the logged-in user in config
  Configure.loggedInUserId = user.id; // เก็บ ID ของผู้ใช้ที่ล็อกอิน
});

        // Navigate or show success message
        print("Login successful!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProductScreen()),
        );
            } else {
        // Handle server errors
        setState(() {
          _loginFailed = true;
        });
        print('Failed to load users');
      }
    } catch (e) {
      setState(() {
        _loginFailed = true;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          // IconButton(
          //   icon: const Icon(Icons.help_outline, color: Colors.orange),
          //   onPressed: () {
          //     // Handle help action
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40), // Add spacing from top
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40), // Spacing between icon and form

            // Username (Email) field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20), // Space between the fields

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 40), // Space between fields and button

            // Show error if login failed
            if (_loginFailed)
              const Text(
                'Login failed! Incorrect email or password.',
                style: TextStyle(color: Colors.red),
              ),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 50, // Make the button larger
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

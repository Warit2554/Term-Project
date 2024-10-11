import 'package:flutter/material.dart';
import 'package:flutter1/topupcomplete.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/config.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _moneyController = TextEditingController();

  // ฟังก์ชันสำหรับอัปเดตจำนวนเงินในฐานข้อมูล
  Future<void> _topUpMoney() async {
    final String moneyStr = _moneyController.text;
    
    if (moneyStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    try {
      final double money = double.parse(moneyStr);

      // อัปเดตข้อมูลผู้ใช้ใน jsonserver
      final url = Uri.parse('http://${Configure.server}/users/${Configure.login.id}');
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'money': Configure.login.money + money, // เพิ่มจำนวนเงินเข้าไปในบัญชีผู้ใช้
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          Configure.login.money = Configure.login.money + money; // อัปเดตเงินใน UI
        });
        ScaffoldMessenger.of(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TopUpCompleteScreen(), // ไปที่หน้าการเติมเงินสำเร็จ
        ),
      );




      } else {
        throw Exception('Failed to top up');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount. Please enter a valid number.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top up'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ส่วนข้อมูลผู้ใช้ (ชื่อและรูปโปรไฟล์)
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: AssetImage(Configure.login.imageUrl ??
                      'assets/images/placeholder.jpeg'), // รูปภาพแทนที่เป็นค่าเริ่มต้น
                 
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // แสดงชื่อผู้ใช้
                    Text(
                      Configure.login.fullname ?? 'Username',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ข้อมูล Followers/Following
                    // Text(
                    //   '${Configure.login.follower} Followers   ${Configure.login.following} Following',
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //   ),
                    // ),
                  ],
                  
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ช่องกรอกจำนวนเงิน
            TextField(
              controller: _moneyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter amount',
                suffixText: '฿', // แสดงหน่วยเงิน
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่ม OK
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _topUpMoney,
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
      // bottomNavigationBar: BottomAppBar(
      //   shape: CircularNotchedRectangle(),
      //   notchMargin: 10,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       IconButton(
      //         icon: Icon(Icons.home),
      //         onPressed: () {
      //           // ฟังก์ชันเมื่อกดปุ่ม Home
      //         },
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.shopping_cart),
      //         onPressed: () {
      //           // ฟังก์ชันเมื่อกดปุ่ม Cart
      //         },
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.favorite),
      //         onPressed: () {
      //           // ฟังก์ชันเมื่อกดปุ่ม Favorite
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
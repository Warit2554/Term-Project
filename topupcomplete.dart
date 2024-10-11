import 'package:flutter/material.dart';
import 'package:flutter1/afterlogin.dart';

class TopUpCompleteScreen extends StatefulWidget {
  const TopUpCompleteScreen({super.key});

  @override
  _TopUpCompleteScreenState createState() => _TopUpCompleteScreenState();
}

class _TopUpCompleteScreenState extends State<TopUpCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // ตั้งเวลา 2 วินาทีแล้วเปลี่ยนไปที่หน้าที่ต้องการ
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyProductScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top up complete'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ฟังก์ชันเมื่อกดปุ่ม back
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ไอคอนวงกลมและเครื่องหมายถูก
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            // ข้อความ "สำเร็จ"
            const Text(
              'Complete !!!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            // ข้อความ "Your Top up is complete !!!"
            const Text(
              'Your Top up is complete !!!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

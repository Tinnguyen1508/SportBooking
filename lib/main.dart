import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/review_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Đặt sân thể thao',

      // Màn hình đầu tiên vẫn là đăng nhập
      //home: const LoginScreen(),
       //home: const PaymentScreen(),
       home: const ReviewScreen(),

      // Các màn hình khác
      routes: {
        '/login': (context) => const LoginScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/review': (context) => const ReviewScreen(),
      },
    );
  }
}
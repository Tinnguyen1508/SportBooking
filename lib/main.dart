import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
<<<<<<< HEAD
import 'screens/register_screen.dart';
import 'screens/register_otp_screen.dart'; // Sử dụng màn hình OTP dành riêng cho đăng ký

=======
import 'screens/payment_screen.dart';
import 'screens/review_screen.dart';
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'SportBooking',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // Các route tĩnh khác nếu có...
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp-verify') {
          return MaterialPageRoute(
            builder: (context) => const RegisterOtpScreen(),
            settings: settings, // 🔥 QUAN TRỌNG: Phải truyền settings này để màn hình OTP nhận được arguments!
          );
        }
        return null;
=======
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
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
      },
    );
  }
}
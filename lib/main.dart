import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_otp_screen.dart'; // Sử dụng màn hình OTP dành riêng cho đăng ký

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
    );
  }
}

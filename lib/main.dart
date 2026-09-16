import 'package:flutter/material.dart';

// Import các màn hình Chủ sân
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_manager.dart'; // Import thêm màn hình quản lý trạng thái sân

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

      // Mở thẳng màn hình Dashboard Chủ sân
      home: const OwnerManagerScreen (),

      // Nơi đăng ký các đường dẫn (routes)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/review': (context) => const ReviewScreen(),
        '/owner-dashboard': (context) => const OwnerDashboardScreen(),
        '/owner-manager': (context) => const OwnerManagerScreen(), // Route trực tiếp đến giao diện xem trạng thái sân
      },
    );
  }
}
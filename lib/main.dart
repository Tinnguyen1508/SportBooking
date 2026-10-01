import 'package:flutter/material.dart';

// Import các màn hình chính trong hệ thống
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_stock.dart';
import 'owner/owner_manager.dart';
import 'owner/owner_branch.dart';
import 'owner/owner_revenue.dart';
import 'owner/owner_customers.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_otp_screen.dart'; // Màn hình OTP dành riêng cho đăng ký
import 'screens/payment_screen.dart';
import 'screens/review_screen.dart';

void main() {
  runApp(const SportBookingApp());
}

class SportBookingApp extends StatelessWidget {
  const SportBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportBooking - Partner Owner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C40),
          primary: const Color(0xFF0D5C40),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      // Màn hình khởi chạy ban đầu: Đăng nhập
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/review': (context) => const ReviewScreen(),

        // Các màn hình chủ sân
        '/dashboard': (context) => const OwnerDashboardScreen(),
        '/stock': (context) => const OwnerStockScreen(),
        '/manager': (context) => const OwnerManagerScreen(),
        '/branch': (context) => const OwnerBranchScreen(),
        '/revenue': (context) => const OwnerRevenueScreen(),
        '/customers': (context) => const OwnerCustomersScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp-verify') {
          return MaterialPageRoute(
            builder: (context) => const RegisterOtpScreen(),
            // Phải truyền settings để màn hình OTP nhận được arguments
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
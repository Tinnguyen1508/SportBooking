import 'package:flutter/material.dart';

// Import các màn hình chính trong hệ thống
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_stock.dart';
import 'owner/owner_manager.dart';
import 'owner/owner_branch.dart';
import 'owner/owner_revenue.dart';
import 'owner/owner_customers.dart';

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
      // Màn hình khởi chạy ban đầu: Dashboard
      home: const OwnerDashboardScreen(),

      // Định nghĩa các Route dễ dàng điều hướng
      routes: {
        '/dashboard': (context) => const OwnerDashboardScreen(),
        '/stock': (context) => const OwnerStockScreen(),
        '/manager': (context) => const OwnerManagerScreen(),
        '/branch': (context) => const OwnerBranchScreen(),
        '/revenue': (context) => const OwnerRevenueScreen(),
        '/customers': (context) => const OwnerCustomersScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/slot_picker_screen.dart';
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

      // Test trực tiếp màn hình Review với dữ liệu mẫu
      home: const ReviewScreen(
        bookingId: 1,
        userId: 1,
        courtName: 'Sân Cầu Lông Alobo',
      ),

      // Khai báo danh sách Routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/home': (context) => const HomeScreen(),
        '/slot-picker': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return SlotPickerScreen(
            courtId: args?['courtId'] ?? 1,
            courtName: args?['courtName'] ?? 'Chi tiết sân',
          );
        },
        '/review': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ReviewScreen(
            bookingId: args?['bookingId'] ?? 1,
            userId: args?['userId'] ?? 1,
            courtName: args?['courtName'] ?? 'Sân Cầu Lông Alobo',
          );
        },
      },
    );
  }
}
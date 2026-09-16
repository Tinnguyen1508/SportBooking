import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Import các màn hình Chủ sân
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_manager.dart';

import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/review_screen.dart';

// Cấu hình kéo thả bằng chuột/trackpad trên Web & Desktop cho toàn bộ App
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

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
      scrollBehavior: AppScrollBehavior(), // Kích hoạt thao tác kéo chuột mượt mà

      // Mở trực tiếp màn hình Quản lý sân
      home: const OwnerManagerScreen(),

      // Danh sách các đường dẫn (routes)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/review': (context) => const ReviewScreen(),
        '/owner-dashboard': (context) => const OwnerDashboardScreen(),
        '/owner-manager': (context) => const OwnerManagerScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';

// Import màn hình quản lý cụm sân vừa tạo
import 'owner/owner_branch.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BadmintonBookingApp());
}

class BadmintonBookingApp extends StatelessWidget {
  const BadmintonBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo đồng bộ toàn hệ thống
    const Color primaryColor = Color(0xFF0D5C40);

    return MaterialApp(
      title: 'Badminton Booking System',
      debugShowCheckedModeBanner: false,

      // Cấu hình Theme tổng thể khớp với thiết kế Database & UI
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surfaceContainerLowest: const Color(0xFFF4F5F7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        
        // Font chữ & TextStyle chuẩn
        fontFamily: 'Roboto', // Hoặc font hệ thống mặc định

        // Style chung cho AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Style chung cho Form Input (khớp với Database fields)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        ),

        // Style chung cho Nút bấm (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),

      // Điều hướng trực tiếp đến Màn hình Quản lý Cụm sân của Chủ sân (Owner)
      home: const OwnerBranchScreen(),
    );
  }
}
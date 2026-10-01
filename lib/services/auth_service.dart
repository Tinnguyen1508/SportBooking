import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Địa chỉ IP Backend Node.js
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth';
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return 'http://localhost:5000/api/auth';
    } else {
      return 'http://10.0.2.2:5000/api/auth';
    }
  }

  // --- BƯỚC 1: GỬI MÃ OTP ĐĂNG KÝ (Chưa lưu DB) ---
  static Future<Map<String, dynamic>> sendRegisterOtp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'), // Trỏ đúng route /api/auth/send-otp
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  // --- BƯỚC 2: XÁC THỰC OTP & HOÀN TẤT ĐĂNG KÝ (Lưu DB) ---
  static Future<Map<String, dynamic>> verifyAndRegister({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String role,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/verify-register',
        ), // Trỏ đúng route /api/auth/verify-register
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
          'role': role,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Lưu token vào thiết bị khi đăng ký và xác thực thành công
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  // 3. GỌI API ĐĂNG NHẬP (Giữ nguyên)
  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrPhone': emailOrPhone, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String phoneOrEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'), // Trỏ đúng route backend của bạn
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneOrEmail': phoneOrEmail}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  static Future<Map<String, dynamic>> resendForgotOtp({
    required String phoneOrEmail,
  }) async {
    // Tái sử dụng chính API forgotPassword vì backend đã có sẵn logic gửi mã
    return await forgotPassword(phoneOrEmail: phoneOrEmail);
  }

  static Future<Map<String, dynamic>> resendRegisterOtp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    return await sendRegisterOtp(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      role: role,
    );
  }

  static Future<Map<String, dynamic>> verifyForgotOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-forgot-otp'),
        headers: {'Content-Type': 'application/json'},
        // 💡 Đã đổi 'phone' thành 'phoneOrEmail' để khớp với Backend
        body: jsonEncode({'phoneOrEmail': phone, 'otp': otp}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  // ==========================================
  // 5. ĐẶT LẠI MẬT KHẨU MỚI
  // ==========================================
  static Future<Map<String, dynamic>> resetPassword({
    required String phoneOrEmail,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'), // Trỏ đúng route backend của bạn
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneOrEmail': phoneOrEmail,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }
}

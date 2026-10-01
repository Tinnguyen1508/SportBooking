import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Có thể nhập SĐT hoặc Email
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  // Đọc vai trò: ưu tiên field backend trả về, nếu không có thì đọc trong JWT
  String? _extractRole(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map && user['role'] != null) return user['role'].toString();
    if (data['role'] != null) return data['role'].toString();

    try {
      final parts = (data['token'] ?? '').toString().split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        if (payload is Map && payload['role'] != null) {
          return payload['role'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // ==============================
  // Xử lý đăng nhập bằng SĐT hoặc Email
  // ==============================
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // AuthService.login tự lưu token vào SharedPreferences (key 'userToken')
    // và tự chọn địa chỉ server theo nền tảng (Web / Windows / Android)
    final data = await AuthService.login(
      emailOrPhone: _emailOrPhoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (data['success'] != true) {
      _showMessage(
        data['message'] ?? 'Tài khoản hoặc mật khẩu không chính xác!',
        isError: true,
      );
      return;
    }

    _showMessage(data['message'] ?? 'Đăng nhập thành công!');

    final role = _extractRole(data)?.toUpperCase();
    if (role == 'OWNER') {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (role == null) {
      _showMessage(
        'Đăng nhập thành công nhưng không đọc được vai trò. Kiểm tra dữ liệu /api/auth/login trả về.',
        isError: true,
      );
    } else {
      _showMessage(
        'Tài khoản khách hàng chưa có màn hình trong ứng dụng này.',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          // BACKGROUND
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),

          // LỚP PHỦ MỜ
          child: Container(
            color: Colors.white.withValues(alpha: 0.85),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),

                // GIỚI HẠN CHIỀU RỘNG FORM
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          // TIÊU ĐỀ
                          const Text(
                            'Đăng Nhập',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 35),

                          // SỐ ĐIỆN THOẠI HOẶC EMAIL
                          TextFormField(
                            controller: _emailOrPhoneController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại hoặc Email',
                              hintText: 'Nhập SĐT hoặc Email của bạn',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập số điện thoại hoặc email';
                              }

                              final input = value.trim();

                              // Kiểm tra SĐT hoặc Email hợp lệ
                              final isPhone = RegExp(
                                r'^(0|\+84)[3|5|7|8|9][0-9]{8}$',
                              ).hasMatch(input);
                              final isEmail = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(input);

                              if (!isPhone && !isEmail) {
                                return 'Số điện thoại hoặc định dạng email không hợp lệ';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // MẬT KHẨU
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }

                              if (value.length < 6) {
                                return 'Mật khẩu phải từ 6 ký tự trở lên';
                              }

                              return null;
                            },
                          ),

                          // QUÊN MẬT KHẨU
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // NÚT ĐĂNG NHẬP
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ĐĂNG KÝ
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Chưa có tài khoản? '),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Đăng ký ngay',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
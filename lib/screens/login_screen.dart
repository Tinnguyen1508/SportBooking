import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Thư viện gọi API

import 'dart:convert';

import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Đổi tên controller để phản ánh việc có thể nhập SĐT hoặc Email
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  // ==============================
  // Xử lý đăng nhập bằng SĐT hoặc Email
  // ==============================
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
<<<<<<< HEAD
      final emailOrPhone = _emailOrPhoneController.text.trim();
      final password = _passwordController.text;
=======
      
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986

      try {
        // ⚠️ LƯU Ý ĐỊA CHỈ URL:
        // - Nếu chạy máy ảo Android (Emulator): Dùng 'http://10.0.2.2:5000/api/auth/login'
        // - Nếu chạy máy điện thoại thật (cùng Wi-Fi): Dùng IP LAN máy tính của bạn (VD: 'http://192.168.1.X:5000/api/auth/login')
        final url = Uri.parse('http://localhost:5000/api/auth/login');

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'emailOrPhone': emailOrPhone,
            'password': password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (!mounted) return;

        if (response.statusCode == 200 && responseData['success'] == true) {
          // Đăng nhập thành công -> Thông báo và lấy Token
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Đăng nhập thành công!'),
            ),
          );

          final token = responseData['token'];
          // TODO: Lưu token này lại bằng SharedPreferences nếu cần dùng cho các màn hình sau
          print('Token nhận được: $token');

          // Ví dụ chuyển hướng sang màn hình chính (nếu có):
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          // Đăng nhập thất bại (sai tài khoản hoặc mật khẩu do Backend trả về)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ??
                    'Tài khoản hoặc mật khẩu không chính xác!',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Lỗi kết nối mạng hoặc server Node.js chưa bật
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể kết nối đến máy chủ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

<<<<<<< HEAD
=======
  // ==============================
  // Xử lý đăng nhập Google
  // ==============================
  void _handleGoogleLogin() {
    

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đăng nhập bằng Google')));
  }

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
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
          // ==========================================
          // BACKGROUND
          // ==========================================
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================
          // LỚP PHỦ MỜ
          // ==========================================
          child: Container(
           color: Colors.white.withValues(alpha: 0.85),

            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),

                // ==========================================
                // GIỚI HẠN CHIỀU RỘNG FORM
                // ==========================================
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          // ==================================
                          // TIÊU ĐỀ
                          // ==================================
                          const SizedBox(height: 20),

                          const Text(
                            'Đăng Nhập',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 35),

                          // ==================================
                          // SỐ ĐIỆN THOẠI HOẶC EMAIL
                          // ==================================
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

                              // Kiểm tra xem user nhập vào là SĐT hay Email hợp lệ không
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

                          // ==================================
                          // MẬT KHẨU
                          // ==================================
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

                          // ==================================
                          // QUÊN MẬT KHẨU
                          // ==================================
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
<<<<<<< HEAD
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
=======
                               
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                              },
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==================================
                          // NÚT ĐĂNG NHẬP
                          // ==================================
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

                          // ==================================
                          // ĐĂNG KÝ
                          // ==================================
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
import 'package:flutter/material.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  // ==============================
  // Xử lý đăng nhập bằng số điện thoại
  // ==============================
  void _handlePhoneLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Gọi API đăng nhập bằng SĐT & Mật khẩu

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));
    }
  }

  // ==============================
  // Xử lý đăng nhập Google
  // ==============================
  void _handleGoogleLogin() {
    // TODO: Gọi hàm GoogleSignIn().signIn()

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đăng nhập bằng Google')));
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
            color: Colors.white.withOpacity(0.85),

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
                          // SỐ ĐIỆN THOẠI
                          // ==================================
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,

                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              hintText: 'Nhập số điện thoại',

                              prefixIcon: const Icon(Icons.phone_android),

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
                                return 'Vui lòng nhập số điện thoại';
                              }

                              if (!RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$')
                                  .hasMatch(value)) {
                                return 'Số điện thoại không hợp lệ';
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
                                return 'Mật khẩu phải từ 6 ký tự';
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
                                // TODO: Xử lý quên mật khẩu
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
                              onPressed: _handlePhoneLogin,

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

                          const SizedBox(height: 25),

                          // ==================================
                          // PHÂN CÁCH
                          // ==================================
                          const Row(
                            children: [
                              Expanded(child: Divider()),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Hoặc',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),

                              Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // ==================================
                          // GOOGLE
                          // ==================================
                          SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _handleGoogleLogin,

                              icon: Image.asset(
                                'assets/images/google_logo.png',
                                width: 24,
                                height: 24,
                              ),

                              label: const Text(
                                'Tiếp tục với Google',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),

                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,

                                side: const BorderSide(color: Colors.grey),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

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

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // =========================================================
  // MÀU GIAO DIỆN
  // =========================================================
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  // =========================================================
  // FORM
  // =========================================================
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // =========================================================
  // LOẠI TÀI KHOẢN
  // =========================================================
  String _accountType = 'Người chơi';

  // =========================================================
  // HIỆN / ẨN MẬT KHẨU
  // =========================================================
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ==========================================
  // XỬ LÝ ĐĂNG KÝ & GỬI OTP
  // ==========================================
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    // 1. Hiển thị Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Gọi API Gửi OTP từ AuthService
    final result = await AuthService.sendRegisterOtp(
      fullName: _nameController.text.trim(),
      phone: phone,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _accountType,
    );

    // Tắt Loading
    if (mounted) Navigator.pop(context);

    // 3. Xử lý kết quả trả về
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã gửi mã OTP xác thực đến số điện thoại!'),
          ),
        );

        // Chuyển sang màn hình OTP và TRUYỀN ĐẦY ĐỦ THÔNG TIN ĐĂNG KÝ
        Navigator.pushNamed(
          context,
          '/otp-verify',
          arguments: {
            'fullName': _nameController.text.trim(),
            'phone': phone,
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'role': _accountType,
          },
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${result['message'] ?? 'Không thể gửi OTP'}'),
          ),
        );
      }
    }
  }

  // =========================================================
  // GIẢI PHÓNG CONTROLLER
  // =========================================================
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.white.withOpacity(0.85),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Tạo tài khoản',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Đăng ký để bắt đầu đặt sân',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: greyText),
                          ),
                          const SizedBox(height: 30),

                          // HỌ VÀ TÊN
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              hint: 'Họ và tên',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              if (value.trim().length < 2) {
                                return 'Họ và tên không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // SỐ ĐIỆN THOẠI
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              hint: 'Số điện thoại',
                              icon: Icons.phone_android,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
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

                          // EMAIL
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: 'Nhập địa chỉ email',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null; // Cho phép để trống nếu không bắt buộc
                              }
                              bool emailValid = RegExp(
                                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                              ).hasMatch(value.trim());
                              if (!emailValid) {
                                return 'Email không đúng định dạng';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // LOẠI TÀI KHOẢN
                          DropdownButtonFormField<String>(
                            value: _accountType,
                            decoration: _inputDecoration(
                              hint: 'Loại tài khoản',
                              icon: Icons.account_circle_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Người chơi',
                                child: Text('Người chơi'),
                              ),
                              DropdownMenuItem(
                                value: 'Chủ sân',
                                child: Text('Chủ sân'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _accountType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 18),

                          // MẬT KHẨU
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hint: 'Mật khẩu',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: greyText,
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
                          const SizedBox(height: 18),

                          // NHẬP LẠI MẬT KHẨU
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              _handleRegister();
                            },
                            decoration: _inputDecoration(
                              hint: 'Nhập lại mật khẩu',
                              icon: Icons.lock_reset_outlined,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: greyText,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập lại mật khẩu';
                              }
                              if (value != _passwordController.text) {
                                return 'Mật khẩu không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // NÚT ĐĂNG KÝ
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ĐÃ CÓ TÀI KHOẢN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Đã có tài khoản?',
                                style: TextStyle(color: greyText),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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
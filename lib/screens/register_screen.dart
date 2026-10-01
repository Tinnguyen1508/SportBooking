import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
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
  final _confirmPasswordController =
      TextEditingController();

  // =========================================================
  // LOẠI TÀI KHOẢN
  // =========================================================
  String _accountType = 'Người chơi';

  // =========================================================
  // HIỆN / ẨN MẬT KHẨU
  // =========================================================
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

<<<<<<< HEAD
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
=======
  // =========================================================
  // XỬ LÝ ĐĂNG KÝ
  // =========================================================
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Frontend demo.
      // Sau này có backend thì gọi API đăng ký tại đây.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng ký thành công với vai trò: $_accountType',
          ),
          backgroundColor: Colors.green,
        ),
      );
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
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

<<<<<<< HEAD
=======
  // =========================================================
  // STYLE CHUNG CHO Ô NHẬP
  // =========================================================
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
<<<<<<< HEAD
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
=======

      hintStyle: const TextStyle(
        color: greyText,
        fontSize: 15,
      ),

      prefixIcon: Icon(
        icon,
        color: greyText,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: borderColor,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.8,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
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
<<<<<<< HEAD
=======
          // =================================================
          // ẢNH BACKGROUND
          // =================================================
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/login_background.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
<<<<<<< HEAD
          child: Container(
            color: Colors.white.withOpacity(0.85),
=======

          // =================================================
          // LỚP PHỦ TRẮNG
          // =================================================
          child: Container(
            color: const Color.fromRGBO(
              255,
              255,
              255,
              0.93,
            ),

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
<<<<<<< HEAD
                    constraints: const BoxConstraints(maxWidth: 450),
=======
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                    child: Form(
                      key: _formKey,
                      child: Column(
<<<<<<< HEAD
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
=======
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,

                        children: [
                          // ===================================
                          // NÚT QUAY LẠI
                          // ===================================
                          Align(
                            alignment: Alignment.centerLeft,

                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: textColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // ===================================
                          // ICON
                          // ===================================
                          Center(
                            child: Container(
                              width: 76,
                              height: 76,

                              decoration: BoxDecoration(
                                color: const Color(
                                  0x1F6C4ED9,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  22,
                                ),
                              ),

                              child: const Icon(
                                Icons.person_add_alt_1,
                                color: primaryColor,
                                size: 40,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ===================================
                          // TIÊU ĐỀ
                          // ===================================
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
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

                            style: TextStyle(
                              fontSize: 15,
                              color: greyText,
                            ),
                          ),
<<<<<<< HEAD
                          const SizedBox(height: 30),

                          // HỌ VÀ TÊN
                          TextFormField(
                            controller: _nameController,
=======

                          const SizedBox(height: 32),

                          // ===================================
                          // HỌ VÀ TÊN
                          // ===================================
                          TextFormField(
                            controller: _nameController,

                            textInputAction:
                                TextInputAction.next,

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                            decoration: _inputDecoration(
                              hint: 'Họ và tên',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              if (value.trim().length < 2) {
                                return 'Họ và tên không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

<<<<<<< HEAD
                          // SỐ ĐIỆN THOẠI
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
=======
                          // ===================================
                          // SỐ ĐIỆN THOẠI
                          // ===================================
                          TextFormField(
                            controller: _phoneController,

                            keyboardType:
                                TextInputType.phone,

                            textInputAction:
                                TextInputAction.next,

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                            decoration: _inputDecoration(
                              hint: 'Số điện thoại',
                              icon: Icons.phone_android,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
<<<<<<< HEAD
                              if (!RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$')
                                  .hasMatch(value)) {
=======

                              final phone =
                                  value.trim();

                              if (!RegExp(
                                r'^(0|\+84)[35789][0-9]{8}$',
                              ).hasMatch(phone)) {
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                                return 'Số điện thoại không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

<<<<<<< HEAD
                          // EMAIL
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              label: 'Email',
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
=======
                          // ===================================
                          // LOẠI TÀI KHOẢN
                          // ===================================
                          DropdownButtonFormField<String>(
                            initialValue: _accountType,
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986

                          // LOẠI TÀI KHOẢN
                          DropdownButtonFormField<String>(
                            value: _accountType,
                            decoration: _inputDecoration(
                              hint: 'Loại tài khoản',
                              icon: Icons
                                  .account_circle_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Người chơi',
                                child: Text(
                                  'Người chơi',
                                ),
                              ),

                              DropdownMenuItem(
                                value: 'Chủ sân',
                                child: Text(
                                  'Chủ sân',
                                ),
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

<<<<<<< HEAD
                          // MẬT KHẨU
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration:
                                _inputDecoration(
                                  label: 'Mật khẩu',
                                  hint: 'Nhập mật khẩu',
                                  icon: Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
=======
                          // ===================================
                          // MẬT KHẨU
                          // ===================================
                          TextFormField(
                            controller:
                                _passwordController,

                            obscureText:
                                !_isPasswordVisible,

                            textInputAction:
                                TextInputAction.next,

                            decoration: _inputDecoration(
                              hint: 'Mật khẩu',
                              icon: Icons.lock_outline,

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible =
                                        !_isPasswordVisible;
                                  });
                                },

                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,

                                  color: greyText,
                                ),
                              ),
                            ),

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải từ 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

<<<<<<< HEAD
                          // NHẬP LẠI MẬT KHẨU
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration:
                                _inputDecoration(
                                  label: 'Nhập lại mật khẩu',
                                  hint: 'Nhập lại mật khẩu',
                                  icon: Icons.lock_reset_outlined,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
=======
                          // ===================================
                          // NHẬP LẠI MẬT KHẨU
                          // ===================================
                          TextFormField(
                            controller:
                                _confirmPasswordController,

                            obscureText:
                                !_isConfirmPasswordVisible,

                            textInputAction:
                                TextInputAction.done,

                            onFieldSubmitted: (_) {
                              _handleRegister();
                            },

                            decoration: _inputDecoration(
                              hint: 'Nhập lại mật khẩu',

                              icon:
                                  Icons.lock_reset_outlined,

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },

                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,

                                  color: greyText,
                                ),
                              ),
                            ),

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Vui lòng nhập lại mật khẩu';
                              }
<<<<<<< HEAD
                              if (value != _passwordController.text) {
=======

                              if (value !=
                                  _passwordController.text) {
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                                return 'Mật khẩu không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

<<<<<<< HEAD
                          // NÚT ĐĂNG KÝ
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
=======
                          // ===================================
                          // NÚT ĐĂNG KÝ
                          // ===================================
                          SizedBox(
                            height: 54,

                            child: ElevatedButton(
                              onPressed: _handleRegister,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    primaryColor,

                                foregroundColor:
                                    Colors.white,

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                                ),
                              ),
                              child: const Text(
                                'Đăng ký',

                                style: TextStyle(
                                  fontSize: 16,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

<<<<<<< HEAD
                          // QUAY LẠI ĐĂNG NHẬP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản? '),
=======
                          // ===================================
                          // ĐÃ CÓ TÀI KHOẢN
                          // ===================================
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              const Text(
                                'Đã có tài khoản?',

                                style: TextStyle(
                                  color: greyText,
                                ),
                              ),

>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Đăng nhập',

                                  style: TextStyle(
                                    color: primaryColor,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
<<<<<<< HEAD
                          const SizedBox(height: 15),
=======

                          const SizedBox(height: 20),
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
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
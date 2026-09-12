import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _accountType = 'Người chơi';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ==========================================
  // XỬ LÝ ĐĂNG KÝ
  // ==========================================

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // TODO: Gọi API đăng ký

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================
  // WIDGET Ô NHẬP
  // ==========================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
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

                          const SizedBox(height: 10),

                          const Text(
                            'Tạo tài khoản',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Đăng ký để bắt đầu đặt sân',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),

                          const SizedBox(height: 30),

                          // ==================================
                          // HỌ VÀ TÊN
                          // ==================================
                          TextFormField(
                            controller: _nameController,

                            decoration: _inputDecoration(
                              label: 'Họ và tên',
                              hint: 'Nhập họ và tên',
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

                          // ==================================
                          // SỐ ĐIỆN THOẠI
                          // ==================================
                          TextFormField(
                            controller: _phoneController,

                            keyboardType: TextInputType.phone,

                            decoration: _inputDecoration(
                              label: 'Số điện thoại',
                              hint: 'Nhập số điện thoại',
                              icon: Icons.phone_android,
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
                          // LOẠI TÀI KHOẢN
                          // ==================================
                          DropdownButtonFormField<String>(
                            initialValue: _accountType,

                            decoration: _inputDecoration(
                              label: 'Loại tài khoản',
                              hint: 'Chọn loại tài khoản',
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

                          // ==================================
                          // MẬT KHẨU
                          // ==================================
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

                          // ==================================
                          // NHẬP LẠI MẬT KHẨU
                          // ==================================
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

                          // ==================================
                          // NÚT ĐĂNG KÝ
                          // ==================================
                          SizedBox(
                            height: 50,

                            child: ElevatedButton(
                              onPressed: _handleRegister,

                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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

                          // ==================================
                          // QUAY LẠI ĐĂNG NHẬP
                          // ==================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              const Text('Đã có tài khoản? '),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },

                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),
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

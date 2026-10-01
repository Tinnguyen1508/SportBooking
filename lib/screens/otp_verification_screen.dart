import 'package:flutter/material.dart';

import '../services/auth_service.dart'; // Đảm bảo đường dẫn import AuthService đúng với dự án của bạn
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  // ==========================================
  // XỬ LÝ XÁC THỰC OTP QUÊN MẬT KHẨU
  // ==========================================
  void _handleVerifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();

    setState(() => _isLoading = true);

    // 1. Gọi API kiểm tra mã OTP quên mật khẩu
    // (Giả sử trong AuthService bạn có hàm verifyForgotOtp hoặc verifyOtp tương ứng)
    final response = await AuthService.verifyForgotOtp(
      phone: widget.phoneNumber,
      otp: otp,
    );

    setState(() => _isLoading = false);

    // 2. Kiểm tra kết quả trả về từ API
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Xác thực OTP thành công! Vui lòng đổi mật khẩu mới.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // 3. Chuyển sang màn hình đổi mật khẩu, đồng thời truyền dữ liệu phone & otp sang
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResetPasswordScreen(phoneNumber: widget.phoneNumber, otp: otp),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${response['message'] ?? 'Mã OTP không chính xác hoặc đã hết hạn!'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isResending = false;

  void _handleResendOTP() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    // Gọi trực tiếp hàm resendOtp trong AuthService
    final response = await AuthService.forgotPassword(
      phoneOrEmail: widget.phoneNumber,
    );

    setState(() => _isResending = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🔄 Đã gửi lại mã OTP mới! Vui lòng kiểm tra Terminal.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${response['message'] ?? 'Không thể gửi lại mã OTP'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.jpg'),
            fit: BoxFit.cover,
          ),
          color: Colors.white,
        ),
        child: Container(
          color: Colors.white.withOpacity(0.85),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),
                        const Icon(
                          Icons.sms_outlined,
                          size: 80,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Xác thực OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mã OTP đã được gửi đến số điện thoại\n${widget.phoneNumber}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 35),

                        // TEXTFIELD NHẬP OTP
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Mã OTP',
                            hintText: '••••••',
                            counterText: '',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
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
                              return 'Vui lòng nhập mã OTP';
                            }
                            if (value.length != 6) {
                              return 'Mã OTP phải gồm 6 số';
                            }
                            if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                              return 'OTP chỉ được chứa số';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // GỬI LẠI OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Chưa nhận được mã? '),
                            TextButton(
                              onPressed: _isLoading ? null : _handleResendOTP,
                              child: const Text(
                                'Gửi lại OTP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // NÚT XÁC NHẬN
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleVerifyOTP,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Xác nhận OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Quay lại',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
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

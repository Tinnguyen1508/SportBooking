import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  // --- BỔ SUNG BIẾN LƯU TRẠNG THÁI GỬI LẠI OTP ---
  bool _isResending = false;
  bool _canResend = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Bắt đầu đếm ngược 60s ngay khi mở màn hình
  }

  // Khởi chạy đồng hồ đếm ngược 60s
  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  // Hàm xử lý khi bấm nút Gửi lại OTP
  void _handleResendOtp() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Không tìm thấy thông tin đăng ký!'),
        ),
      );
      return;
    }

    setState(() => _isResending = true);

    // Gọi lại API sendRegisterOtp với dữ liệu từ màn hình đăng ký
    final response = await AuthService.sendRegisterOtp(
      fullName: args['fullName'] ?? '',
      phone: args['phone'] ?? '',
      email: args['email'] ?? '',
      password: args['password'] ?? '',
      role: args['role'] ?? 'CUSTOMER',
    );

    setState(() => _isResending = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Đã gửi lại mã OTP mới thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _startTimer(); // Chạy lại đếm ngược 60s
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${response['message'] ?? 'Không thể gửi lại mã OTP!'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verifyAndCompleteRegister() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lỗi: Không tìm thấy thông tin đăng ký!'),
        ),
      );
      return;
    }

    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Vui lòng nhập đầy đủ mã OTP 6 chữ số!'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.verifyAndRegister(
      fullName: args['fullName'],
      phone: args['phone'],
      email: args['email'] ?? '',
      password: args['password'],
      role: args['role'],
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? '🎉 Đăng ký thành công!'),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${response['message'] ?? 'Mã OTP không chính xác!'}',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer để tránh leak bộ nhớ
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final phone = args?['phone'] ?? 'số điện thoại của bạn';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực OTP Đăng ký'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Xác thực tài khoản',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Mã xác thực 6 chữ số đã được gửi qua SMS đến số:\n$phone',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '------',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyAndCompleteRegister,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Xác nhận & Hoàn tất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // --- NÚT GỬI LẠI MÃ OTP ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Chưa nhận được mã? ",
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: (_canResend && !_isResending && !_isLoading)
                      ? _handleResendOtp
                      : null,
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _canResend
                              ? 'Gửi lại mã'
                              : 'Gửi lại sau (${_secondsRemaining}s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _canResend ? Colors.blue : Colors.grey,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

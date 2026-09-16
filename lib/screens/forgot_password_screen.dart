<<<<<<< HEAD
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'otp_verification_screen.dart';
=======
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
<<<<<<< HEAD
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  // Thêm biến trạng thái để hiện loading nếu bạn muốn khóa nút khi đang gửi
  bool _isLoading = false;

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;
=======
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  // =========================================================
  // FORM KEYS
  // =========================================================
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // =========================================================
  // CONTROLLERS
  // =========================================================
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  // 1 = Nhập SĐT
  // 2 = Nhập OTP
  // 3 = Đặt mật khẩu mới
  int _step = 1;

  bool _isLoading = false;

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? _generatedOtp;

  int _seconds = 0;

  Timer? _timer;

  // =========================================================
  // GỬI OTP
  // =========================================================
  Future<void> _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) {
      return;
    }
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986

    setState(() {
      _isLoading = true;
    });

<<<<<<< HEAD
    try {
      final phoneOrEmail = _phoneController.text.trim();

      // Gọi đúng AuthService đã viết
      final result = await AuthService.forgotPassword(
        phoneOrEmail: phoneOrEmail,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi mã OTP thành công qua SMS!')),
        );

        // Chuyển sang màn hình nhập OTP sau khi server kích hoạt eSMS thành công
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpVerificationScreen(phoneNumber: phoneOrEmail),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Không thể gửi OTP!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi kết nối máy chủ: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu'), centerTitle: true),

      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
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
                          Icons.lock_reset,
                          size: 80,
                          color: Colors.blue,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Quên mật khẩu?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Nhập số điện thoại đã đăng ký.\n'
                          'Chúng tôi sẽ gửi mã OTP để xác nhận.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),

                        const SizedBox(height: 35),

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
                              return 'Vui lòng nhập số điện thoại';
                            }

                            if (!RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$')
                                .hasMatch(value)) {
                              return 'Số điện thoại không hợp lệ';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            // Khóa nút khi đang xử lý để tránh bấm liên tục
                            onPressed: _isLoading ? null : _handleSendOTP,

                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            // Hiển thị vòng quay loading hoặc chữ tùy theo trạng thái
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Gửi mã OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text(
                            'Quay lại đăng nhập',
                            style: TextStyle(fontSize: 15),
                          ),
=======
    // Giả lập thời gian gọi server
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    // =======================================================
    // FRONTEND DEMO:
    //
    // Tạo OTP ngẫu nhiên gồm 6 chữ số.
    //
    // Sau này Backend sẽ gửi OTP thật qua SMS.
    // =======================================================
    final random = Random();

    final otp =
        100000 + random.nextInt(900000);

    _generatedOtp = otp.toString();

    setState(() {
      _isLoading = false;
      _step = 2;
    });

    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP demo của bạn là: $_generatedOtp',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // =========================================================
  // COUNTDOWN
  // =========================================================
  void _startCountdown() {
    _timer?.cancel();

    setState(() {
      _seconds = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_seconds <= 1) {
          timer.cancel();

          if (mounted) {
            setState(() {
              _seconds = 0;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _seconds--;
            });
          }
        }
      },
    );
  }

  // =========================================================
  // GỬI LẠI OTP
  // =========================================================
  Future<void> _resendOtp() async {
    if (_seconds > 0) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    if (!mounted) return;

    final random = Random();

    final otp =
        100000 + random.nextInt(900000);

    _generatedOtp = otp.toString();

    _otpController.clear();

    setState(() {
      _isLoading = false;
    });

    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP mới của bạn là: $_generatedOtp',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // =========================================================
  // XÁC NHẬN OTP
  // =========================================================
  void _verifyOtp() {
    if (!_otpFormKey.currentState!.validate()) {
      return;
    }

    if (_otpController.text.trim() !=
        _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mã OTP không chính xác.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _step = 3;
    });
  }

  // =========================================================
  // ĐỔI MẬT KHẨU
  // =========================================================
  void _resetPassword() {
    if (!_passwordFormKey.currentState!
        .validate()) {
      return;
    }

    // =======================================================
    // FRONTEND DEMO
    //
    // Hiện tại chưa lưu mật khẩu vào Database.
    //
    // Sau này Backend sẽ xử lý đổi mật khẩu thật.
    // =======================================================

    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 55,
          ),

          title: const Text(
            'Đổi mật khẩu thành công',
            textAlign: TextAlign.center,
          ),

          content: const Text(
            'Bạn có thể đăng nhập bằng mật khẩu mới.',
            textAlign: TextAlign.center,
          ),

          actionsAlignment:
              MainAxisAlignment.center,

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // Quay lại Login
                Navigator.pop(context);
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,
              ),

              child: const Text(
                'Đăng nhập',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // BACK BUTTON
  // =========================================================
  void _goBack() {
    if (_step == 1) {
      Navigator.pop(context);
      return;
    }

    if (_step == 2) {
      setState(() {
        _step = 1;
      });

      return;
    }

    if (_step == 3) {
      setState(() {
        _step = 2;
      });
    }
  }

  // =========================================================
  // DECORATION
  // =========================================================
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: greyText,
      ),

      prefixIcon: Icon(
        icon,
        color: greyText,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: borderColor,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: primaryColor,
          width: 1.8,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // =========================================================
  // STEP 1 - PHONE
  // =========================================================
  Widget _buildPhoneStep() {
    return Form(
      key: _phoneFormKey,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          const Text(
            'Quên mật khẩu?',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,

              color: textColor,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Nhập số điện thoại đã đăng ký.\n'
            'Chúng tôi sẽ gửi mã OTP để xác thực.',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: greyText,
            ),
          ),

          const SizedBox(height: 36),

          TextFormField(
            controller:
                _phoneController,

            keyboardType:
                TextInputType.phone,

            decoration:
                _inputDecoration(
              hint:
                  'Số điện thoại',

              icon:
                  Icons.phone_android,
            ),

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }

              if (!RegExp(
                r'^(0|\+84)[35789][0-9]{8}$',
              ).hasMatch(
                value.trim(),
              )) {
                return 'Số điện thoại không hợp lệ';
              }

              return null;
            },
          ),

          const SizedBox(height: 26),

          SizedBox(
            height: 54,

            child: ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : _sendOtp,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),

              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,

                      child:
                          CircularProgressIndicator(
                        strokeWidth:
                            2,

                        color:
                            Colors.white,
                      ),
                    )
                  : const Text(
                      'Gửi mã OTP',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STEP 2 - OTP
  // =========================================================
  Widget _buildOtpStep() {
    return Form(
      key: _otpFormKey,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          const Text(
            'Xác thực OTP',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 30,
              fontWeight:
                  FontWeight.bold,

              color: textColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Mã OTP đã được gửi tới\n'
            '${_phoneController.text}',

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              color: greyText,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // ================================
          // OTP DEMO
          // ================================
          Container(
            padding:
                const EdgeInsets.all(
              16,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFF2EFFF,
              ),

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Column(
              children: [
                const Text(
                  'OTP DEMO',

                  style: TextStyle(
                    fontSize: 12,
                    color: greyText,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _generatedOtp ??
                      '',

                  style:
                      const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,

                    letterSpacing:
                        6,

                    color:
                        primaryColor,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                const Text(
                  'Frontend demo - chưa gửi SMS thật',

                  style: TextStyle(
                    fontSize: 11,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller:
                _otpController,

            keyboardType:
                TextInputType.number,

            textAlign:
                TextAlign.center,

            maxLength: 6,

            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
            ],

            style:
                const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,

              letterSpacing: 8,
            ),

            decoration:
                InputDecoration(
              counterText: '',

              hintText: '------',

              filled: true,
              fillColor:
                  Colors.white,

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),

                borderSide:
                    const BorderSide(
                  color:
                      borderColor,
                ),
              ),

              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),

                borderSide:
                    const BorderSide(
                  color:
                      primaryColor,

                  width: 2,
                ),
              ),
            ),

            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Vui lòng nhập OTP';
              }

              if (value.length != 6) {
                return 'OTP phải gồm 6 số';
              }

              return null;
            },
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,

            child: ElevatedButton(
              onPressed:
                  _verifyOtp,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),

              child: const Text(
                'Xác nhận OTP',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Text(
                'Chưa nhận được mã? ',

                style: TextStyle(
                  color: greyText,
                ),
              ),

              if (_seconds > 0)
                Text(
                  'Gửi lại (${_seconds}s)',

                  style:
                      const TextStyle(
                    color: greyText,
                  ),
                )
              else
                TextButton(
                  onPressed:
                      _resendOtp,

                  child:
                      const Text(
                    'Gửi lại',

                    style:
                        TextStyle(
                      color:
                          primaryColor,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STEP 3 - NEW PASSWORD
  // =========================================================
  Widget _buildPasswordStep() {
    return Form(
      key:
          _passwordFormKey,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          const Text(
            'Tạo mật khẩu mới',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 30,

              fontWeight:
                  FontWeight.bold,

              color: textColor,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Mật khẩu mới phải có ít nhất 6 ký tự.',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: greyText,
            ),
          ),

          const SizedBox(height: 36),

          TextFormField(
            controller:
                _passwordController,

            obscureText:
                !_showPassword,

            decoration:
                _inputDecoration(
              hint:
                  'Mật khẩu mới',

              icon:
                  Icons.lock_outline,

              suffixIcon:
                  IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword =
                        !_showPassword;
                  });
                },

                icon: Icon(
                  _showPassword
                      ? Icons
                          .visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),

            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Vui lòng nhập mật khẩu mới';
              }

              if (value.length <
                  6) {
                return 'Mật khẩu phải từ 6 ký tự';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller:
                _confirmPasswordController,

            obscureText:
                !_showConfirmPassword,

            decoration:
                _inputDecoration(
              hint:
                  'Nhập lại mật khẩu',

              icon:
                  Icons.lock_reset,

              suffixIcon:
                  IconButton(
                onPressed: () {
                  setState(() {
                    _showConfirmPassword =
                        !_showConfirmPassword;
                  });
                },

                icon: Icon(
                  _showConfirmPassword
                      ? Icons
                          .visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),

            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Vui lòng nhập lại mật khẩu';
              }

              if (value !=
                  _passwordController
                      .text) {
                return 'Mật khẩu không khớp';
              }

              return null;
            },
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,

            child: ElevatedButton(
              onPressed:
                  _resetPassword,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),

              child: const Text(
                'Đổi mật khẩu',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================
  @override
  void dispose() {
    _timer?.cancel();

    _phoneController.dispose();
    _otpController.dispose();

    _passwordController
        .dispose();

    _confirmPasswordController
        .dispose();

    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration:
              const BoxDecoration(
            image:
                DecorationImage(
              image: AssetImage(
                'assets/images/login_background.jpg',
              ),

              fit: BoxFit.cover,
            ),
          ),

          child: Container(
            color:
                const Color.fromRGBO(
              255,
              255,
              255,
              0.95,
            ),

            child: SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),

                child: Center(
                  child:
                      ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 430,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,

                      children: [
                        // BACK
                        Align(
                          alignment:
                              Alignment
                                  .centerLeft,

                          child:
                              IconButton(
                            onPressed:
                                _goBack,

                            icon:
                                const Icon(
                              Icons
                                  .arrow_back_ios_new,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // ICON
                        Center(
                          child:
                              Container(
                            width: 80,
                            height: 80,

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0x1F6C4ED9,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                24,
                              ),
                            ),

                            child: Icon(
                              _step == 1
                                  ? Icons
                                      .lock_reset
                                  : _step == 2
                                      ? Icons
                                          .verified_user_outlined
                                      : Icons
                                          .password_outlined,

                              size: 44,

                              color:
                                  primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        if (_step == 1)
                          _buildPhoneStep(),

                        if (_step == 2)
                          _buildOtpStep(),

                        if (_step == 3)
                          _buildPasswordStep(),

                        const SizedBox(
                          height: 30,
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 492b1911d44a4736fbc1b4f370bbddcb316c8986

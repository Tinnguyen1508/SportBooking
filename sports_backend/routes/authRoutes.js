const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Đăng ký bước 1: Kiểm tra thông tin và gửi OTP
router.post('/send-otp', authController.sendRegisterOtp);

// Đăng ký bước 2: Xác thực OTP và tạo tài khoản chính thức trong SQL Server
router.post('/verify-register', authController.verifyAndRegister);

// Đăng nhập
router.post('/login', authController.login);

// --- THÊM DÒNG NÀY ĐỂ KHỚP VỚI FLUTTER ---
router.post('/forgot-password', authController.forgotPassword);

router.post('/verify-forgot-otp', authController.verifyForgotOtp);

// 2. Đặt lại mật khẩu mới
router.post('/reset-password', authController.resetPassword);

module.exports = router;
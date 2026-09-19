const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const axios = require('axios');

// Bộ nhớ tạm lưu OTP trên RAM của server (Key: số điện thoại hoặc email, Value: { otp, expiresAt })
const otpStorage = new Map();

const generateToken = (userId) => {
    return jwt.sign(
        { id: userId }, 
        process.env.JWT_SECRET || 'fallback_secret_key', 
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
};

// ================= HÀM IN OTP RA TERMINAL (TEST MODE) =================
const sendRealSmsOtp = async (target, otpCode) => {
    // In chính xác mã OTP ngẫu nhiên được sinh ra ra Terminal để bạn dễ dàng nhìn thấy và nhập
    console.log(`\n========================================`);
    console.log(`🔑 [TEST MODE] Mã OTP gửi tới [ ${target} ] là: ${otpCode}`);
    console.log(`========================================\n`);

    return true; // Luôn trả về thành công để app chuyển màn hình mượt mà
};

// ================= 1. ĐĂNG KÝ - GỬI OTP =================
exports.sendRegisterOtp = async (req, res) => {
    try {
        const { fullName, phone, email, password, role } = req.body;

        const userExists = await User.findOne({
            where: {
                [Op.or]: [{ phone }, ...(email ? [{ email }] : [])]
            }
        });

        if (userExists) {
            return res.status(400).json({ success: false, message: 'Số điện thoại hoặc Email đã tồn tại!' });
        }

        // Sinh mã OTP 6 chữ số ngẫu nhiên
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        
        // Lưu OTP vào bộ nhớ tạm (hết hạn sau 5 phút) dùng Key là số điện thoại
        otpStorage.set(phone, {
            otp: otpCode,
            expiresAt: Date.now() + 5 * 60 * 1000
        });

        // Gọi hàm in OTP ra Terminal
        const isSent = await sendRealSmsOtp(phone, otpCode);
        if (!isSent) {
            return res.status(500).json({ success: false, message: 'Không thể gửi mã OTP, vui lòng thử lại!' });
        }

        res.status(200).json({
            success: true,
            message: 'Đã gửi mã OTP thành công!'
        });
    } catch (error) {
        console.error("Error in sendRegisterOtp:", error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ', error: error.message });
    }
};

// ĐĂNG KÝ - XÁC THỰC VÀ LƯU DB
exports.verifyAndRegister = async (req, res) => {
    try {
        const { fullName, phone, email, password, role, otp } = req.body;

        // Kiểm tra OTP trong bộ nhớ tạm theo số điện thoại
        const storedData = otpStorage.get(phone);
        if (!storedData || storedData.otp !== otp) {
            return res.status(400).json({ success: false, message: 'Mã OTP không chính xác hoặc đã hết hạn!' });
        }

        if (Date.now() > storedData.expiresAt) {
            otpStorage.delete(phone);
            return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn!' });
        }

        const userExists = await User.findOne({
            where: {
                [Op.or]: [{ phone }, ...(email ? [{ email }] : [])]
            }
        });

        if (userExists) {
            return res.status(400).json({ success: false, message: 'Số điện thoại hoặc Email này đã được đăng ký trước đó!' });
        }

        let formattedRole = 'CUSTOMER';
        if (role === 'Chủ sân' || role === 'OWNER') {
            formattedRole = 'OWNER';
        }

        const salt = await bcrypt.genSalt(10);
        const password_hash = await bcrypt.hash(password, salt);
        const cleanEmail = (!email || email.trim() === '') ? null : email.trim();

        const newUser = await User.create({
            full_name: fullName,
            phone: phone,
            email: cleanEmail,
            password_hash: password_hash,
            role: formattedRole
        });

        // Xóa OTP sau khi dùng thành công
        otpStorage.delete(phone);

        const token = generateToken(newUser.id);

        res.status(201).json({
            success: true,
            message: 'Đăng ký và xác thực thành công!',
            token,
            user: {
                id: newUser.id,
                fullName: newUser.full_name,
                phone: newUser.phone,
                email: newUser.email,
                role: newUser.role
            }
        });
    } catch (error) {
        console.error("Error in verifyAndRegister:", error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ', error: error.message });
    }
};

// ================= ĐĂNG NHẬP =================
exports.login = async (req, res) => {
    try {
        const { emailOrPhone, password } = req.body;

        const user = await User.findOne({
            where: {
                [Op.or]: [{ phone: emailOrPhone }, { email: emailOrPhone }]
            }
        });

        if (!user) {
            return res.status(400).json({ success: false, message: 'Tài khoản hoặc mật khẩu không chính xác' });
        }

        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(400).json({ success: false, message: 'Tài khoản hoặc mật khẩu không chính xác' });
        }

        const token = generateToken(user.id);

        res.status(200).json({
            success: true,
            message: 'Đăng nhập thành công!',
            token,
            user: {
                id: user.id,
                fullName: user.full_name,
                phone: user.phone,
                email: user.email,
                role: user.role,
                avatar: user.avatar_url
            }
        });
    } catch (error) {
        console.error("Error in login:", error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ', error: error.message });
    }
};

// ================= QUÊN MẬT KHẨU =================

// Gửi OTP quên mật khẩu
exports.forgotPassword = async (req, res) => {
    try {
        const { phoneOrEmail } = req.body;

        if (!phoneOrEmail) {
            return res.status(400).json({ success: false, message: 'Vui lòng cung cấp số điện thoại hoặc email!' });
        }

        const user = await User.findOne({
            where: {
                [Op.or]: [{ phone: phoneOrEmail }, { email: phoneOrEmail }]
            }
        });

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy tài khoản tương ứng!' });
        }

        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

        // Lưu OTP vào bộ nhớ tạm ứng với đúng giá trị phoneOrEmail mà client gửi lên
        otpStorage.set(phoneOrEmail, {
            otp: otpCode,
            expiresAt: Date.now() + 5 * 60 * 1000
        });

        // In OTP ra Terminal để dễ dàng kiểm tra
        await sendRealSmsOtp(phoneOrEmail, otpCode);

        return res.json({ 
            success: true, 
            message: 'Mã OTP đã được gửi thành công!'
        });
    } catch (error) {
        console.error('Lỗi gửi OTP quên mật khẩu:', error);
        return res.status(500).json({ success: false, message: error.message });
    }
};

// Xác thực OTP quên mật khẩu
exports.verifyForgotOtp = async (req, res) => {
  try {
    const { phoneOrEmail, otp } = req.body;
    
    if (!phoneOrEmail || !otp) {
      return res.status(400).json({ success: false, message: 'Vui lòng cung cấp đầy đủ thông tin' });
    }

    const storedData = otpStorage.get(phoneOrEmail);
    if (!storedData || storedData.otp !== otp) {
      return res.status(400).json({ success: false, message: 'Mã OTP không chính xác hoặc đã hết hạn!' });
    }

    if (Date.now() > storedData.expiresAt) {
      otpStorage.delete(phoneOrEmail);
      return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn!' });
    }

    return res.json({ success: true, message: 'Xác thực OTP thành công' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Đặt lại mật khẩu mới
exports.resetPassword = async (req, res) => {
  try {
    // 💡 Hứng cả 'phoneOrEmail' hoặc 'phone' tùy theo client truyền lên
    const phoneOrEmail = req.body.phoneOrEmail || req.body.phone;
    const { otp, newPassword } = req.body;

    if (!phoneOrEmail || !otp || !newPassword) {
      return res.status(400).json({ success: false, message: 'Thiếu thông tin bắt buộc' });
    }

    const storedData = otpStorage.get(phoneOrEmail);
    if (!storedData || storedData.otp !== otp) {
      return res.status(400).json({ success: false, message: 'Mã OTP không hợp lệ hoặc đã hết hạn!' });
    }

    if (Date.now() > storedData.expiresAt) {
      otpStorage.delete(phoneOrEmail);
      return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn!' });
    }

    const user = await User.findOne({
        where: {
            [Op.or]: [{ phone: phoneOrEmail }, { email: phoneOrEmail }]
        }
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy tài khoản!' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(newPassword, salt);

    user.password_hash = password_hash;
    await user.save();

    // Dọn dẹp OTP sau khi đổi mật khẩu thành công
    otpStorage.delete(phoneOrEmail);

    return res.json({ success: true, message: 'Đặt lại mật khẩu thành công và đã cập nhật vào SQL Server!' });
  } catch (error) {
    console.error('Lỗi đặt lại mật khẩu:', error);
    return res.status(400).json({ success: false, message: error.message });
  }
};
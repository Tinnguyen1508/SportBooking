const User = require('../models/User');

// 1. Lấy thông tin cá nhân người dùng đang đăng nhập
exports.getUserProfile = async (req, res) => {
    try {
        // req.user.id được giải mã từ token qua authMiddleware
        const user = await User.findByPk(req.user.id, {
            attributes: { exclude: ['password_hash'] }
        });

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        res.status(200).json({
            success: true,
            user: {
                id: user.id,
                fullName: user.full_name,
                phone: user.phone,
                email: user.email,
                role: user.role,
                avatar: user.avatar_url,
                createdAt: user.created_at
            }
        });
    } catch (error) {
        console.error("Lỗi getUserProfile:", error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ', error: error.message });
    }
};

// 2. Cập nhật thông tin cá nhân
exports.updateUserProfile = async (req, res) => {
    try {
        const { fullName, phone, email, avatarUrl } = req.body;
        const user = await User.findByPk(req.user.id);

        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        if (fullName !== undefined) user.full_name = fullName;
        if (phone !== undefined) user.phone = phone;
        if (email !== undefined) user.email = email;
        if (avatarUrl !== undefined) user.avatar_url = avatarUrl;

        await user.save();

        res.status(200).json({
            success: true,
            message: 'Cập nhật thông tin thành công!',
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
        console.error("Lỗi updateUserProfile:", error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ', error: error.message });
    }
};
exports.uploadAvatar = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'Chưa chọn file ảnh nào' });
        }

        const user = await User.findByPk(req.user.id);
        if (!user) {
            return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
        }

        // Đường dẫn URL ảnh公 khai công khai
        const avatarUrl = `http://127.0.0.1:5000/uploads/${req.file.filename}`;
        user.avatar_url = avatarUrl;
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Tải ảnh đại diện thành công!',
            avatarUrl: avatarUrl
        });
    } catch (error) {
        console.error("Lỗi uploadAvatar:", error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ', error: error.message });
    }
};
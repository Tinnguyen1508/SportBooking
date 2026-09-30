import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // Key constants
  static const String _keyUserId = 'user_id';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserAvatarUrl = 'user_avatar_url';
  static const String _keyUserCreatedAt = 'user_created_at';

  /// Lưu toàn bộ thông tin người dùng sau khi Đăng nhập / Đăng ký
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user['id'] ?? 0);
    await prefs.setString(_keyUserPhone, user['phone'] ?? '');
    await prefs.setString(_keyUserFullName, user['full_name'] ?? '');
    await prefs.setString(_keyUserRole, user['role'] ?? 'CUSTOMER');
    await prefs.setString(_keyUserEmail, user['email'] ?? '');
    await prefs.setString(_keyUserAvatarUrl, user['avatar_url'] ?? '');
    await prefs.setString(_keyUserCreatedAt, user['created_at'] ?? '');
  }

  /// Tải thông tin người dùng lưu trữ cục bộ
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_keyUserId) ?? 0,
      'phone': prefs.getString(_keyUserPhone) ?? 'Chưa cập nhật',
      'full_name': prefs.getString(_keyUserFullName) ?? 'Người dùng',
      'role': prefs.getString(_keyUserRole) ?? 'CUSTOMER',
      'email': prefs.getString(_keyUserEmail) ?? 'Chưa cập nhật',
      'avatar_url':
          prefs.getString(_keyUserAvatarUrl) ??
          'https://i.pravatar.cc/300?img=12',
      'created_at': prefs.getString(_keyUserCreatedAt) ?? '',
    };
  }

  /// Cập nhật ảnh đại diện người dùng
  static Future<void> updateAvatarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAvatarUrl, url);
  }

  /// Xóa toàn bộ dữ liệu bộ nhớ tạm khi Đăng xuất
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

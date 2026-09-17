import 'package:flutter/material.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);

  bool notificationsEnabled = true;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn thoát tài khoản quản trị?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: greyText))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đăng xuất thành công')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Tài khoản quản trị', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://images.unsplash.com/photo-1622279457486-62dcc4a631d6?q=80&w=1000&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: primaryColor,
                      child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quản trị viên', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                          SizedBox(height: 4),
                          Text('admin@pickleball.com', style: TextStyle(fontSize: 13, color: greyText)),
                          SizedBox(height: 2),
                          Text('Quyền hạn: Toàn quyền hệ thống', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Cài đặt tài khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: primaryColor),
                      title: const Text('Chỉnh sửa thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: greyText),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: primaryColor),
                      title: const Text('Đổi mật khẩu bảo mật', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: greyText),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text('Nhận thông báo đẩy', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                      secondary: const Icon(Icons.notifications_active_outlined, color: primaryColor),
                      activeColor: primaryColor,
                      value: notificationsEnabled,
                      onChanged: (val) => setState(() => notificationsEnabled = val),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: primaryColor),
                      title: const Text('Phiên bản ứng dụng', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                      trailing: const Text('v1.0.0', style: TextStyle(color: greyText, fontWeight: FontWeight.bold)),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Đăng xuất tài khoản', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
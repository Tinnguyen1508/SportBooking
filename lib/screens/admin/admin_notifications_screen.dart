import 'package:flutter/material.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);

  final List<Map<String, dynamic>> notifications = const [
    {
      'title': 'Đơn đặt sân mới',
      'message': 'Khách hàng Nguyễn Văn A vừa đặt Pickleball 1 lúc 18:00.',
      'time': '10 phút trước',
      'isRead': false,
    },
    {
      'title': 'Yêu cầu hủy lịch',
      'message': 'Lê Văn C đã yêu cầu hủy đơn đặt sân BK003.',
      'time': '1 giờ trước',
      'isRead': false,
    },
    {
      'title': 'Bảo trì hệ thống',
      'message': 'Lịch bảo trì sân Pickleball 3 đã hoàn tất.',
      'time': 'Hôm qua',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Thông báo hệ thống', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              bool isRead = notif['isRead'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRead ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.98),
                  borderRadius: BorderRadius.circular(14),
                  border: isRead ? null : Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(notif['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                              Text(notif['time'], style: const TextStyle(fontSize: 12, color: greyText)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(notif['message'], style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
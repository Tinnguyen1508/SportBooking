import 'package:flutter/material.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // Tông màu chủ đạo (Xanh lá đậm)
  static const Color primaryColor = Color(0xFF0D5C40);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  int _currentBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. THANH HEADER TRÊN CÙNG
              _buildTopHeader(),

              const SizedBox(height: 16),

              // 2. BANNER THÔNG TIN CÂU LẠC BỘ
              _buildClubBanner(),

              const SizedBox(height: 20),

              // 3. TIÊU ĐỀ MỤC QUẢN LÝ
              const Text(
                'Quản lý hệ thống',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // 4. LƯỚI CHỨC NĂNG (GRIDVIEW)
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),

      // 5. THANH MENU DƯỚI CÙNG (BOTTOM NAVIGATION BAR)
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Header trên cùng (Tiêu đề + Thông báo + Profile)
  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tổng quan hệ thống',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.black54),
              onPressed: () {
                _showToast('Chưa có thông báo mới');
              },
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/owner-account'),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Banner Câu lạc bộ
  Widget _buildClubBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_tennis_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALOBO SPORT CLUB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hệ thống quản lý trung tâm thể thao',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lưới chứa các ô chức năng chính
  Widget _buildDashboardGrid() {
    // Danh sách cấu hình các nút chức năng
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Xem trạng thái sân',
        'subtitle': 'Sơ đồ & Ca trống',
        'icon': Icons.apps_rounded,
        'iconBg': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFE65100),
        'route': '/owner-manager',
      },
      {
        'title': 'Bán hàng tại quầy',
        'subtitle': 'Tạo đơn & Check-in',
        'icon': Icons.point_of_sale_rounded,
        'iconBg': const Color(0xFFFFEBEE),
        'iconColor': const Color(0xFFC62828),
        'route': '/owner-shop',
      },
      {
        'title': 'Kho & dịch vụ',
        'subtitle': 'Nước uống, dụng cụ',
        'icon': Icons.inventory_2_rounded,
        'iconBg': const Color(0xFFFFEBEE),
        'iconColor': const Color(0xFFC62828),
        'route': '/owner-shop',
      },
      {
        'title': 'Doanh thu & Báo cáo',
        'subtitle': 'Tài chính',
        'icon': Icons.bar_chart_rounded,
        'iconBg': const Color(0xFFFCE4EC),
        'iconColor': const Color(0xFFAD1457),
        'route': null, // Bổ sung sau
      },
      {
        'title': 'Quản lý chi nhánh',
        'subtitle': 'Cụm sân & Cơ sở',
        'icon': Icons.storefront_rounded,
        'iconBg': const Color(0xFFE0F2F1),
        'iconColor': const Color(0xFF00695C),
        'route': null, // Bổ sung sau
      },
      {
        'title': 'Quản lý khách hàng',
        'subtitle': 'Hội viên & Tích điểm',
        'icon': Icons.groups_rounded,
        'iconBg': const Color(0xFFE8F5E9),
        'iconColor': const Color(0xFF2E7D32),
        'route': '/owner-customers',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Hiển thị 3 cột chuẩn như ảnh
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildCardItem(
          title: item['title'],
          subtitle: item['subtitle'],
          icon: item['icon'],
          iconBg: item['iconBg'],
          iconColor: item['iconColor'],
          onTap: () {
            if (item['route'] != null) {
              // Chuyển sang màn hình mới
              Navigator.pushNamed(context, item['route']);
            } else {
              _showToast('Chức năng "${item['title']}" đang phát triển');
            }
          },
        );
      },
    );
  }

  // Widget Thẻ chi tiết của từng ô
  Widget _buildCardItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Thanh điều hướng phía dưới
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: (index) {
        setState(() => _currentBottomIndex = index);
        switch (index) {
          case 0:
            // Đang ở Trang chủ
            break;
          case 1:
            Navigator.pushNamed(context, '/owner-manager');
            break;
          case 2:
            _showToast('Tính năng Duyệt đơn đang phát triển');
            break;
          case 3:
            Navigator.pushNamed(context, '/owner-shop');
            break;
          case 4:
            Navigator.pushNamed(context, '/owner-account');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Lịch đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified_rounded),
          label: 'Duyệt đơn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_rounded),
          label: 'Bán quầy & Kho',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
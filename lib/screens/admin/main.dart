import 'package:flutter/material.dart';
import 'admin_manage_services_screen.dart';
import 'admin_manage_courts_screen.dart';
import 'admin_manage_bookings_screen.dart';
import 'admin_manage_users_screen.dart';
import 'admin_schedule_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_account_screen.dart';
import 'admin_statistics_screen.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color textColor = Color(0xFF25232A);
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminAccountScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      
      // ===== THANH BOTTOM NAV NỔI (3 MỤC) =====
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFA5D6A7).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex > 2 ? 0 : _selectedIndex,
            onTap: _onBottomNavTapped,
            selectedItemColor: const Color(0xFF1E5631),
            unselectedItemColor: Colors.black54,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Thông báo'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
            ],
          ),
        ),
      ),

      // ===== ẢNH NỀN BACKGROUND TRANG CHỦ =====
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildStickyHeader(),
              Expanded(
                // LayoutBuilder + ConstrainedBox giúp background lấp đầy toàn bộ chiều cao cửa sổ Windows
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildOverviewSection(),
                            const SizedBox(height: 25),
                            _buildResponsiveGrid(context),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Text('AD', style: TextStyle(color: Color(0xFF1E5631), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              SizedBox(width: 12),
              Text('Admin', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()));
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_outlined, color: textColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E5631).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng quan hôm nay', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('15', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Lịch đặt sân', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('2.5tr', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Doanh thu', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Bảng lịch sân', 'icon': Icons.calendar_month, 'color': const Color(0xFF4CAF50), 'screen': const AdminScheduleScreen()},
      {'title': 'Quản lý lịch', 'icon': Icons.event_available, 'color': const Color(0xFF2196F3), 'screen': const AdminManageBookingsScreen()},
      {'title': 'Quản lý sân', 'icon': Icons.sports_tennis, 'color': const Color(0xFFFF9800), 'screen': const AdminManageCourtsScreen()},
      {'title': 'Dịch vụ', 'icon': Icons.room_service_outlined, 'color': const Color(0xFFE91E63), 'screen': const AdminManageServicesScreen()},
      {'title': 'Khách hàng', 'icon': Icons.people_outline, 'color': const Color(0xFF9C27B0), 'screen': const AdminManageUsersScreen()},
      {'title': 'Thống kê', 'icon': Icons.bar_chart, 'color': const Color(0xFF00BCD4), 'screen': const AdminStatisticsScreen()},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 700;
        double itemWidth = isWide 
            ? (constraints.maxWidth - (15 * 5)) / 6 
            : (constraints.maxWidth - 15) / 2;

        if (itemWidth > 125) itemWidth = 125;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 15,
          runSpacing: 15,
          children: menuItems.map((item) {
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'])),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: itemWidth,
                height: itemWidth * 1.1,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'], color: item['color'], size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
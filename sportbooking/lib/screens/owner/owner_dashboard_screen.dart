import 'package:flutter/material.dart';

import 'owner_account.dart'; // Import file màn hình tài khoản

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _bottomNavIndex = 0;
  int _activeModuleIndex = -1;

  // Màu chủ đạo
  static const Color primaryColor = Color(0xFF0D5C40);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            switch (index) {
              case 0:
                _activeModuleIndex = -1; // Trang chủ
                break;
              case 1:
                _activeModuleIndex = 0; // Lịch đặt
                break;
              case 2:
                _activeModuleIndex = 6; // Duyệt đơn
                break;
              case 3:
                _activeModuleIndex = 1; // Bán quầy & Kho
                break;
              case 4:
                _activeModuleIndex = -1; // Tài khoản
                break;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Lịch đặt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_sharp),
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
      ),
    );
  }

  Widget _buildBody() {
    if (_bottomNavIndex == 4) {
      return const OwnerAccountScreen();
    }
    if (_activeModuleIndex != -1) {
      return _buildModuleDetailView();
    }
    return _buildDashboardContent();
  }

  // ===========================================================================
  // GIAO DIỆN TRANG CHỦ
  // ===========================================================================
  Widget _buildDashboardContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER (Đã bỏ khu vực)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  const Text(
                    'Tổng quan hệ thống',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black54,
                      size: 26,
                    ),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 2. BANNER ALOBO SPORT CLUB (Đã chèn ảnh)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D5C40), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Khung hiển thị Logo/Ảnh Alobo Sport Club
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png', // Thay đường dẫn ảnh của bạn tại đây
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Icon hiển thị mặc định nếu chưa tìm thấy file ảnh
                            return const Icon(
                              Icons.sports_tennis,
                              color: primaryColor,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'ALOBO SPORT CLUB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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
              ),
            ),

            const SizedBox(height: 20),

            // 3. DANH SÁCH CHỨC NĂNG QUẢN LÝ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quản lý hệ thống',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: [
                          _buildOwnerCard(
                            title: 'Xem trạng thái sân',
                            subtitle: 'Sơ đồ & Ca trống',
                            icon: Icons.grid_view_rounded,
                            iconColor: const Color(0xFFD97706),
                            onTap: () => setState(() => _activeModuleIndex = 0),
                          ),
                          _buildOwnerCard(
                            title: 'Bán hàng tại quầy',
                            subtitle: 'Tạo đơn & Check-in',
                            icon: Icons.point_of_sale_rounded,
                            iconColor: const Color(0xFFE07A5F),
                            onTap: () => setState(() => _activeModuleIndex = 1),
                          ),
                          _buildOwnerCard(
                            title: 'Kho & dịch vụ',
                            subtitle: 'Nước uống, dụng cụ',
                            icon: Icons.inventory_2_rounded,
                            iconColor: const Color(0xFFE63946),
                            onTap: () => setState(() => _activeModuleIndex = 2),
                          ),
                          _buildOwnerCard(
                            title: 'Doanh thu & Báo cáo',
                            subtitle: 'Thống kê tài chính',
                            icon: Icons.bar_chart_rounded,
                            iconColor: const Color(0xFF8B1E3F),
                            onTap: () => setState(() => _activeModuleIndex = 3),
                          ),
                          _buildOwnerCard(
                            title: 'Quản lý chi nhánh',
                            subtitle: 'Cụm sân & Cơ sở',
                            icon: Icons.store_mall_directory_rounded,
                            iconColor: const Color(0xFF0F766E),
                            onTap: () => setState(() => _activeModuleIndex = 4),
                          ),
                          _buildOwnerCard(
                            title: 'Quản lý khách hàng',
                            subtitle: 'Hội viên & Tích điểm',
                            icon: Icons.groups_rounded,
                            iconColor: const Color(0xFF15803D),
                            onTap: () => setState(() => _activeModuleIndex = 5),
                          ),
                          _buildOwnerCard(
                            title: 'Quản lý đơn tháng',
                            subtitle: 'Lịch cố định',
                            icon: Icons.receipt_long_rounded,
                            iconColor: const Color(0xFF6D28D9),
                            onTap: () => setState(() => _activeModuleIndex = 6),
                          ),
                          _buildOwnerCard(
                            title: 'Cài đặt thanh toán',
                            subtitle: 'Mã QR & Ngân hàng',
                            icon: Icons.qr_code_scanner_rounded,
                            iconColor: const Color(0xFF2563EB),
                            onTap: () => setState(() => _activeModuleIndex = 7),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CHI TIẾT MODULE
  // ===========================================================================
  Widget _buildModuleDetailView() {
    Widget content;
    switch (_activeModuleIndex) {
      case 0:
        content = const _CourtAndPricingTab();
        break;
      case 1:
        content = const _BookingManagementTab();
        break;
      case 2:
        content = const _ServiceManagementTab();
        break;
      case 3:
        content = const _OverviewTab();
        break;
      case 7:
        content = const _PaymentSettingsTab();
        break;
      default:
        content = Center(
          child: Text(
            'Tính năng đang được phát triển',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => setState(() {
            _activeModuleIndex = -1;
            _bottomNavIndex = 0;
          }),
        ),
        title: const Text(
          'ALOBO SPORT CLUB',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: content),
    );
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doanh thu & Lợi nhuận',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'Đơn hôm nay',
              '12',
              Icons.receipt_long,
              Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Sân đang trống',
              '4/8',
              Icons.check_circle_outline,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSettingsTab extends StatelessWidget {
  const _PaymentSettingsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt thanh toán & QR',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_2,
                  size: 100,
                  color: Color(0xFF0D5C40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mã QR VietQR Thụ Hưởng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C40),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Cập nhật mã QR mới',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingManagementTab extends StatelessWidget {
  const _BookingManagementTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Bán hàng tại quầy & Đặt sân',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

class _CourtAndPricingTab extends StatelessWidget {
  const _CourtAndPricingTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Trạng thái Sân & Bảng giá',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

class _ServiceManagementTab extends StatelessWidget {
  const _ServiceManagementTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Kho & Dịch vụ đi kèm',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

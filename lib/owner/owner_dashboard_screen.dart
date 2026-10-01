import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:sportbooking/owner/owner_shop.dart';
import 'package:sportbooking/owner/owner_stock.dart';

// Import chính xác các màn hình bạn đã thiết kế
import 'owner_manager.dart';    // Màn hình ma trận Xem trạng thái sân & Ca trống (Ảnh 13)
import 'owner_branch.dart';     // Màn hình Quản lý Chi nhánh / Cụm sân (Ảnh 14)
import 'owner_revenue.dart';    // Màn hình Báo cáo Doanh thu
import 'owner_customers.dart';  // Màn hình Quản lý Khách hàng
import 'owner_account.dart';    // Màn hình Tài khoản
=======
import 'owner_account.dart'; // Import file màn hình tài khoản
>>>>>>> Stashed changes

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  static const Color primaryColor = Color(0xFF0D5C40);
  int _currentBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình hiện tại
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text('ALOBO SPORT CLUB'),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
<<<<<<< Updated upstream
      // Căn giữa toàn bộ nội dung để không bị kéo giãn tràn màn hình Web
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Giới hạn chiều rộng chuẩn Web/Desktop
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
=======
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
            // 1. TOP HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  const Text(
                    'Quản lí sân',
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

            // 2. BANNER ALOBO SPORT CLUB (SỬ DỤNG HÌNH ẢNH BANNER.JPG LÀM NỀN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // Lớp phủ tối nhẹ giúp chữ hiển thị rõ trên mọi hình ảnh
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_tennis,
                          color: primaryColor,
                          size: 28,
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
>>>>>>> Stashed changes
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. THẺ BANNER CHÀO MỪNG
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ALOBO SPORT CLUB!',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Hệ thống quản lý trung tâm thể thao ALOBO',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Quản lý hệ thống', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 2. LƯỚI CHỨC NĂNG (Responsive: 3 cột trên Web, 2 cột trên Mobile)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: screenWidth > 600 ? 3 : 2, // Tự điều chỉnh cột theo kích thước màn hình
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: screenWidth > 600 ? 1.4 : 1.15,
                  children: [
                    // NÚT 1: XEM TRẠNG THÁI SÂN (Màn hình Ma trận Ca trống - Ảnh 13)
                    _buildMenuCard(
                      title: 'Xem trạng thái sân',
                      subtitle: 'Sơ đồ & Ca trống',
                      icon: Icons.grid_view_rounded,
                      iconBgColor: Colors.orange.shade50,
                      iconColor: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerManagerScreen()),
                        );
                      },
                    ),

                    // NÚT 2: BÁN HÀNG TẠI QUẦY
                    _buildMenuCard(
                      title: 'Bán hàng tại quầy',
                      subtitle: 'Tạo đơn & Check-in',
                      icon: Icons.point_of_sale_rounded,
                      iconBgColor: Colors.red.shade50,
                      iconColor: Colors.redAccent,
                      onTap: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerShopScreen()),
                        );
                      },

                    ),

                    // NÚT 3: KHO & DỊCH VỤ
                    _buildMenuCard(
                      title: 'Kho & dịch vụ',
                      subtitle: 'Nước uống, dụng cụ',
                      icon: Icons.inventory_2_rounded,
                      iconBgColor: Colors.red.shade50,
                      iconColor: Colors.red,
                      onTap: () {},
                    ),

                    // NÚT 4: DOANH THU & BÁO CÁO (Màn hình Báo cáo Doanh thu)
                    _buildMenuCard(
                      title: 'Doanh thu & Báo cáo',
                      subtitle: 'Tài chính',
                      icon: Icons.bar_chart_rounded,
                      iconBgColor: Colors.purple.shade50,
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerRevenueScreen()),
                        );
                      },
                    ),

                    // NÚT 5: QUẢN LÝ CHI NHÁNH (Màn hình Cụm sân - Ảnh 14)
                    _buildMenuCard(
                      title: 'Quản lý chi nhánh',
                      subtitle: 'Cụm sân & Cơ sở',
                      icon: Icons.storefront_rounded,
                      iconBgColor: Colors.teal.shade50,
                      iconColor: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerBranchScreen()),
                        );
                      },
                    ),

                    // NÚT 6: QUẢN LÝ KHÁCH HÀNG
                    _buildMenuCard(
                      title: 'Quản lý khách hàng',
                      subtitle: 'Hội viên & Tích điểm',
                      icon: Icons.group_rounded,
                      iconBgColor: Colors.green.shade50,
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerCustomersScreen()),
                        );
                      },
                    ),
                    _buildMenuCard(
                  title: 'Kho & dịch vụ',
                    subtitle: 'Nước uống, dụng cụ',
                    icon: Icons.inventory_2_rounded,
                    iconBgColor: Colors.red.shade50,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OwnerStockScreen()),
    );
  },
),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OwnerAccountScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch đặt'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_outlined), label: 'Duyệt đơn'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Bán quầy & Kho'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }

  // WIDGET BẢN MẪU THẺ NÚT CHỨC NĂNG
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: primaryColor.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< Updated upstream
=======
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
>>>>>>> Stashed changes
}
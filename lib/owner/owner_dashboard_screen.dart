import 'package:flutter/material.dart';
import 'package:sportbooking/owner/owner_shop.dart';
import 'package:sportbooking/owner/owner_stock.dart';

// Import chính xác các màn hình bạn đã thiết kế
import 'owner_manager.dart';    // Màn hình ma trận Xem trạng thái sân & Ca trống (Ảnh 13)
import 'owner_branch.dart';     // Màn hình Quản lý Chi nhánh / Cụm sân (Ảnh 14)
import 'owner_revenue.dart';    // Màn hình Báo cáo Doanh thu
import 'owner_customers.dart';  // Màn hình Quản lý Khách hàng
import 'owner_account.dart';    // Màn hình Tài khoản

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
      // Căn giữa toàn bộ nội dung để không bị kéo giãn tràn màn hình Web
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // Giới hạn chiều rộng chuẩn Web/Desktop
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
}
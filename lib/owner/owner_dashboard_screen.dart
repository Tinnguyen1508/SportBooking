import 'package:flutter/material.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _bottomNavIndex = 0;
  int _activeModuleIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: _activeModuleIndex == -1 
          ? _buildDashboardGrid() 
          : _buildModuleDetailView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
            if (index == 0) {
              _activeModuleIndex = -1;
            } else if (index == 1) {
              _activeModuleIndex = 1;
            } else if (index == 2) {
              _activeModuleIndex = 6;
            }
          });
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
            icon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Duyệt đơn',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GIAO DIỆN TRANG CHỦ DẠNG LƯỚI (GRID DASHBOARD)
  // ===========================================================================
 Widget _buildDashboardGrid() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/banner.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.35),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/badminton.jpg',
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.sports_tennis, color: Color(0xFF0D5C40), size: 36),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'ALOBO BADMINTON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 2.2,
                  children: [
                    _buildMenuCard(
                      title: 'Xem trạng thái sân',
                      icon: Icons.grid_view_rounded,
                      color: const Color(0xFFD97706),
                      onTap: () => setState(() => _activeModuleIndex = 0),
                    ),
                    _buildMenuCard(
                      title: 'Bán hàng tại quầy',
                      icon: Icons.point_of_sale_rounded,
                      color: const Color(0xFFE07A5F),
                      onTap: () => setState(() => _activeModuleIndex = 1),
                    ),
                    _buildMenuCard(
                      title: 'Kho & dịch vụ',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFFE63946),
                      onTap: () => setState(() => _activeModuleIndex = 2),
                    ),
                    _buildMenuCard(
                      title: 'Doanh thu & Lợi nhuận',
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFF8B1E3F),
                      onTap: () => setState(() => _activeModuleIndex = 3),
                    ),
                    _buildMenuCard(
                      title: 'Quản lý chi nhánh',
                      icon: Icons.store_mall_directory_rounded,
                      color: const Color(0xFF0F766E),
                      onTap: () => setState(() => _activeModuleIndex = 4),
                    ),
                    _buildMenuCard(
                      title: 'Quản lý khách hàng',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF15803D),
                      onTap: () => setState(() => _activeModuleIndex = 5),
                    ),
                    _buildMenuCard(
                      title: 'Quản lý đơn tháng',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF6D28D9),
                      onTap: () => setState(() => _activeModuleIndex = 6),
                    ),
                    _buildMenuCard(
                      title: 'Cài đặt thanh toán ',
                      icon: Icons.qr_code_scanner_rounded,
                      color: const Color(0xFF2563EB),
                      onTap: () => setState(() => _activeModuleIndex = 7),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white.withValues(alpha: 0.95)), // Đã sửa withOpacity
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HIỂN THỊ NỘI DUNG CHI TIẾT KHI BẤM VÀO MỖI Ô MENU
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => setState(() => _activeModuleIndex = -1),
        ),
        title: const Text(
          'ALOBO BADMINTON',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: content,
      ),
    );
  }
}

// =============================================================================
// CÁC COMPONENT CON
// =============================================================================
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doanh thu & Lợi nhuận cơ sở', 
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatCard('Đơn hôm nay', '12', Icons.receipt_long, Colors.blue),
            const SizedBox(width: 16),
            _buildStatCard('Sân đang trống', '4/8', Icons.check_circle_outline, Colors.green),
            const SizedBox(width: 16),
            _buildStatCard('Doanh thu tạm tính', '2,350,000 VNĐ', Icons.monetization_on, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    value, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                ],
              )
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
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/qr_payment.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 160, height: 160, color: Colors.grey[200], child: const Icon(Icons.qr_code_2, size: 60)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mã QR VietQR Thụ Hưởng',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Mã QR này dùng để hiển thị cho khách chuyển khoản khi nhận sân trực tiếp hoặc thanh toán dịch vụ tại quầy.',
                        style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file, color: Colors.white),
                        label: const Text(
                          'Cập nhật Mã QR mới',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
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
  Widget build(BuildContext context) => const Center(child: Text('Lịch đặt & Check-in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)));
}

class _CourtAndPricingTab extends StatelessWidget {
  const _CourtAndPricingTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Trạng thái Sân & Bảng giá', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)));
}

class _ServiceManagementTab extends StatelessWidget {
  const _ServiceManagementTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Kho & Dịch vụ đi kèm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)));
}
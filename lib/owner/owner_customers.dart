import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// MODEL KHÁCH HÀNG (Mapping từ bảng USERS & BOOKINGS)
// -----------------------------------------------------------------------------
class Customer {
  final int id;
  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl;
  final String tier; // Kim Cương, Vàng, Bạc, Đồng, Mới
  final int totalBookings; // Đếm từ bảng bookings
  final double totalSpent; // Tổng sum(total_amount) từ bookings
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.tier,
    required this.totalBookings,
    required this.totalSpent,
    required this.createdAt,
  });
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------
class OwnerCustomersScreen extends StatefulWidget {
  const OwnerCustomersScreen({super.key});

  @override
  State<OwnerCustomersScreen> createState() => _OwnerCustomersScreenState();
}

class _OwnerCustomersScreenState extends State<OwnerCustomersScreen> {
  static const Color primaryColor = Color(0xFF0D5C40);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  String _searchQuery = '';
  String _selectedTier = 'Tất cả';

  // Dữ liệu mẫu mô phỏng truy vấn từ DATABASE (Users where role = 'CUSTOMER')
  final List<Customer> _allCustomers = [
    Customer(
      id: 1,
      fullName: 'Nguyễn Duc Tin',
      phone: '0901234567',
      email: 'nguyenductin@gmail.com',
      avatarUrl: null,
      tier: 'Kim Cương',
      totalBookings: 24,
      totalSpent: 4800000,
      createdAt: DateTime(2023, 5, 10),
    ),
    Customer(
      id: 2,
      fullName: 'Trần Huy Hoang',
      phone: '0987654321',
      email: 'hoangtran@gmail.com',
      avatarUrl: null,
      tier: 'Vàng',
      totalBookings: 12,
      totalSpent: 2200000,
      createdAt: DateTime(2023, 8, 15),
    ),
    Customer(
      id: 3,
      fullName: 'Do Nguyen Khang',
      phone: '0912345678',
      email: 'Khangnguyen@gmail.com',
      avatarUrl: null,
      tier: 'Bạc',
      totalBookings: 6,
      totalSpent: 1100000,
      createdAt: DateTime(2024, 1, 20),
    ),
    Customer(
      id: 4,
      fullName: 'Tran Nguyen Tan Tien',
      phone: '0933445566',
      email: 'TienTran@gmail.com',
      avatarUrl: null,
      tier: 'Mới',
      totalBookings: 1,
      totalSpent: 180000,
      createdAt: DateTime(2024, 3, 1),
    ),
  ];

  // Lọc danh sách khách hàng
  List<Customer> get _filteredCustomers {
    return _allCustomers.where((customer) {
      final matchesSearch = customer.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.phone.contains(_searchQuery) ||
          customer.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesTier = _selectedTier == 'Tất cả' || customer.tier == _selectedTier;

      return matchesSearch && matchesTier;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Quản lý khách hàng',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: primaryColor),
            onPressed: () {
              // Thêm khách hàng thủ công
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. THỐNG KÊ TỔNG QUAN
          _buildOverviewMetrics(),

          // 2. THANH TÌM KIẾM & BỘ LỌC HẠNG
          _buildSearchAndFilter(),

          // 3. DANH SÁCH KHÁCH HÀNG
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy khách hàng phù hợp',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return _buildCustomerCard(customer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget Thống kê tổng quan
  Widget _buildOverviewMetrics() {
    final totalCustomers = _allCustomers.length;
    final vipCustomers = _allCustomers.where((c) => c.tier == 'Kim Cương' || c.tier == 'Vàng').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              'Tổng khách hàng',
              '$totalCustomers',
              Icons.groups_rounded,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricItem(
              'Hội viên VIP',
              '$vipCustomers',
              Icons.stars_rounded,
              Colors.amber[800]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            radius: 18,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Tìm kiếm & Filter Chips
  Widget _buildSearchAndFilter() {
    final tiers = ['Tất cả', 'Kim Cương', 'Vàng', 'Bạc', 'Mới'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, SĐT hoặc email...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tiers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tier = tiers[index];
                final isSelected = _selectedTier == tier;
                return ChoiceChip(
                  label: Text(
                    tier,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: backgroundColor,
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTier = tier);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Thẻ hiển thị thông tin từng Khách hàng
  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showCustomerDetailBottomSheet(customer),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    customer.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),

                // Thông tin chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            customer.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          _buildTierBadge(customer.tier),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${customer.phone} • ${customer.email}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đã đặt: ${customer.totalBookings} lượt  |  Chi tiêu: ${_formatCurrency(customer.totalSpent)}',
                        style: const TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Badge hiển thị hạng thành viên
  Widget _buildTierBadge(String tier) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (tier) {
      case 'Kim Cương':
        badgeColor = Colors.purple;
        break;
      case 'Vàng':
        badgeColor = Colors.amber[800]!;
        break;
      case 'Bạc':
        badgeColor = Colors.grey[600]!;
        break;
      default:
        badgeColor = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor, width: 0.5),
      ),
      child: Text(
        tier,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
      ),
    );
  }

  // BottomSheet xem chi tiết khách hàng
  void _showCustomerDetailBottomSheet(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor,
                    child: Text(
                      customer.fullName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildTierBadge(customer.tier),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              _buildDetailRow(Icons.phone, 'Số điện thoại', customer.phone),
              _buildDetailRow(Icons.email, 'Email', customer.email),
              _buildDetailRow(Icons.calendar_today, 'Ngày tham gia', '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}'),
              _buildDetailRow(Icons.confirmation_number, 'Tổng lượt đặt sân', '${customer.totalBookings} lượt'),
              _buildDetailRow(Icons.payments, 'Tổng tiền đã thanh toán', _formatCurrency(customer.totalSpent)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone, color: primaryColor),
                      label: const Text('Gọi điện', style: TextStyle(color: primaryColor)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text('Lịch sử đặt', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }
}
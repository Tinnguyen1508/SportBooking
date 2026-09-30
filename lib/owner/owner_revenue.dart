import 'package:flutter/material.dart';

// ==========================================
// 1. DATA MODELS CHUẨN THEO DATABASE SQL
// ==========================================

/// Model Chi nhánh / Cụm sân (Bảng 'courts')
class BranchOption {
  final int id;
  final String name;

  BranchOption({required this.id, required this.name});
}

/// Model Tổng quan Doanh thu (Map từ 'payments' & 'bookings')
class RevenueSummaryModel {
  final double totalRevenue;      // Tổng doanh thu thực nhận
  final double courtRevenue;      // Doanh thu từ tiền thuê sân
  final double serviceRevenue;    // Doanh thu từ dịch vụ (nước, thuê vợt...)
  final int totalBookings;        // Tổng số đơn đặt sân
  final double vietqrAmount;      // Thanh toán qua VietQR
  final double cashAmount;        // Thanh toán Tiền mặt

  RevenueSummaryModel({
    required this.totalRevenue,
    required this.courtRevenue,
    required this.serviceRevenue,
    required this.totalBookings,
    required this.vietqrAmount,
    required this.cashAmount,
  });
}

/// Model Giao dịch / Đặt sân gần đây (Map bảng 'bookings' + 'payments' + 'users')
class TransactionModel {
  final int bookingId;
  final String customerName;
  final String courtBranchName;
  final String courtDetailName; // Ví dụ: Sân 01
  final double amount;
  final String paymentMethod;   // 'VIETQR', 'CASH'
  final String paymentStatus;   // 'PAID', 'PENDING'
  final String createdAt;

  TransactionModel({
    required this.bookingId,
    required this.customerName,
    required this.courtBranchName,
    required this.courtDetailName,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
  });
}

// ==========================================
// 2. GIAO DIỆN BÁO CÁO DOANH THU (OWNER)
// ==========================================

class OwnerRevenueScreen extends StatefulWidget {
  const OwnerRevenueScreen({super.key});

  @override
  State<OwnerRevenueScreen> createState() => _OwnerRevenueScreenState();
}

class _OwnerRevenueScreenState extends State<OwnerRevenueScreen> {
  static const Color primaryColor = Color(0xFF0D5C40);

  // Danh sách chi nhánh (Tương ứng các record trong bảng 'courts')
  final List<BranchOption> _branches = [
    BranchOption(id: 0, name: 'Tất cả chi nhánh'),
    BranchOption(id: 1, name: 'Alo Badminton - Quận 7'),
    BranchOption(id: 2, name: 'Alo Badminton - Tân Bình'),
    BranchOption(id: 3, name: 'Alo Badminton - Thủ Đức'),
  ];

  late int _selectedBranchId;
  String _selectedPeriod = 'Tháng này'; // 'Hôm nay', 'Tuần này', 'Tháng này', 'Năm nay'

  // Dữ liệu mẫu giả lập theo Database
  final List<TransactionModel> _allTransactions = [
    TransactionModel(
      bookingId: 1001,
      customerName: 'Nguyễn Văn A',
      courtBranchName: 'Alo Badminton - Quận 7',
      courtDetailName: 'Sân 01 (VIP)',
      amount: 240000,
      paymentMethod: 'VIETQR',
      paymentStatus: 'PAID',
      createdAt: '14:30 - 28/09/2026',
    ),
    TransactionModel(
      bookingId: 1002,
      customerName: 'Trần Thị B',
      courtBranchName: 'Alo Badminton - Tân Bình',
      courtDetailName: 'Sân 03',
      amount: 180000,
      paymentMethod: 'CASH',
      paymentStatus: 'PAID',
      createdAt: '16:00 - 28/09/2026',
    ),
    TransactionModel(
      bookingId: 1003,
      customerName: 'Lê Hoàng C',
      courtBranchName: 'Alo Badminton - Quận 7',
      courtDetailName: 'Sân 02',
      amount: 320000,
      paymentMethod: 'VIETQR',
      paymentStatus: 'PAID',
      createdAt: '18:00 - 27/09/2026',
    ),
    TransactionModel(
      bookingId: 1004,
      customerName: 'Phạm Minh D',
      courtBranchName: 'Alo Badminton - Thủ Đức',
      courtDetailName: 'Sân 01',
      amount: 150000,
      paymentMethod: 'VIETQR',
      paymentStatus: 'PAID',
      createdAt: '19:30 - 27/09/2026',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedBranchId = _branches.first.id;
  }

  // Tiện ích định dạng tiền tệ VNĐ
  String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    // Lọc giao dịch theo chi nhánh được chọn
    List<TransactionModel> filteredTransactions = _selectedBranchId == 0
        ? _allTransactions
        : _allTransactions.where((t) {
            final branchName = _branches.firstWhere((b) => b.id == _selectedBranchId).name;
            return t.courtBranchName == branchName;
          }).toList();

    // Tính toán số liệu tổng hợp
    double totalRev = filteredTransactions.fold(0, (sum, item) => sum + item.amount);
    double vietqrRev = filteredTransactions
        .where((t) => t.paymentMethod == 'VIETQR')
        .fold(0, (sum, item) => sum + item.amount);
    double cashRev = filteredTransactions
        .where((t) => t.paymentMethod == 'CASH')
        .fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text('Báo Cáo Doanh Thu'),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THANH BỘ LỌC CHI NHÁNH & THỜI GIAN
            _buildFilterHeader(),

            const SizedBox(height: 16),

            // 2. THẺ TỔNG DOANH THU CHÍNH
            _buildMainRevenueCard(totalRev),

            const SizedBox(height: 12),

            // 3. CÁC THẺ KPI PHÂN TÍCH CHI TIẾT
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Tiền thuê sân',
                    value: _formatCurrency(totalRev * 0.85),
                    icon: Icons.sports_tennis_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Tiền dịch vụ',
                    value: _formatCurrency(totalRev * 0.15),
                    icon: Icons.local_cafe_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. PHÂN TÍCH THEO PHƯƠNG THỨC THANH TOÁN (VIETQR VS TIỀN MẶT)
            _buildPaymentMethodBreakdown(totalRev, vietqrRev, cashRev),

            const SizedBox(height: 20),

            // 5. DANH SÁCH GIAO DỊCH GẦN ĐÂY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử giao dịch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredTransactions.length} đơn hàng',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...filteredTransactions.map((tx) => _buildTransactionCard(tx)),
          ],
        ),
      ),
    );
  }

  // Widget chọn Chi nhánh & Khoảng thời gian
  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Dropdown Chọn Chi Nhánh
          DropdownButtonFormField<int>(
            initialValue: _selectedBranchId,
            decoration: const InputDecoration(
              labelText: 'Chọn Chi Nhánh / Cụm Sân',
              prefixIcon: Icon(Icons.storefront_rounded, color: primaryColor),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: _branches
                .map((b) => DropdownMenuItem<int>(
                      value: b.id,
                      child: Text(b.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBranchId = val);
            },
          ),
          const SizedBox(height: 10),

          // Chips Chọn Thời Gian
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Hôm nay', 'Tuần này', 'Tháng này', 'Năm nay'].map((period) {
                bool isSelected = _selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedPeriod = period);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Card Doanh thu Tổng
  Widget _buildMainRevenueCard(double totalRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, Color(0xFF14805A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TỔNG DOANH THU ($_selectedPeriod)',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(totalRevenue),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 16),
              SizedBox(width: 4),
              Text('Đã xác nhận thanh toán thành công', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Thẻ KPI nhỏ
  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget Phân Bổ Phương Thức Thanh Toán
  Widget _buildPaymentMethodBreakdown(double total, double vietqr, double cash) {
    double vietqrPercent = total == 0 ? 0 : (vietqr / total);
    double cashPercent = total == 0 ? 0 : (cash / total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán (payments.payment_method)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          
          // Thanh biểu đồ tỉ lệ (Progress Bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(flex: (vietqrPercent * 100).toInt(), child: Container(color: primaryColor)),
                  Expanded(flex: (cashPercent * 100).toInt(), child: Container(color: Colors.amber)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('VietQR: ${_formatCurrency(vietqr)} (${(vietqrPercent * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Tiền mặt: ${_formatCurrency(cash)} (${(cashPercent * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Đơn Hàng Giao Dịch
  Widget _buildTransactionCard(TransactionModel tx) {
    bool isVietQr = tx.paymentMethod == 'VIETQR';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isVietQr ? primaryColor.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
            child: Icon(
              isVietQr ? Icons.qr_code_scanner_rounded : Icons.payments_rounded,
              color: isVietQr ? primaryColor : Colors.amber.shade800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.customerName} - ${tx.courtDetailName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.courtBranchName,
                  style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500),
                ),
                Text(
                  tx.createdAt,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${_formatCurrency(tx.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.paymentMethod,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
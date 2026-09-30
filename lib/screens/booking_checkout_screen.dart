import 'package:flutter/material.dart';
import 'payment_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final int courtId;
  final String courtName;
  final DateTime bookingDate;
  final List<Map<String, dynamic>> selectedSlots;

  const BookingCheckoutScreen({
    super.key,
    required this.courtId,
    required this.courtName,
    required this.bookingDate,
    required this.selectedSlots,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  static const Color primaryGreen = Color(0xFF00A86B);
  static const Color headerGreen = Color(0xFF006837);
  static const Color accentOrange = Color(0xFFFF6B00);

  late String bookingCode;

  // Dữ liệu giả lập Bảng [services] của cụm sân này
  final List<Map<String, dynamic>> availableServices = [
    {'id': 1, 'name': 'Thuê vợt cầu lông', 'price': 30000.0, 'unit': 'Cây', 'quantity': 0},
    {'id': 2, 'name': 'Nước điện giải Revive', 'price': 15000.0, 'unit': 'Chai', 'quantity': 0},
    {'id': 3, 'name': 'Ống cầu Ba Sao (12 quả)', 'price': 240000.0, 'unit': 'Ống', 'quantity': 0},
  ];

  final Map<String, dynamic> currentUser = {
    'id': 1,
    'full_name': 'Nguyễn Văn Định',
    'phone': '0908123456',
    'email': 'dinh.nguyen@example.com',
  };

  @override
  void initState() {
    super.initState();
    // Khởi tạo mã đơn hàng cố định 1 lần duy nhất khi mở màn hình
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    bookingCode = 'BK-$timestamp';
  }

  // Tính tổng tiền đặt sân từ [booking_details]
  double get slotsTotalAmount {
    return widget.selectedSlots.fold(0.0, (sum, item) => sum + (item['price'] as double));
  }

  // Tính tổng tiền dịch vụ bán kèm từ [booking_services]
  double get servicesTotalAmount {
    return availableServices.fold(
        0.0, (sum, item) => sum + ((item['price'] as double) * (item['quantity'] as int)));
  }

  // Tổng tiền đơn hàng tổng [bookings.total_amount]
  double get grandTotal => slotsTotalAmount + servicesTotalAmount;

  String formatMoney(double value) {
    return '${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  void _navigateToPayment() async {
    final generatedBookingId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Chuyển trực tiếp sang PaymentScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          bookingId: generatedBookingId,
          amount: grandTotal,
          bookingCode: bookingCode,
        ),
      ),
    );

    // Khi người dùng hoàn tất thanh toán từ PaymentScreen trở về
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${widget.bookingDate.day.toString().padLeft(2, '0')}/${widget.bookingDate.month.toString().padLeft(2, '0')}/${widget.bookingDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: headerGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác nhận đặt sân',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ Thông tin Cụm sân
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mã đơn hàng:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bookingCode,
                          style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(widget.courtName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Ngày chơi: $formattedDate', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Khung giờ đặt sân [booking_details]
            const Text('Chi tiết khung giờ chơi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.selectedSlots.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final slot = widget.selectedSlots[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.sports_tennis, color: primaryGreen, size: 20),
                    ),
                    title: Text(slot['court_detail_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Khung giờ: ${slot['start_time']} - ${slot['end_time']}'),
                    trailing: Text(
                      formatMoney(slot['price'] as double),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: accentOrange),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Dịch vụ bán kèm [services] & [booking_services]
            const Text('Dịch vụ bán kèm (Tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableServices.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final service = availableServices[index];
                  final int qty = service['quantity'];

                  return ListTile(
                    title: Text(service['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('${formatMoney(service['price'] as double)} / ${service['unit']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (qty > 0)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                            onPressed: () {
                              setState(() {
                                service['quantity'] = qty - 1;
                              });
                            },
                          ),
                        if (qty > 0)
                          Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: primaryGreen, size: 22),
                          onPressed: () {
                            setState(() {
                              service['quantity'] = qty + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // Thanh tổng tiền & Nút Chuyển sang Thanh Toán
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  formatMoney(grandTotal),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentOrange),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _navigateToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'TẠO ĐƠN ĐẶT SÂN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
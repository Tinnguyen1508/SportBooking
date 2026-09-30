import 'package:flutter/material.dart';
import 'booking_checkout_screen.dart'; // Import màn hình xác nhận đặt sân

class SlotPickerScreen extends StatefulWidget {
  final int courtId;
  final String courtName;

  const SlotPickerScreen({
    super.key,
    this.courtId = 1,
    this.courtName = 'Alobo Badminton Club - Sài Gòn',
  });

  @override
  State<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends State<SlotPickerScreen> {
  static const Color headerGreen = Color(0xFF006837);
  static const Color primaryGreen = Color(0xFF00A86B);
  static const Color bottomGold = Color(0xFFEAB308);

  DateTime selectedDate = DateTime.now();

  // Bảng [court_details]: Danh sách thảm sân con
  final List<Map<String, dynamic>> courtDetails = [
    {'id': 101, 'name': 'Sân Lông 1', 'is_active': true},
    {'id': 102, 'name': 'Sân Lông 2', 'is_active': true},
    {'id': 103, 'name': 'Sân Lông 3', 'is_active': true},
    {'id': 104, 'name': 'Sân Lông 4', 'is_active': true},
    {'id': 105, 'name': 'Sân Lông 5', 'is_active': true},
    {'id': 106, 'name': 'Sân Lông 6', 'is_active': true},
  ];

  // Bảng [slot_pricings]: Bảng giá động theo khung giờ
  final List<Map<String, dynamic>> slotPricings = [
    {'start_time': '05:00', 'end_time': '16:00', 'price_per_hour': 80000.0},
    {'start_time': '16:00', 'end_time': '23:00', 'price_per_hour': 120000.0},
  ];

  // Bảng [booking_details]: Các ô giờ đã được đặt trước
  final List<Map<String, String>> bookedSlots = [
    {'court_detail_id': '101', 'time': '17:30'},
    {'court_detail_id': '101', 'time': '18:00'},
    {'court_detail_id': '101', 'time': '20:00'},
    {'court_detail_id': '101', 'time': '20:30'},
    {'court_detail_id': '101', 'time': '21:00'},
    {'court_detail_id': '101', 'time': '21:30'},
    {'court_detail_id': '102', 'time': '18:00'},
    {'court_detail_id': '102', 'time': '18:30'},
    {'court_detail_id': '102', 'time': '19:00'},
    {'court_detail_id': '102', 'time': '20:00'},
    {'court_detail_id': '102', 'time': '20:30'},
    {'court_detail_id': '102', 'time': '21:00'},
    {'court_detail_id': '102', 'time': '21:30'},
    {'court_detail_id': '103', 'time': '08:00'},
    {'court_detail_id': '103', 'time': '08:30'},
    {'court_detail_id': '103', 'time': '09:00'},
    {'court_detail_id': '103', 'time': '09:30'},
    {'court_detail_id': '103', 'time': '10:00'},
    {'court_detail_id': '103', 'time': '10:30'},
    {'court_detail_id': '103', 'time': '11:00'},
    {'court_detail_id': '103', 'time': '11:30'},
    {'court_detail_id': '103', 'time': '18:00'},
    {'court_detail_id': '103', 'time': '18:30'},
    {'court_detail_id': '104', 'time': '07:00'},
    {'court_detail_id': '104', 'time': '07:30'},
    {'court_detail_id': '104', 'time': '08:00'},
    {'court_detail_id': '104', 'time': '08:30'},
    {'court_detail_id': '104', 'time': '17:30'},
    {'court_detail_id': '104', 'time': '18:00'},
    {'court_detail_id': '104', 'time': '18:30'},
    {'court_detail_id': '104', 'time': '19:00'},
    {'court_detail_id': '104', 'time': '19:30'},
    {'court_detail_id': '105', 'time': '19:00'},
    {'court_detail_id': '105', 'time': '19:30'},
    {'court_detail_id': '105', 'time': '20:00'},
    {'court_detail_id': '105', 'time': '20:30'},
    {'court_detail_id': '106', 'time': '19:00'},
    {'court_detail_id': '106', 'time': '19:30'},
    {'court_detail_id': '106', 'time': '20:00'},
    {'court_detail_id': '106', 'time': '20:30'},
  ];

  final List<String> timeSlots = [
    '05:00', '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
    '21:00', '21:30', '22:00', '22:30', '23:00', '23:30'
  ];

  final Set<String> selectedCellKeys = {};

  bool _isLockedSlot(String time) {
    final hour = int.parse(time.split(':')[0]);
    return hour < 5 || hour >= 23;
  }

  double _getSlotPrice(String time) {
    final hour = int.parse(time.split(':')[0]);
    if (hour < 16) {
      return 80000.0 / 2;
    }
    return 120000.0 / 2;
  }

  double get totalPrice {
    double total = 0.0;
    for (var key in selectedCellKeys) {
      final time = key.split('_')[1];
      total += _getSlotPrice(time);
    }
    return total;
  }

  double get totalHours => selectedCellKeys.length * 0.5;

  void _toggleCell(int courtDetailId, String time) {
    final key = '${courtDetailId}_$time';
    setState(() {
      if (selectedCellKeys.contains(key)) {
        selectedCellKeys.remove(key);
      } else {
        selectedCellKeys.add(key);
      }
    });
  }

  void _showPricingModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bảng giá sân theo giờ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              ListTile(
                title: const Text('Khung giờ ngày (05:00 - 16:00)'),
                trailing: const Text('80.000 đ / giờ', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Khung giờ tối (16:00 - 23:00)'),
                trailing: const Text('120.000 đ / giờ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        backgroundColor: headerGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đặt lịch ngày trực quan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                children: [
                  Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.calendar_month, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh chú thích
          Container(
            color: headerGreen,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildLegendItem(Colors.white, 'Trống'),
                const SizedBox(width: 12),
                _buildLegendItem(const Color(0xFFFB7185), 'Đã đặt'),
                const SizedBox(width: 12),
                _buildLegendItem(const Color(0xFF94A3B8), 'Khóa'),
                const Spacer(),
                GestureDetector(
                  onTap: _showPricingModal,
                  child: const Text(
                    'Xem sân & bảng giá',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
          ),

          // Thanh lưu ý
          Container(
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: const Text(
              'Lưu ý: Nếu bạn cần đặt lịch cố định vui lòng liên hệ: 0909.368.603 để được hỗ trợ',
              style: TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),

          // Ma trận Đặt lịch
          Expanded(
            child: Row(
              children: [
                // Cột Tên Sân Con
                Container(
                  width: 90,
                  color: const Color(0xFFE2E8F0),
                  child: Column(
                    children: [
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          border: Border.all(color: Colors.grey.shade400, width: 0.5),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: courtDetails.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                              ),
                              child: Text(
                                courtDetails[index]['name'],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Lưới Ô Giờ
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: timeSlots.length * 48.0,
                      child: Column(
                        children: [
                          // Hàng Header Mốc Giờ
                          SizedBox(
                            height: 32,
                            child: Row(
                              children: timeSlots.map((time) {
                                return Container(
                                  width: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                  ),
                                  child: Text(
                                    time,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Các Ô Giờ
                          Expanded(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: courtDetails.length,
                              itemBuilder: (context, rowIndex) {
                                final courtDetailId = courtDetails[rowIndex]['id'] as int;

                                return SizedBox(
                                  height: 44,
                                  child: Row(
                                    children: timeSlots.map((time) {
                                      final cellKey = '${courtDetailId}_$time';
                                      final isBooked = bookedSlots.any((b) => b['court_detail_id'] == courtDetailId.toString() && b['time'] == time);
                                      final isLocked = _isLockedSlot(time);
                                      final isSelected = selectedCellKeys.contains(cellKey);

                                      Color cellColor = Colors.white;
                                      if (isLocked) {
                                        cellColor = const Color(0xFF94A3B8);
                                      } else if (isBooked) {
                                        cellColor = const Color(0xFFFB7185);
                                      } else if (isSelected) {
                                        cellColor = const Color(0xFFBBF7D0);
                                      }

                                      return GestureDetector(
                                        onTap: (!isBooked && !isLocked)
                                            ? () => _toggleCell(courtDetailId, time)
                                            : null,
                                        child: Container(
                                          width: 48,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: cellColor,
                                            border: Border.all(
                                              color: isSelected ? primaryGreen : Colors.grey.shade300,
                                              width: isSelected ? 1.5 : 0.5,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(Icons.check, size: 16, color: primaryGreen)
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: headerGreen,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng giờ: ${totalHours.toStringAsFixed(1)}h00',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Tổng tiền: ${totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedCellKeys.isNotEmpty
                    ? () {
                        // Tổng hợp các slot được chọn chuẩn cấu trúc bảng [booking_details]
                        final List<Map<String, dynamic>> preparedSlots = selectedCellKeys.map((key) {
                          final parts = key.split('_');
                          final courtDetailId = int.parse(parts[0]);
                          final startTime = parts[1];

                          final hour = int.parse(startTime.split(':')[0]);
                          final minute = int.parse(startTime.split(':')[1]);
                          final endMinutes = minute + 30;
                          final endTime = endMinutes == 60
                              ? '${(hour + 1).toString().padLeft(2, '0')}:00'
                              : '${hour.toString().padLeft(2, '0')}:$endMinutes';

                          final courtDetailObj = courtDetails.firstWhere((c) => c['id'] == courtDetailId);

                          return {
                            'court_detail_id': courtDetailId,
                            'court_detail_name': courtDetailObj['name'],
                            'start_time': startTime,
                            'end_time': endTime,
                            'price': _getSlotPrice(startTime),
                          };
                        }).toList();

                        // Chuyển sang Màn hình Xác nhận Đặt sân
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingCheckoutScreen(
                              courtId: widget.courtId,
                              courtName: widget.courtName,
                              bookingDate: selectedDate,
                              selectedSlots: preparedSlots,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bottomGold,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: const Text(
                  'TIẾP THEO',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.black26, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
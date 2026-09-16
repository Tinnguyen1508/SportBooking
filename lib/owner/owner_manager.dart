import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Lớp cho phép kéo thả bằng chuột trên Flutter Web / Desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class OwnerManagerScreen extends StatefulWidget {
  const OwnerManagerScreen({super.key});

  @override
  State<OwnerManagerScreen> createState() => _OwnerManagerScreenState();
}

class _OwnerManagerScreenState extends State<OwnerManagerScreen> {
  // Danh sách các sân
  final List<String> courts = [
    'Sân Lông 1',
    'Sân Lông 2',
    'Sân Lông 3',
    'Sân Lông 4',
    'Sân Lông 5',
    'Sân Lông 6',
  ];

  // Khung giờ từ 06:00 đến 23:00 (Mỗi ô 30 phút)
  final List<String> timeSlots = [
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
  ];

  // Dữ liệu giả lập slot sân
  late Map<String, Map<String, dynamic>> mockBookings;

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  void _initMockData() {
    mockBookings = {
      // Sân 1: 06:00 - 06:30 & 17:00 - 18:00
      '0_0': _createMockBooking(
        'BK-99101',
        '06:00',
        '06:30',
        'PAID',
        name: 'Lê Văn C',
        phone: '0901112233',
      ),
      '0_22': _createMockBooking(
        'BK-99212',
        '17:00',
        '17:30',
        'PAID',
        name: 'Nguyễn Văn A',
        phone: '0912345678',
      ),
      '0_23': _createMockBooking(
        'BK-99212',
        '17:30',
        '18:00',
        'PAID',
        name: 'Nguyễn Văn A',
        phone: '0912345678',
      ),

      // Sân 2: 17:30 - 19:00
      '1_23': _createMockBooking(
        'BK-99215',
        '17:30',
        '18:00',
        'CHECKED_IN',
        name: 'Trần Thị B',
        phone: '0987654321',
      ),
      '1_24': _createMockBooking(
        'BK-99215',
        '18:00',
        '18:30',
        'CHECKED_IN',
        name: 'Trần Thị B',
        phone: '0987654321',
      ),

      // Sân 3: 08:00 - 09:00 & 21:00 - 22:00
      '2_4': _createMockBooking(
        'BK-99100',
        '08:00',
        '08:30',
        'PAID',
        name: 'Lê Văn C',
        phone: '0901112233',
      ),
      '2_5': _createMockBooking(
        'BK-99100',
        '08:30',
        '09:00',
        'PAID',
        name: 'Lê Văn C',
        phone: '0901112233',
      ),
      '2_30': _createMockBooking(
        'BK-99401',
        '21:00',
        '21:30',
        'PAID',
        name: 'Phạm Hoàng D',
        phone: '0933445566',
      ),
    };
  }

  Map<String, dynamic> _createMockBooking(
    String code,
    String start,
    String end,
    String status, {
    required String name,
    required String phone,
  }) {
    return {
      'booking_code': code,
      'status': status,
      'total_amount': 160000.00,
      'price_slot': 80000.00,
      'booking_date': '2026-09-16',
      'start_time': start,
      'end_time': end,
      'created_at': '2026-09-16 14:30:00',
      'customer_name': name,
      'customer_phone': phone,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER BAR
            Container(
              color: const Color(0xFF0D5C40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildLegendItem(Colors.white, 'Trống'),
                  const SizedBox(width: 12),
                  _buildLegendItem(const Color(0xFFF87171), 'Đã đặt'),
                  const SizedBox(width: 12),
                  _buildLegendItem(Colors.grey[400]!, 'Khóa'),
                  const Spacer(),
                  const Text(
                    'Xem sân & bảng giá',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // 2. CHÚ Ý
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Text(
                'Lưu ý: Nếu bạn cần đặt lịch cố định vui lòng liên hệ: 0909.368.603 để được hỗ trợ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),

            // 3. BẢNG MÃ TRẬN HỖ TRỢ KÉO CHUỘT
            Expanded(
              child: ScrollConfiguration(
                behavior: AppScrollBehavior(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double headerRowHeight = 40.0;
                    double calculatedRowHeight =
                        (constraints.maxHeight - headerRowHeight) /
                        courts.length;
                    double cellHeight = calculatedRowHeight > 55
                        ? calculatedRowHeight
                        : 55;

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dòng thời gian
                            Row(
                              children: [
                                Container(
                                  width: 110,
                                  height: headerRowHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                ...timeSlots.map(
                                  (time) => Container(
                                    width: 75,
                                    height: headerRowHeight,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Các hàng sân
                            ...List.generate(courts.length, (courtIndex) {
                              return Row(
                                children: [
                                  Container(
                                    width: 110,
                                    height: cellHeight,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(
                                      courts[courtIndex],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(timeSlots.length, (
                                    timeIndex,
                                  ) {
                                    String key = '${courtIndex}_$timeIndex';
                                    bool isBooked = mockBookings.containsKey(
                                      key,
                                    );
                                    Map<String, dynamic>? bookingData =
                                        mockBookings[key];

                                    return InkWell(
                                      onTap: () => _showSlotDetails(
                                        context,
                                        courtIndex,
                                        timeIndex,
                                        courts[courtIndex],
                                        timeSlots[timeIndex],
                                        bookingData,
                                      ),
                                      child: Container(
                                        width: 75,
                                        height: cellHeight,
                                        padding: const EdgeInsets.all(2.0),
                                        decoration: BoxDecoration(
                                          color: isBooked
                                              ? const Color(0xFFF87171)
                                              : Colors.white,
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: isBooked
                                            ? Center(
                                                child: Text(
                                                  bookingData?['customer_name'] ??
                                                      'Đã đặt',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
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
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  void _showSlotDetails(
    BuildContext context,
    int courtIndex,
    int timeIndex,
    String courtName,
    String timeSlot,
    Map<String, dynamic>? booking,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isBooked = booking != null;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Row(
            children: [
              Icon(
                isBooked ? Icons.bookmark : Icons.check_circle,
                color: isBooked ? const Color(0xFFF87171) : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$courtName ($timeSlot)',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              if (isBooked) ...[
                _buildInfoRow('Mã đơn:', booking['booking_code']),
                _buildInfoRow('Khách hàng:', booking['customer_name']),
                _buildInfoRow('Số điện thoại:', booking['customer_phone']),
                _buildInfoRow(
                  'Khung giờ:',
                  '${booking['start_time']} - ${booking['end_time']}',
                ),
                _buildInfoRow('Trạng thái:', booking['status'], isTag: true),
                _buildInfoRow(
                  'Giá slot:',
                  '${booking['price_slot'].toStringAsFixed(0)} VNĐ',
                ),
                _buildInfoRow(
                  'Tổng tiền:',
                  '${booking['total_amount'].toStringAsFixed(0)} VNĐ',
                ),
              ] else ...[
                const Text(
                  'Trạng thái: Ô trống',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Khung giờ này chưa có ai đặt. Bạn có thể tự giữ chỗ cho chủ sân hoặc tạo đơn đặt tại quầy.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
            ),
            if (isBooked) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Chuyển sân'),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _showMoveSlotDialog(
                        context,
                        courtIndex,
                        timeIndex,
                        booking,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hủy sân'),
                    onPressed: () {
                      String key = '${courtIndex}_$timeIndex';
                      setState(() {
                        mockBookings.remove(key);
                      });

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã hủy lịch đặt tại $courtName ($timeSlot) thành công!',
                          ),
                          backgroundColor: Colors.red[600],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C40),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add_task, size: 18),
                label: const Text('Chủ sân tự đặt sân'),
                onPressed: () {
                  String key = '${courtIndex}_$timeIndex';
                  String nextTime = (timeIndex + 1 < timeSlots.length)
                      ? timeSlots[timeIndex + 1]
                      : timeSlot;

                  setState(() {
                    mockBookings[key] = _createMockBooking(
                      'OWNER-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      timeSlot,
                      nextTime,
                      'PAID',
                      name: 'Chủ sân (Giữ chỗ)',
                      phone: '0909368603',
                    );
                  });

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã giữ chỗ $courtName khung giờ $timeSlot!',
                      ),
                      backgroundColor: Colors.green[700],
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  void _showMoveSlotDialog(
    BuildContext context,
    int currentCourtIndex,
    int currentTimeIndex,
    Map<String, dynamic> bookingData,
  ) {
    int targetCourtIndex = currentCourtIndex;
    int targetTimeIndex = currentTimeIndex;

    showDialog(
      context: context,
      builder: (moveContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Chuyển / Đổi ca đánh',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn vị trí sân và khung giờ mới cần chuyển đến:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: targetCourtIndex,
                    decoration: const InputDecoration(
                      labelText: 'Chọn sân mới',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: List.generate(
                      courts.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(courts[index]),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => targetCourtIndex = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: targetTimeIndex,
                    decoration: const InputDecoration(
                      labelText: 'Chọn khung giờ mới',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: List.generate(
                      timeSlots.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(timeSlots[index]),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null)
                        setDialogState(() => targetTimeIndex = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(moveContext),
                  child: const Text(
                    'Hủy bỏ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    String oldKey = '${currentCourtIndex}_$currentTimeIndex';
                    String newKey = '${targetCourtIndex}_$targetTimeIndex';

                    if (oldKey == newKey) {
                      Navigator.pop(moveContext);
                      return;
                    }

                    String newStart = timeSlots[targetTimeIndex];
                    String newEnd = (targetTimeIndex + 1 < timeSlots.length)
                        ? timeSlots[targetTimeIndex + 1]
                        : newStart;

                    setState(() {
                      var updatedCurrentBooking = Map<String, dynamic>.from(
                        bookingData,
                      );
                      updatedCurrentBooking['start_time'] = newStart;
                      updatedCurrentBooking['end_time'] = newEnd;

                      if (mockBookings.containsKey(newKey)) {
                        var targetBooking = Map<String, dynamic>.from(
                          mockBookings[newKey]!,
                        );
                        targetBooking['start_time'] =
                            timeSlots[currentTimeIndex];
                        targetBooking['end_time'] =
                            (currentTimeIndex + 1 < timeSlots.length)
                            ? timeSlots[currentTimeIndex + 1]
                            : timeSlots[currentTimeIndex];

                        mockBookings[oldKey] = targetBooking;
                        mockBookings[newKey] = updatedCurrentBooking;
                      } else {
                        mockBookings.remove(oldKey);
                        mockBookings[newKey] = updatedCurrentBooking;
                      }
                    });

                    Navigator.pop(moveContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã chuyển lịch của ${bookingData['customer_name']} sang ${courts[targetCourtIndex]} ($newStart) thành công!',
                        ),
                        backgroundColor: Colors.blue[700],
                      ),
                    );
                  },
                  child: const Text('Xác nhận chuyển'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTag = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          if (isTag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(value).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(value),
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'CHECKED_IN':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

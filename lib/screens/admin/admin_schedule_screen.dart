import 'package:flutter/material.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);

  DateTime selectedDate = DateTime.now();

  final List<String> timeSlots = [
    '05:00', '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00'
  ];

  final List<String> courts = ['C.Lông 1', 'C.Lông 2', 'C.Lông 3', 'C.Lông 4'];

  // Giả lập trạng thái sân: 'empty', 'booked' (xanh dương), 'active' (xanh lá), 'maintenance' (đỏ)
  String getCourtStatus(String court, String time) {
    if (court == 'C.Lông 1' && (time == '05:00' || time == '05:30')) {
      return 'booked'; // Sân đã đặt lịch
    }
    if (court == 'C.Lông 2' && (time == '06:00' || time == '06:30')) {
      return 'active'; // Đang hoạt động
    }
    if (court == 'C.Lông 3' && (time == '07:00' || time == '07:30')) {
      return 'maintenance'; // Sân bảo trì
    }
    return 'empty'; // Sân trống
  }

  String _formatWeekday(int weekday) {
    return '${weekday + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    String weekdayStr = selectedDate.weekday == 7 
        ? 'Chủ Nhật' 
        : 'Thứ ${_formatWeekday(selectedDate.weekday)}';
    String dayString = '$weekdayStr ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Trạng thái sân',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: isDesktop ? 900 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // 1. Chú thích màu sắc trạng thái sân
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(Colors.white, 'Sân trống', textColor, hasBorder: true),
                        _buildLegendItem(Colors.blue.shade500, 'Đã đặt', textColor),
                        _buildLegendItem(Colors.green.shade500, 'Hoạt động', textColor),
                        _buildLegendItem(Colors.red.shade500, 'Bảo trì', textColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Thanh chọn ngày
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: primaryColor, size: 28),
                          onPressed: () => setState(() => selectedDate = selectedDate.subtract(const Duration(days: 1))),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: primaryColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              dayString,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: primaryColor, size: 28),
                          onPressed: () => setState(() => selectedDate = selectedDate.add(const Duration(days: 1))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Bảng lịch biểu chi tiết cuộn 2 chiều
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(primaryColor.withOpacity(0.2)),
                              columnSpacing: 12,
                              dataRowMinHeight: 45,
                              dataRowMaxHeight: 55,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    '$weekdayStr\n${selectedDate.day}/${selectedDate.month}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                                  ),
                                ),
                                ...timeSlots.map((time) => DataColumn(
                                      label: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                                    )),
                              ],
                              rows: courts.map((court) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          court,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor),
                                        ),
                                      ),
                                    ),
                                    ...timeSlots.map((time) {
                                      final status = getCourtStatus(court, time);

                                      Color bgColor = Colors.white;
                                      Color borderColor = Colors.grey.shade300;

                                      if (status == 'booked') {
                                        bgColor = Colors.blue.shade500;
                                        borderColor = Colors.blue.shade700;
                                      } else if (status == 'active') {
                                        bgColor = Colors.green.shade500;
                                        borderColor = Colors.green.shade700;
                                      } else if (status == 'maintenance') {
                                        bgColor = Colors.red.shade500;
                                        borderColor = Colors.red.shade700;
                                      }

                                      return DataCell(
                                        Container(
                                          width: 65,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: borderColor, width: 1),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color bg, String label, Color textColor, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: Colors.grey, width: 1) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}
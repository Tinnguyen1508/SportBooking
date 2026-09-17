import 'package:flutter/material.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);

  String selectedPeriod = 'Tháng này';

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth > 900 ? 4 : 2;
    double childAspectRatio = screenWidth > 900 ? 2.2 : 2.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Thống kê báo cáo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  // Dùng constraints.maxHeight để đảm bảo nền luôn phủ kín màn hình mà không gây lỗi layout
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 1. Thanh chọn khoảng thời gian
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['Tuần này', 'Tháng này', 'Năm nay'].map((period) {
                          bool isSelected = selectedPeriod == period;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(period),
                              selected: isSelected,
                              selectedColor: primaryColor,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold, fontSize: 13),
                              backgroundColor: Colors.white.withOpacity(0.9),
                              onSelected: (val) => setState(() => selectedPeriod = period),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 2. Card tổng doanh thu
                      Center(
                        child: Container(
                          width: screenWidth > 900 ? 600 : double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Column(
                            children: [
                              const Text('Tổng doanh thu', style: TextStyle(color: greyText, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(formatMoney(35400000), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.trending_up, color: Colors.green, size: 16),
                                  SizedBox(width: 4),
                                  Text('+18.5% so với kỳ trước', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Lưới các ô thống kê
                      GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildStatCard('Tổng số lượt đặt', '142 đơn', Icons.event_note, Colors.blue),
                          _buildStatCard('Khách hàng mới', '28 người', Icons.person_add, Colors.orange),
                          _buildStatCard('Giờ sân hoạt động', '210 giờ', Icons.access_time, Colors.purple),
                          _buildStatCard('Tỷ lệ lấp đầy', '78%', Icons.pie_chart, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: greyText, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
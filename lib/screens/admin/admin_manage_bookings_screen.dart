import 'package:flutter/material.dart';

class AdminManageBookingsScreen extends StatefulWidget {
  const AdminManageBookingsScreen({super.key});

  @override
  State<AdminManageBookingsScreen> createState() => _AdminManageBookingsScreenState();
}

class _AdminManageBookingsScreenState extends State<AdminManageBookingsScreen> {
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);

  List<Map<String, dynamic>> bookings = [
    {'id': 'BK001', 'customer': 'Nguyễn Văn A', 'court': 'Pickleball 1', 'time': '18:00 - 19:30', 'date': '17/09/2026', 'status': 'Đã xác nhận', 'price': 250000},
    {'id': 'BK002', 'customer': 'Trần Thị B', 'court': 'Pickleball 2', 'time': '07:00 - 08:30', 'date': '17/09/2026', 'status': 'Đang chờ', 'price': 200000},
    {'id': 'BK003', 'customer': 'Lê Văn C', 'court': 'Pickleball 3', 'time': '16:00 - 17:30', 'date': '18/09/2026', 'status': 'Đã huỷ', 'price': 250000},
  ];

  String searchQuery = '';

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}đ';
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      bookings[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật trạng thái đơn ${bookings[index]['id']}')));
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa đơn đặt sân ${bookings[index]['id']}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: greyText))),
            ElevatedButton(
              onPressed: () {
                setState(() => bookings.removeAt(index));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    final filteredBookings = bookings.where((b) {
      return b['customer'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             b['court'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             b['id'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Quản lý lịch đặt sân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // Giới hạn chiều rộng trên màn hình Windows lớn để không bị bè ngang
            child: Container(
              width: isDesktop ? 900 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, mã đơn, sân...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredBookings.isEmpty
                        ? const Center(child: Text('Không tìm thấy lịch đặt nào.', style: TextStyle(color: Colors.white70, fontSize: 16)))
                        : ListView.builder(
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final item = filteredBookings[index];
                              Color statusColor = item['status'] == 'Đã xác nhận' 
                                  ? Colors.green 
                                  : (item['status'] == 'Đang chờ' ? Colors.orange : Colors.red);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15)),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                              child: Text(item['status'], style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert, size: 20, color: greyText),
                                              onSelected: (val) {
                                                if (val == 'delete') {
                                                  _confirmDelete(bookings.indexOf(item));
                                                } else {
                                                  _updateStatus(bookings.indexOf(item), val);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(value: 'Đã xác nhận', child: Text('Xác nhận đơn')),
                                                const PopupMenuItem(value: 'Đang chờ', child: Text('Chuyển chờ xử lý')),
                                                const PopupMenuItem(value: 'Đã huỷ', child: Text('Hủy đơn')),
                                                const PopupMenuItem(value: 'delete', child: Text('Xóa đơn', style: TextStyle(color: Colors.red))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16, color: greyText),
                                        const SizedBox(width: 8),
                                        Text('Khách hàng: ${item['customer']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.sports_tennis, size: 16, color: greyText),
                                        const SizedBox(width: 8),
                                        Text('Sân: ${item['court']} | Giờ: ${item['time']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 16, color: greyText),
                                            const SizedBox(width: 8),
                                            Text('Ngày: ${item['date']}'),
                                          ],
                                        ),
                                        Text(formatMoney(item['price']), style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15)),
                                      ],
                                    ),
                                  ],
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
      ),
    );
  }
}
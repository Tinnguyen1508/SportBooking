import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'slot_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF00A86B);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  int selectedNavIndex = 0;
  String searchQuery = '';

  int? selectedDistrictId;
  String selectedProvinceFilter = 'Tất cả';

  List<int> selectedSportIds = [0];
  List<int> selectedAmenityIds = [];
  List<int> favoriteCourtIds = [];
  String activeFilterTab = 'ALL';

  File? _localAvatarFile;

  // 1. Thông tin người dùng
  final Map<String, dynamic> currentUser = {
    'id': 1,
    'phone': '0854320123',
    'full_name': 'Đỗ Nguyên Khang',
    'role': 'CUSTOMER',
    'email': 'nguyenkhang1511006@gmail.com',
    'avatar_url': 'https://i.pravatar.cc/300?img=12',
    'created_at': '2026-01-15 10:30:00',
    'google_id': 'google-oauth2|109238491283',
  };

  final List<String> quickAvatars = [
    'https://i.pravatar.cc/300?img=12',
    'https://i.pravatar.cc/300?img=33',
    'https://i.pravatar.cc/300?img=47',
    'https://i.pravatar.cc/300?img=68',
    'https://i.pravatar.cc/300?img=5',
  ];

  // 2. Danh sách môn thể thao
  final List<Map<String, dynamic>> sports = [
    {'id': 0, 'name': 'Tất cả', 'icon': Icons.sports_kabaddi, 'is_active': true},
    {'id': 1, 'name': 'Cầu lông', 'icon': Icons.sports_tennis, 'is_active': true},
    {'id': 2, 'name': 'Pickleball', 'icon': Icons.sports_handball, 'is_active': true},
    {'id': 3, 'name': 'Bóng đá', 'icon': Icons.sports_soccer, 'is_active': true},
    {'id': 4, 'name': 'Tennis', 'icon': Icons.sports_tennis_outlined, 'is_active': true},
  ];

  // 3. Danh sách quận/huyện
  final List<Map<String, dynamic>> districts = [
    {'id': 1, 'name': 'Quận 1', 'province_name': 'TP. Hồ Chí Minh'},
    {'id': 2, 'name': 'Bình Thạnh', 'province_name': 'TP. Hồ Chí Minh'},
    {'id': 3, 'name': 'Quận 7', 'province_name': 'TP. Hồ Chí Minh'},
    {'id': 4, 'name': 'Cầu Giấy', 'province_name': 'Hà Nội'},
    {'id': 5, 'name': 'Hoàn Kiếm', 'province_name': 'Hà Nội'},
  ];

  // 4. Danh sách sân
  final List<Map<String, dynamic>> courts = [
    {
      'id': 1,
      'owner_id': 2,
      'sport_id': 1,
      'district_id': 1,
      'name': 'Alobo Badminton Club - Sài Gòn',
      'address': '123 Nguyễn Thị Minh Khai, Q.1, TP.HCM',
      'open_time': '05:00:00',
      'close_time': '23:00:00',
      'status': 'ACTIVE',
      'bank_name': 'MBBank',
      'bank_account': '999988887777',
      'bank_account_holder': 'CTY ALOBO SPORTS',
    },
    {
      'id': 2,
      'owner_id': 3,
      'sport_id': 1,
      'district_id': 2,
      'name': 'Sân Cầu Lông Bình Thạnh Arena',
      'address': '456 Điện Biên Phủ, P.25, Bình Thạnh, TP.HCM',
      'open_time': '06:00:00',
      'close_time': '22:00:00',
      'status': 'ACTIVE',
      'bank_name': 'Vietcombank',
      'bank_account': '0123456789',
      'bank_account_holder': 'NGUYEN VAN A',
    },
    {
      'id': 3,
      'owner_id': 4,
      'sport_id': 2,
      'district_id': 3,
      'name': 'Pickleball Alobo Center Q7',
      'address': '789 Nguyễn Văn Linh, Q.7, TP.HCM',
      'open_time': '06:00:00',
      'close_time': '22:30:00',
      'status': 'ACTIVE',
      'bank_name': 'Techcombank',
      'bank_account': '1122334455',
      'bank_account_holder': 'TRAN THI B',
    },
    {
      'id': 4,
      'owner_id': 5,
      'sport_id': 1,
      'district_id': 4,
      'name': 'CLB Cầu Lông Cầu Giấy Hà Nội',
      'address': '101 Xuân Thủy, Cầu Giấy, Hà Nội',
      'open_time': '05:30:00',
      'close_time': '22:30:00',
      'status': 'ACTIVE',
      'bank_name': 'BIDV',
      'bank_account': '6666777788',
      'bank_account_holder': 'LE VAN C',
    },
  ];

  // 5. Ảnh bìa
  final List<Map<String, dynamic>> courtImages = [
    {'id': 1, 'court_id': 1, 'image_url': 'https://picsum.photos/400/220?random=1', 'is_cover': true},
    {'id': 2, 'court_id': 2, 'image_url': 'https://picsum.photos/400/220?random=2', 'is_cover': true},
    {'id': 3, 'court_id': 3, 'image_url': 'https://picsum.photos/400/220?random=3', 'is_cover': true},
    {'id': 4, 'court_id': 4, 'image_url': 'https://picsum.photos/400/220?random=4', 'is_cover': true},
  ];

  // 6. Tiện ích
  final List<Map<String, dynamic>> amenities = [
    {'id': 1, 'name': 'Wifi', 'icon_code': 'wifi'},
    {'id': 2, 'name': 'Đỗ ô tô', 'icon_code': 'directions_car'},
    {'id': 3, 'name': 'Căng tin', 'icon_code': 'local_cafe'},
    {'id': 4, 'name': 'Phòng tắm', 'icon_code': 'shower'},
  ];

  final List<Map<String, dynamic>> courtAmenities = [
    {'court_id': 1, 'amenity_id': 1},
    {'court_id': 1, 'amenity_id': 2},
    {'court_id': 1, 'amenity_id': 3},
    {'court_id': 1, 'amenity_id': 4},
    {'court_id': 2, 'amenity_id': 1},
    {'court_id': 2, 'amenity_id': 3},
    {'court_id': 3, 'amenity_id': 1},
    {'court_id': 3, 'amenity_id': 2},
    {'court_id': 4, 'amenity_id': 1},
  ];

  // 7. Bảng giá
  final List<Map<String, dynamic>> slotPricings = [
    {'id': 1, 'court_id': 1, 'start_time': '05:00', 'end_time': '16:00', 'price_per_hour': 100000.0, 'day_type': 'WEEKDAY'},
    {'id': 2, 'court_id': 1, 'start_time': '16:00', 'end_time': '23:00', 'price_per_hour': 150000.0, 'day_type': 'WEEKDAY'},
    {'id': 3, 'court_id': 2, 'start_time': '06:00', 'end_time': '22:00', 'price_per_hour': 80000.0, 'day_type': 'WEEKDAY'},
    {'id': 4, 'court_id': 3, 'start_time': '06:00', 'end_time': '22:30', 'price_per_hour': 120000.0, 'day_type': 'WEEKDAY'},
    {'id': 5, 'court_id': 4, 'start_time': '05:30', 'end_time': '22:30', 'price_per_hour': 90000.0, 'day_type': 'WEEKDAY'},
  ];

  // 8. Đơn đặt sân (bổ sung trường cancel_reason)
  final List<Map<String, dynamic>> myBookings = [
    {
      'id': 101,
      'court_name': 'Alobo Badminton Club - Sài Gòn',
      'court_detail_name': 'Sân Lông 1',
      'booking_date': '2026-09-20',
      'time_slot': '18:00 - 19:30',
      'total_price': 180000.0,
      'status': 'CONFIRMED',
      'cancel_reason': null,
    },
    {
      'id': 102,
      'court_name': 'Sân Cầu Lông Bình Thạnh Arena',
      'court_detail_name': 'Sân Lông 3',
      'booking_date': '2026-09-22',
      'time_slot': '19:00 - 20:30',
      'total_price': 120000.0,
      'status': 'CONFIRMED',
      'cancel_reason': null,
    },
  ];

  // ----------------------------------------------------
  // HÀM HỦY SÂN CÓ CỬA SỔ NHẬP LÝ DO
  // ----------------------------------------------------
  void _cancelBooking(int bookingId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận hủy sân', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn có chắc chắn muốn hủy đơn đặt sân này không? Thao tác này không thể hoàn tác.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lý do hủy sân:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do (ví dụ: Bận đột xuất, thời tiết xấu...)',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final reasonText = reasonController.text.trim();
                Navigator.pop(dialogContext);
                setState(() {
                  final index = myBookings.indexWhere((b) => b['id'] == bookingId);
                  if (index != -1) {
                    myBookings[index]['status'] = 'CANCELLED';
                    myBookings[index]['cancel_reason'] = reasonText.isNotEmpty ? reasonText : 'Không có lý do cụ thể';
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã hủy đơn đặt sân thành công!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Hủy sân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _getCoverImage(int courtId) {
    final img = courtImages.firstWhere(
      (i) => i['court_id'] == courtId && i['is_cover'] == true,
      orElse: () => {'image_url': 'https://picsum.photos/400/220?random=$courtId'},
    );
    return img['image_url'];
  }

  double _getMinPrice(int courtId) {
    final prices = slotPricings.where((p) => p['court_id'] == courtId).map((p) => p['price_per_hour'] as double).toList();
    if (prices.isEmpty) return 0.0;
    prices.sort();
    return prices.first;
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _localAvatarFile = File(image.path);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera ? 'Đã chụp và cập nhật ảnh đại diện!' : 'Đã cập nhật ảnh đại diện từ thiết bị!',
            ),
          ),
        );
      }
    }
  }

  void _toggleFavoriteCourt(int courtId) {
    setState(() {
      if (favoriteCourtIds.contains(courtId)) {
        favoriteCourtIds.remove(courtId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã bỏ sân khỏi danh sách yêu thích'), duration: Duration(seconds: 1)),
        );
      } else {
        favoriteCourtIds.add(courtId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm sân vào danh sách yêu thích ♥'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  ImageProvider _getAvatarImageProvider() {
    if (_localAvatarFile != null) {
      return FileImage(_localAvatarFile!);
    }
    return NetworkImage(currentUser['avatar_url']);
  }

  void _showChangeAvatarModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cập nhật Ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined, color: primaryColor),
                ),
                title: const Text('Chụp ảnh mới', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Sử dụng camera thiết bị'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_outlined, color: primaryColor),
                ),
                title: const Text('Chọn ảnh từ thư viện', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Truy cập bộ sưu tập hình ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 24),
              const Text('Hoặc chọn Avatar mẫu:', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: quickAvatars.length,
                  itemBuilder: (context, index) {
                    final url = quickAvatars[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _localAvatarFile = null;
                          currentUser['avatar_url'] = url;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(url)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final filteredDistricts = districts.where((d) {
              if (selectedProvinceFilter == 'Tất cả') return true;
              return d['province_name'] == selectedProvinceFilter;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Chọn vị trí đặt sân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Tất cả', 'TP. Hồ Chí Minh', 'Hà Nội'].map((province) {
                      final isSelected = selectedProvinceFilter == province;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(province),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedProvinceFilter = province);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredDistricts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('Tất cả quận/huyện'),
                            trailing: selectedDistrictId == null ? const Icon(Icons.check_circle, color: primaryColor) : null,
                            onTap: () {
                              setState(() => selectedDistrictId = null);
                              Navigator.pop(context);
                            },
                          );
                        }
                        final dist = filteredDistricts[index - 1];
                        final bool isSelected = selectedDistrictId == dist['id'];
                        return ListTile(
                          title: Text('${dist['name']}, ${dist['province_name']}'),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: primaryColor) : null,
                          onTap: () {
                            setState(() => selectedDistrictId = dist['id']);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUserProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(radius: 44, backgroundImage: _getAvatarImageProvider()),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showChangeAvatarModal();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(currentUser['full_name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(currentUser['role'], style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildProfileRow(Icons.phone, 'Số điện thoại', currentUser['phone']),
            _buildProfileRow(Icons.email, 'Email', currentUser['email'] ?? 'Chưa cập nhật'),
            _buildProfileRow(Icons.calendar_today, 'Ngày tham gia', currentUser['created_at'].toString().split(' ')[0]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  void _toggleSportSelection(int sportId) {
    setState(() {
      if (sportId == 0) {
        selectedSportIds = [0];
      } else {
        selectedSportIds.remove(0);
        if (selectedSportIds.contains(sportId)) {
          selectedSportIds.remove(sportId);
          if (selectedSportIds.isEmpty) selectedSportIds.add(0);
        } else {
          selectedSportIds.add(sportId);
        }
      }
    });
  }

  IconData _getAmenityIcon(String? iconCode) {
    switch (iconCode) {
      case 'wifi':
        return Icons.wifi;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'shower':
        return Icons.shower;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildTabBody() {
    switch (selectedNavIndex) {
      case 0:
        return _buildHomeTabContent();
      case 1:
        return _buildMyBookingsTabContent();
      case 2:
        return _buildAccountTabContent();
      default:
        return _buildHomeTabContent();
    }
  }

  Widget _buildMyBookingsTabContent() {
    if (myBookings.isEmpty) {
      return _buildPlaceholderScreen('Lịch Của Tôi', Icons.confirmation_number_outlined);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch đặt sân của tôi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myBookings.length,
            itemBuilder: (context, index) {
              final booking = myBookings[index];
              final bool isCancelled = booking['status'] == 'CANCELLED';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mã đơn: #${booking['id']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCancelled ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCancelled ? 'Đã hủy' : 'Đã xác nhận',
                            style: TextStyle(
                              color: isCancelled ? Colors.red : primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(booking['court_name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.sports_tennis, size: 16, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(booking['court_detail_name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Ngày: ${booking['booking_date']}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Giờ: ${booking['time_slot']}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    ),
                    // Hiển thị lý do hủy nếu đơn đã bị hủy
                    if (isCancelled && booking['cancel_reason'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Lý do hủy: ${booking['cancel_reason']}',
                          style: const TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${booking['total_price'].toInt()}đ',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentOrange),
                        ),
                        if (!isCancelled)
                          OutlinedButton.icon(
                            onPressed: () => _cancelBooking(booking['id']),
                            icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                            label: const Text(
                              'Hủy sân',
                              style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red, width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTabContent() {
    final filteredCourts = courts.where((court) {
      final String courtName = court['name'].toString().toLowerCase();
      final String courtAddress = court['address'].toString().toLowerCase();
      final String query = searchQuery.toLowerCase();

      final matchesSearch = query.isEmpty || courtName.contains(query) || courtAddress.contains(query);
      final matchesDistrict = selectedDistrictId == null || court['district_id'] == selectedDistrictId;
      final matchesSport = selectedSportIds.contains(0) || selectedSportIds.contains(court['sport_id']);

      final courtAmenityIds = courtAmenities
          .where((ca) => ca['court_id'] == court['id'])
          .map((ca) => ca['amenity_id'])
          .toList();
      final matchesAmenities = selectedAmenityIds.isEmpty ||
          selectedAmenityIds.every((id) => courtAmenityIds.contains(id));

      if (activeFilterTab == 'FAVORITE') {
        return matchesSearch && matchesDistrict && matchesSport && matchesAmenities && favoriteCourtIds.contains(court['id']);
      }

      return matchesSearch && matchesDistrict && matchesSport && matchesAmenities;
    }).toList();

    String displayLocationText = 'Tất cả khu vực';
    if (selectedDistrictId != null) {
      final dist = districts.firstWhere((d) => d['id'] == selectedDistrictId);
      displayLocationText = '${dist['name']}, ${dist['province_name']}';
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showLocationPicker(context),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: primaryColor, size: 22),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vị trí của bạn', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              Row(
                                children: [
                                  Text(
                                    displayLocationText.length > 25 ? '${displayLocationText.substring(0, 22)}...' : displayLocationText,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.notifications_none, size: 24), onPressed: () {}),
                        GestureDetector(
                          onTap: () => _showUserProfileModal(context),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 2)),
                            child: CircleAvatar(radius: 16, backgroundImage: _getAvatarImageProvider()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm tên sân, khu vực...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                      icon: Icon(Icons.search, color: Colors.grey[500]),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Môn Thể Thao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: sports.map((sport) {
                    final int id = sport['id'];
                    final isSelected = selectedSportIds.contains(id);
                    return GestureDetector(
                      onTap: () => _toggleSportSelection(id),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
                            ),
                            child: Icon(sport['icon'], color: isSelected ? Colors.white : primaryColor, size: 26),
                          ),
                          const SizedBox(height: 6),
                          Text(sport['name'], style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterTab('Tất cả sân', 'ALL'),
                const SizedBox(width: 8),
                _buildFilterTab('Sân yêu thích (♥ ${favoriteCourtIds.length})', 'FAVORITE'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: amenities.map((amenity) {
                final int id = amenity['id'];
                final isSelected = selectedAmenityIds.contains(id);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(_getAmenityIcon(amenity['icon_code']), size: 14, color: isSelected ? Colors.white : Colors.grey[700]),
                    label: Text(amenity['name'], style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.white,
                    selectedColor: primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    onSelected: (val) {
                      setState(() {
                        isSelected ? selectedAmenityIds.remove(id) : selectedAmenityIds.add(id);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          filteredCourts.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        activeFilterTab == 'FAVORITE' ? Icons.favorite_border : Icons.search_off,
                        size: 48,
                        color: activeFilterTab == 'FAVORITE' ? Colors.red[300] : Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        activeFilterTab == 'FAVORITE' ? 'Chưa có sân yêu thích' : 'Không tìm thấy sân phù hợp',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeFilterTab == 'FAVORITE'
                            ? 'Bấm biểu tượng trái tim ♥ ở góc ảnh các sân để lưu lại xem sau!'
                            : 'Hãy thử chọn khu vực khác hoặc xóa bớt bộ lọc',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            activeFilterTab = 'ALL';
                            selectedDistrictId = null;
                            selectedSportIds = [0];
                            selectedAmenityIds = [];
                            searchQuery = '';
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: Text(
                          activeFilterTab == 'FAVORITE' ? 'Khám phá danh sách sân' : 'Đặt lại bộ lọc',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCourts.length,
                  itemBuilder: (context, index) {
                    final court = filteredCourts[index];
                    final int courtId = court['id'];
                    final isFav = favoriteCourtIds.contains(courtId);
                    final String imageUrl = _getCoverImage(courtId);
                    final double minPrice = _getMinPrice(courtId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => _toggleFavoriteCourt(courtId),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(court['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(court['address'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    Text(
                                      '${minPrice.toInt()}đ / giờ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: accentOrange,
                                      ),
                                    ),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/review',
                                          arguments: {
                                            'bookingId': 1,
                                            'userId': currentUser['id'],
                                            'courtName': court['name'],
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.star_rounded, size: 18, color: primaryColor),
                                      label: const Text(
                                        'Đánh giá',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: primaryColor, width: 1.2),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SlotPickerScreen(
                                              courtId: court['id'],
                                              courtName: court['name'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Đặt sân ngay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAccountTabContent() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(radius: 50, backgroundImage: _getAvatarImageProvider()),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showChangeAvatarModal,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(currentUser['full_name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(currentUser['email'] ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                setState(() {
                  selectedNavIndex = 0;
                  activeFilterTab = 'FAVORITE';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(width: 12),
                    const Text('Sân yêu thích của tôi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Text('${favoriteCourtIds.length} sân', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    const Icon(Icons.chevron_right, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildProfileRow(Icons.phone, 'Số điện thoại', currentUser['phone']),
            _buildProfileRow(Icons.security, 'Quyền hạn', currentUser['role']),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: primaryColor),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Các lịch đặt sân của bạn sẽ xuất hiện tại đây', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String tabKey) {
    final isSelected = activeFilterTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => activeFilterTab = tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: _buildTabBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedNavIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'Lịch của tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
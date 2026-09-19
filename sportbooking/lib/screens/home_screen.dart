import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'slot_picker_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF00A86B);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  static const String baseUrl = 'http://127.0.0.1:5000/api';

  int selectedNavIndex = 0;
  String searchQuery = '';

  int? selectedDistrictId;
  String selectedProvinceFilter = 'Tất cả';

  List<int> selectedSportIds = [0];
  List<int> selectedAmenityIds = [];
  List<int> favoriteCourtIds = [];
  String activeFilterTab = 'ALL';

  File? _localAvatarFile;
  bool _isLoading = true;

  Map<String, dynamic> currentUser = {
    'id': 0,
    'phone': '',
    'full_name': 'Đang tải...',
    'role': 'CUSTOMER',
    'email': '',
    'avatar_url': 'https://i.pravatar.cc/300?img=12',
    'created_at': '',
  };

  List<Map<String, dynamic>> sports = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> courts = [];
  List<Map<String, dynamic>> amenities = [];
  List<Map<String, dynamic>> myBookings = [];

  @override
  void initState() {
    super.initState();
    _loadAllInitialData();
  }

  // ----------------------------------------------------
  // TẢI DỮ LIỆU TỪ CSDL
  // ----------------------------------------------------
  Future<void> _loadAllInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchUserProfile(),
      _fetchSports(),
      _fetchDistricts(),
      _fetchAmenities(),
      _fetchCourts(),
      _fetchFavorites(),
      _fetchMyBookings(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? data;
        setState(() {
          currentUser = {
            'id': user['id'] ?? currentUser['id'],
            // Bắt cả 'full_name' lẫn 'name', nếu rỗng sẽ giữ tên 'Nguyễn Đức Tín'
            'full_name': user['full_name'] ?? user['name'] ?? 'Nguyễn Đức Tín',
            'phone': user['phone'] ?? '0905682143',
            'email': user['email'] ?? '',
            'role': user['role'] ?? 'CUSTOMER',
            // Bắt cả 'avatar_url' lẫn 'avatar' từ CSDL
            'avatar_url':
                user['avatar_url'] ??
                user['avatar'] ??
                currentUser['avatar_url'],
            'created_at': _formatDate(user['created_at']),
          };
        });
      }
    } catch (e) {
      print("Lỗi tải thông tin user: $e");
    }
  }

  void _showAddEmailDialog() {
    final TextEditingController emailController = TextEditingController(
      text:
          (currentUser['email'] != null &&
              currentUser['email'].toString().isNotEmpty)
          ? currentUser['email']
          : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Thêm / Cập nhật Email',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập địa chỉ email của bạn:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'vi_du@email.com',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newEmail = emailController.text.trim();
                if (newEmail.isEmpty) return;

                Navigator.pop(dialogContext);

                try {
                  final token = await _getToken();
                  final response = await http.put(
                    Uri.parse('$baseUrl/users/profile'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({'email': newEmail}),
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    setState(() {
                      currentUser['email'] = newEmail;
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cập nhật Email thành công!'),
                        backgroundColor: primaryColor,
                      ),
                    );
                  }
                } catch (e) {
                  print("Lỗi cập nhật email: $e");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchSports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sports'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          sports = [
            {
              'id': 0,
              'name': 'Tất cả',
              'icon_url': null,
              'icon_fallback': Icons.sports_kabaddi,
            },
            ...data.map(
              (s) => {
                'id': s['id'],
                'name': s['name'],
                'icon_url': s['icon_url'],
                'icon_fallback': _getSportIconByName(s['name']),
              },
            ),
          ];
        });
      }
    } catch (e) {
      print("Lỗi tải sports: $e");
    }
  }

  Future<void> _fetchDistricts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/districts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          districts = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("Lỗi tải districts: $e");
    }
  }

  Future<void> _fetchAmenities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/amenities'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          amenities = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("Lỗi tải amenities: $e");
    }
  }

  Future<void> _fetchCourts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/courts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          courts = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("Lỗi tải courts: $e");
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          favoriteCourtIds = data
              .map<int>((item) => item['court_id'] as int)
              .toList();
        });
      }
    } catch (e) {
      print("Lỗi tải favorites: $e");
    }
  }

  Future<void> _fetchMyBookings() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/my-bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          myBookings = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("Lỗi tải bookings: $e");
    }
  }

  Future<void> _toggleFavoriteCourt(int courtId) async {
    final isFav = favoriteCourtIds.contains(courtId);
    setState(() {
      isFav ? favoriteCourtIds.remove(courtId) : favoriteCourtIds.add(courtId);
    });

    try {
      final token = await _getToken();
      if (token == null) return;

      await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'court_id': courtId}),
      );
    } catch (e) {
      print("Lỗi favorite toggle: $e");
    }
  }

  void _cancelBooking(int bookingId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận hủy sân',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bạn có chắc chắn muốn hủy đơn đặt sân này không?'),
                const SizedBox(height: 16),
                const Text(
                  'Lý do hủy sân:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do hủy sân...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Bỏ qua'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reasonText = reasonController.text.trim();
                Navigator.pop(dialogContext);

                try {
                  final token = await _getToken();
                  final response = await http.put(
                    Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'cancellation_reason': reasonText.isNotEmpty
                          ? reasonText
                          : 'Người dùng hủy',
                    }),
                  );

                  if (response.statusCode == 200) {
                    _fetchMyBookings();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã hủy đơn đặt sân thành công!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print("Lỗi hủy sân: $e");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Hủy sân',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image == null) return;

    // Hiển thị tạm ảnh local từ máy
    setState(() {
      _localAvatarFile = File(image.path);
    });

    try {
      final token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/avatar'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('avatar', bytes, filename: image.name),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("🔥 [DEBUG] Status Code: ${response.statusCode}");
      print("🔥 [DEBUG] Body từ Server: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Bắt mọi tên key phổ biến mà Backend có thể trả về
        String? rawUrl =
            data['avatarUrl'] ??
            data['avatar_url'] ??
            data['avatar'] ??
            data['url'] ??
            data['path'];
        print("🔥 [DEBUG] Đường dẫn nhận được: $rawUrl");

        if (rawUrl == null || rawUrl.toString().trim().isEmpty) {
          print("❌ [LỖI] Backend không trả về đường dẫn ảnh!");
          return;
        }

        // Xóa cache RAM
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        // Tự động ghép Host Server nếu là đường dẫn tương đối (/uploads/...)
        String fullUrl = rawUrl.toString().trim();
        if (!fullUrl.startsWith('http')) {
          String serverHost = baseUrl.replaceAll('/api', '');
          if (serverHost.endsWith('/')) {
            serverHost = serverHost.substring(0, serverHost.length - 1);
          }
          final cleanPath = fullUrl.startsWith('/') ? fullUrl : '/$fullUrl';
          fullUrl = '$serverHost$cleanPath';
        }

        // Thêm timestamp chống cache
        final int timestamp = DateTime.now().millisecondsSinceEpoch;
        final String refreshedUrl = fullUrl.contains('?')
            ? '$fullUrl&t=$timestamp'
            : '$fullUrl?t=$timestamp';

        print("🔥 [DEBUG] URL cuối cùng hiển thị: $refreshedUrl");

        setState(() {
          _localAvatarFile =
              null; // Bỏ ảnh tạm local, chuyển sang dùng URL server
          currentUser['avatar_url'] = refreshedUrl;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi ảnh đại diện thành công!'),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        print("❌ [LỖI SERVER] ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [LỖI EXCEPTION] $e");
    }
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Chưa cập nhật';
    try {
      DateTime dt = DateTime.parse(rawDate.toString());
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (e) {
      return 'Chưa cập nhật';
    }
  }

  IconData _getSportIconByName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cầu lông') || lower.contains('tennis'))
      return Icons.sports_tennis;
    if (lower.contains('bóng đá')) return Icons.sports_soccer;
    if (lower.contains('bóng rổ')) return Icons.sports_basketball;
    if (lower.contains('pickleball')) return Icons.sports_handball;
    return Icons.sports;
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

  ImageProvider _getAvatarImageProvider() {
    if (_localAvatarFile != null) {
      return FileImage(_localAvatarFile!);
    }

    final avatarUrl = currentUser['avatar_url']?.toString().trim();

    if (avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl != 'null') {
      return NetworkImage(avatarUrl);
    }

    return const NetworkImage('https://i.pravatar.cc/300?img=12');
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

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                      const Text(
                        'Chọn vị trí đặt sân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Tất cả', 'TP. Hồ Chí Minh', 'Hà Nội'].map((
                      province,
                    ) {
                      final isSelected = selectedProvinceFilter == province;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(province),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          onSelected: (val) {
                            if (val)
                              setModalState(
                                () => selectedProvinceFilter = province,
                              );
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
                            trailing: selectedDistrictId == null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: primaryColor,
                                  )
                                : null,
                            onTap: () {
                              setState(() => selectedDistrictId = null);
                              Navigator.pop(context);
                            },
                          );
                        }
                        final dist = filteredDistricts[index - 1];
                        final bool isSelected =
                            selectedDistrictId == dist['id'];
                        return ListTile(
                          title: Text(
                            '${dist['district_name']}, ${dist['province_name']}',
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: primaryColor,
                                )
                              : null,
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

  // ----------------------------------------------------
  // GIAO DIỆN CHÍNH CÁC TAB
  // ----------------------------------------------------
  Widget _buildTabBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

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

  // TAB TRANG CHỦ
  Widget _buildHomeTabContent() {
    final filteredCourts = courts.where((court) {
      final String courtName = (court['name'] ?? '').toString().toLowerCase();
      final String courtAddress = (court['address'] ?? '')
          .toString()
          .toLowerCase();
      final String query = searchQuery.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          courtName.contains(query) ||
          courtAddress.contains(query);
      final matchesDistrict =
          selectedDistrictId == null ||
          court['district_id'] == selectedDistrictId;
      final matchesSport =
          selectedSportIds.contains(0) ||
          selectedSportIds.contains(court['sport_id']);

      final List<dynamic> courtAmenityIds = court['amenity_ids'] ?? [];
      final matchesAmenities =
          selectedAmenityIds.isEmpty ||
          selectedAmenityIds.every((id) => courtAmenityIds.contains(id));

      if (activeFilterTab == 'FAVORITE') {
        return matchesSearch &&
            matchesDistrict &&
            matchesSport &&
            matchesAmenities &&
            favoriteCourtIds.contains(court['id']);
      }
      return matchesSearch &&
          matchesDistrict &&
          matchesSport &&
          matchesAmenities;
    }).toList();

    String displayLocationText = 'Tất cả khu vực';
    if (selectedDistrictId != null && districts.isNotEmpty) {
      final dist = districts.firstWhere(
        (d) => d['id'] == selectedDistrictId,
        orElse: () => {},
      );
      if (dist.isNotEmpty) {
        displayLocationText =
            '${dist['district_name']}, ${dist['province_name']}';
      }
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
                          const Icon(
                            Icons.location_on,
                            color: primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vị trí của bạn',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    displayLocationText.length > 25
                                        ? '${displayLocationText.substring(0, 22)}...'
                                        : displayLocationText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none, size: 24),
                          onPressed: () {},
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedNavIndex = 2; // Chuyển sang tab Tài khoản
                            });
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: _getAvatarImageProvider(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm tên sân, khu vực...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
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

          // MỤC MÔN THỂ THAO
          if (sports.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Môn Thể Thao',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                                color: isSelected
                                    ? primaryColor
                                    : Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(color: primaryColor, width: 2)
                                    : null,
                              ),
                              child: sport['icon_url'] != null
                                  ? Image.network(
                                      sport['icon_url'],
                                      width: 26,
                                      height: 26,
                                    )
                                  : Icon(
                                      sport['icon_fallback'] ?? Icons.sports,
                                      color: isSelected
                                          ? Colors.white
                                          : primaryColor,
                                      size: 26,
                                    ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sport['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // FILTER TABS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterTab('Tất cả sân', 'ALL'),
                const SizedBox(width: 8),
                _buildFilterTab(
                  'Sân yêu thích (♥ ${favoriteCourtIds.length})',
                  'FAVORITE',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // AMENITIES
          if (amenities.isNotEmpty)
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
                      avatar: Icon(
                        _getAmenityIcon(amenity['icon_code']),
                        size: 14,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                      label: Text(
                        amenity['name'],
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (val) {
                        setState(() {
                          isSelected
                              ? selectedAmenityIds.remove(id)
                              : selectedAmenityIds.add(id);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          // DANH SÁCH THẺ SÂN
          filteredCourts.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        activeFilterTab == 'FAVORITE'
                            ? Icons.favorite_border
                            : Icons.search_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        activeFilterTab == 'FAVORITE'
                            ? 'Chưa có sân yêu thích'
                            : 'Không tìm thấy sân phù hợp',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                    final String imageUrl =
                        court['cover_image'] ??
                        'https://picsum.photos/400/220?random=$courtId';
                    final double minPrice =
                        (court['min_price'] as num?)?.toDouble() ?? 100000;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.stadium,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => _toggleFavoriteCourt(courtId),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav
                                          ? Colors.red
                                          : Colors.grey[600],
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
                                Text(
                                  court['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  court['address'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
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
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SlotPickerScreen(
                                                  courtId: court['id'],
                                                  courtName: court['name'],
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
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

  // TAB LỊCH CỦA TÔI
  Widget _buildMyBookingsTabContent() {
    if (myBookings.isEmpty) {
      return const Center(child: Text('Bạn chưa có đơn đặt sân nào.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch đặt sân của tôi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mã đơn: #${booking['booking_code'] ?? booking['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCancelled
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
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
                    Text(
                      booking['court_name'] ?? 'Sân thể thao',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày tạo: ${booking['created_at']?.toString().split('T')[0] ?? ''}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    if (isCancelled &&
                        booking['cancellation_reason'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Lý do hủy: ${booking['cancellation_reason']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(booking['total_amount'] as num?)?.toInt() ?? 0}đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: accentOrange,
                          ),
                        ),
                        if (!isCancelled)
                          OutlinedButton(
                            onPressed: () => _cancelBooking(booking['id']),
                            child: const Text(
                              'Hủy sân',
                              style: TextStyle(color: Colors.red),
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

  // TAB TÀI KHOẢN (KHÔI PHỦ CHUẨN CARD NHƯ ẢNH MÔ TẢ)
  Widget _buildAccountTabContent() {
    final bool hasEmail =
        currentUser['email'] != null &&
        currentUser['email'].toString().trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar kèm Nút Camera góc dưới
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: _getAvatarImageProvider(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Họ tên & Mail/Chưa cập nhật
              Text(
                currentUser['full_name'] ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Thẻ Sân yêu thích của tôi
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedNavIndex = 0;
                    activeFilterTab = 'FAVORITE';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sân yêu thích của tôi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${favoriteCourtIds.length} sân >',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 24, thickness: 1),
              const SizedBox(height: 16),

              // Dòng Số điện thoại
              Row(
                children: [
                  Icon(Icons.phone_outlined, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Số điện thoại',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    currentUser['phone'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email_outlined, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (hasEmail) ...[
                    Text(
                      currentUser['email'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _showAddEmailDialog,
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Chưa cập nhật',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showAddEmailDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '+ Thêm',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Dòng Quyền hạn

              Row(
                children: [
                  Icon(
                    Icons.security_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quyền hạn',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    'Người chơi',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Nút Đăng xuất viền xám
              OutlinedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(
                  Icons.logout,
                  size: 18,
                  color: const Color.fromARGB(255, 215, 16, 16),
                ),
                label: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
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
        onTap: (index) => setState(() => selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Lịch của tôi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

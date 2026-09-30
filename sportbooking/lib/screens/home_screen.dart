import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/district_service.dart';
import '../services/court_distance.dart';
import '../services/local_booking_store.dart';
import '../services/mock_court_catalog.dart';
import '../widgets/location_selection_modal.dart';
import 'slot_picker_screen.dart';
import 'login_screen.dart';
import 'review_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF00A86B);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  static String get baseUrl => DistrictService.apiBaseUrl;

  int selectedNavIndex = 0;
  String searchQuery = '';

  int? selectedDistrictId;
  String selectedProvinceFilter = 'Tất cả';
  double? selectedLatitude;
  double? selectedLongitude;

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
  final Set<String> _cancellingBookingKeys = {};

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
        final profileName =
            (user['fullName'] ?? user['full_name'] ?? user['name'] ?? '')
                .toString()
                .trim();
        setState(() {
          currentUser = {
            'id': user['id'] ?? currentUser['id'],
            'full_name': profileName.isNotEmpty
                ? profileName
                : currentUser['full_name'],
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
        final loadedSports = data
            .map<Map<String, dynamic>>(
              (sport) => {
                'id': int.parse(sport['id'].toString()),
                'name': sport['name'].toString(),
                'icon_url': sport['icon_url'],
                'icon_fallback': _getSportIconByName(sport['name'].toString()),
              },
            )
            .toList();
        var nextId = loadedSports.isEmpty
            ? 1
            : loadedSports
                      .map((sport) => sport['id'] as int)
                      .reduce((a, b) => a > b ? a : b) +
                  1;
        for (final mockSport in MockCourtCatalog.sports) {
          final alreadyExists = loadedSports.any(
            (sport) =>
                sport['name'].toString().toLowerCase() ==
                mockSport['name'].toString().toLowerCase(),
          );
          if (!alreadyExists) {
            loadedSports.add({
              'id': nextId++,
              'name': mockSport['name'],
              'icon_url': null,
              'icon_fallback': mockSport['icon'],
            });
          }
        }

        setState(() {
          sports = [
            {
              'id': 0,
              'name': 'Tất cả',
              'icon_url': null,
              'icon_fallback': Icons.sports_kabaddi,
            },
            ...loadedSports,
          ];
        });
      } else {
        _setMockSports();
      }
    } catch (e) {
      print("Lỗi tải sports: $e");
      _setMockSports();
    }
  }

  void _setMockSports() {
    if (!mounted) return;
    setState(() {
      sports = [
        {
          'id': 0,
          'name': 'Tất cả',
          'icon_url': null,
          'icon_fallback': Icons.sports_kabaddi,
        },
        ...MockCourtCatalog.sports.map(
          (sport) => {
            'id': sport['id'],
            'name': sport['name'],
            'icon_url': null,
            'icon_fallback': sport['icon'],
          },
        ),
      ];
    });
  }

  Future<void> _fetchDistricts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/districts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          districts = DistrictService.withHoChiMinhDistricts(
            List<Map<String, dynamic>>.from(data),
          );
        });
      } else {
        setState(() {
          districts = DistrictService.withHoChiMinhDistricts(const []);
        });
      }
    } catch (e) {
      print("Lỗi tải districts: $e");
      if (mounted) {
        setState(() {
          districts = DistrictService.withHoChiMinhDistricts(const []);
        });
      }
    }
  }

  Future<void> _fetchAmenities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/amenities'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          amenities = data.isEmpty
              ? List<Map<String, dynamic>>.from(MockCourtCatalog.amenities)
              : List<Map<String, dynamic>>.from(data);
        });
      } else {
        _setMockAmenities();
      }
    } catch (e) {
      print("Lỗi tải amenities: $e");
      _setMockAmenities();
    }
  }

  void _setMockAmenities() {
    if (!mounted) return;
    setState(() {
      amenities = List<Map<String, dynamic>>.from(MockCourtCatalog.amenities);
    });
  }

  Future<void> _fetchCourts({
    int? districtId,
    String? provinceName,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (districtId != null) {
        queryParameters['district_id'] = districtId.toString();
      }
      if (provinceName != null && provinceName.isNotEmpty) {
        queryParameters['province_name'] = provinceName;
      }
      if (latitude != null && longitude != null) {
        queryParameters['lat'] = latitude.toString();
        queryParameters['lng'] = longitude.toString();
      }
      final uri = Uri.parse('$baseUrl/courts').replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          courts = data.isEmpty
              ? List<Map<String, dynamic>>.from(MockCourtCatalog.courts)
              : List<Map<String, dynamic>>.from(data);
        });
      } else {
        _setMockCourts();
      }
    } catch (e) {
      print("Lỗi tải courts: $e");
      _setMockCourts();
    }
  }

  void _setMockCourts() {
    if (!mounted) return;
    setState(() {
      courts = List<Map<String, dynamic>>.from(MockCourtCatalog.courts);
    });
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
    final localBookings = await LocalBookingStore.getBookings();
    if (mounted) {
      setState(() => myBookings = localBookings);
    }

    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/my-bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final remoteBookings = List<Map<String, dynamic>>.from(data);
        final localBookings = await LocalBookingStore.getBookings();
        final mergedBookings = <Map<String, dynamic>>[];
        for (final remoteBooking in remoteBookings) {
          final localIndex = localBookings.indexWhere(
            (localBooking) => _sameBooking(localBooking, remoteBooking),
          );
          mergedBookings.add(
            localIndex == -1
                ? remoteBooking
                : {...remoteBooking, ...localBookings[localIndex]},
          );
        }
        mergedBookings.addAll(
          localBookings.where(
            (localBooking) => !remoteBookings.any(
              (remoteBooking) => _sameBooking(localBooking, remoteBooking),
            ),
          ),
        );
        if (mounted) setState(() => myBookings = mergedBookings);
      }
    } catch (e) {
      print("Lỗi tải bookings: $e");
    }
  }

  bool _sameBooking(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    final firstCode = first['booking_code']?.toString();
    final secondCode = second['booking_code']?.toString();
    if (firstCode != null &&
        firstCode.isNotEmpty &&
        secondCode != null &&
        secondCode.isNotEmpty &&
        firstCode == secondCode) {
      return true;
    }
    final firstId = (first['id'] ?? first['booking_id'])?.toString();
    final secondId = (second['id'] ?? second['booking_id'])?.toString();
    return firstId != null && firstId.isNotEmpty && firstId == secondId;
  }

  String _bookingKey(Map<String, dynamic> booking) =>
      booking['booking_code']?.toString() ??
      (booking['id'] ?? booking['booking_id'])?.toString() ??
      booking.hashCode.toString();

  List<Map<String, dynamic>> get _activeBookingNotifications => myBookings
      .where((booking) => booking['status'] != 'CANCELLED')
      .toList();

  String _formatBookingDate(dynamic value) {
    if (value == null) return 'Chưa rõ ngày';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showBookingNotifications() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final notifications = _activeBookingNotifications;
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Thông báo',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 44,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('Bạn chưa có thông báo đặt sân.'),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final booking = notifications[index];
                            final slots = booking['selected_slots'];
                            final slotLines = slots is List
                                ? slots
                                      .whereType<Map>()
                                      .map(
                                        (slot) =>
                                            '${slot['court_detail_name'] ?? 'Sân'} '
                                            '${slot['start_time'] ?? ''} - '
                                            '${slot['end_time'] ?? ''}',
                                      )
                                      .toList()
                                : <String>[];

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Đặt sân thành công',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Sân: ${booking['court_name'] ?? 'Sân thể thao'}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          'Ngày: ${_formatBookingDate(booking['booking_date'])}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        if (slotLines.isNotEmpty) ...[
                                          const SizedBox(height: 5),
                                          ...slotLines.map(
                                            (line) => Text(
                                              line,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
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
        );
      },
    );
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

  Future<void> _cancelBookingImmediately(
    Map<String, dynamic> booking,
  ) async {
    final key = _bookingKey(booking);
    if (_cancellingBookingKeys.contains(key)) return;

    const reason = 'Người dùng hủy';
    final bookingIndex = myBookings.indexWhere(
      (item) => _sameBooking(item, booking),
    );
    if (bookingIndex == -1) return;

    final previousBooking = myBookings[bookingIndex];
    setState(() {
      _cancellingBookingKeys.add(key);
      myBookings[bookingIndex] = {
        ...previousBooking,
        'status': 'CANCELLED',
        'cancellation_reason': reason,
      };
    });

    try {
      await LocalBookingStore.cancelBooking(booking, reason: reason);
    } catch (error) {
      if (mounted) {
        setState(() {
          myBookings[bookingIndex] = previousBooking;
          _cancellingBookingKeys.remove(key);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lưu trạng thái hủy sân: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    var serverSyncFailed = false;
    final bookingId = booking['id'] ?? booking['booking_id'];
    try {
      final token = await _getToken();
      if (token != null && bookingId != null) {
        final response = await http.put(
          Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '******',
          },
          body: jsonEncode({'cancellation_reason': reason}),
        );
        serverSyncFailed =
            response.statusCode < 200 || response.statusCode >= 300;
      }
    } catch (error) {
      serverSyncFailed = true;
      debugPrint('Lỗi đồng bộ hủy sân lên máy chủ: $error');
    } finally {
      if (mounted) {
        setState(() => _cancellingBookingKeys.remove(key));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              serverSyncFailed
                  ? 'Đã hủy sân trên thiết bị, nhưng chưa đồng bộ được với máy chủ.'
                  : 'Đã hủy sân thành công!',
            ),
            backgroundColor: serverSyncFailed
                ? Colors.orange.shade800
                : primaryColor,
          ),
        );
      }
    }
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    if (booking.isNotEmpty) {
      _cancelBookingImmediately(booking);
      return;
    }

    final bookingId = booking['id'] ?? booking['booking_id'];
    if (booking.isEmpty) {
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
    if (lower.contains('bóng rổ')) return Icons.sports_basketball;
    if (lower.contains('bóng chuyền')) return Icons.sports_volleyball;
    if (lower.contains('cầu lông') || lower.contains('tennis')) {
      return Icons.sports_tennis;
    }
    if (lower.contains('bóng đá')) return Icons.sports_soccer;
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LocationSelectionModal(
        initialDistrictId: selectedDistrictId,
        initialProvinceName: selectedProvinceFilter == 'Tất cả'
            ? null
            : selectedProvinceFilter,
        initialLatitude: selectedLatitude,
        initialLongitude: selectedLongitude,
      ),
    ).then((selection) {
      if (selection is! Map<String, dynamic> || !mounted) return;

      final districtId = selection['district_id'];
      final latitude = selection['lat'];
      final longitude = selection['lng'];
      final provinceName = selection['province_name']?.toString();
      setState(() {
        selectedDistrictId = districtId is num
            ? districtId.toInt()
            : districtId == null
            ? null
            : int.tryParse(districtId.toString());
        selectedProvinceFilter = provinceName ?? 'Tất cả';
        selectedLatitude = latitude is num ? latitude.toDouble() : null;
        selectedLongitude = longitude is num ? longitude.toDouble() : null;
      });

      _fetchCourts(
        districtId: selectedDistrictId,
        provinceName: selectedProvinceFilter == 'Tất cả'
            ? null
            : selectedProvinceFilter,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );
    });
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
      final provinceDistrictIds = districts
          .where(
            (district) => district['province_name'] == selectedProvinceFilter,
          )
          .map((district) => district['id'].toString())
          .toSet();
      final selectedDistrict = selectedDistrictId == null
          ? null
          : districts.cast<Map<String, dynamic>?>().firstWhere(
              (district) =>
                  district?['id'].toString() ==
                  selectedDistrictId.toString(),
              orElse: () => null,
            );
      final selectedDistrictName =
          selectedDistrict?['name']?.toString().toLowerCase();
      final matchesDistrict = selectedDistrictId != null
          ? court['district_id']?.toString() == selectedDistrictId.toString() ||
                (selectedDistrictName != null &&
                    courtAddress.contains(selectedDistrictName))
          : selectedProvinceFilter == 'Tất cả' ||
                provinceDistrictIds.contains(court['district_id'].toString()) ||
                courtAddress.contains(selectedProvinceFilter.toLowerCase());
      final matchesNearby =
          selectedLatitude == null ||
          selectedLongitude == null ||
          CourtDistance.isWithinNearbyRadius(
            court: court,
            latitude: selectedLatitude!,
            longitude: selectedLongitude!,
          );
      final courtSportId = int.tryParse(court['sport_id']?.toString() ?? '');
      final matchesSport =
          selectedSportIds.contains(0) ||
          (courtSportId != null && selectedSportIds.contains(courtSportId)) ||
          sports.any(
            (sport) =>
                selectedSportIds.contains(sport['id']) &&
                sport['name'].toString().toLowerCase() ==
                    court['sport_name']?.toString().toLowerCase(),
          );

      final List<dynamic> courtAmenityIds = court['amenity_ids'] ?? [];
      final List<dynamic> courtAmenityNames = court['amenity_names'] ?? [];
      final matchesAmenities =
          selectedAmenityIds.isEmpty ||
          selectedAmenityIds.every((id) {
            if (courtAmenityIds.contains(id)) return true;
            final amenity = amenities.firstWhere(
              (item) => item['id'].toString() == id.toString(),
              orElse: () => {},
            );
            return amenity.isNotEmpty &&
                courtAmenityNames.any(
                  (name) =>
                      name.toString().toLowerCase() ==
                      amenity['name'].toString().toLowerCase(),
                );
          });

      if (activeFilterTab == 'FAVORITE') {
        return matchesSearch &&
            matchesDistrict &&
            matchesNearby &&
            matchesSport &&
            matchesAmenities &&
            favoriteCourtIds.contains(court['id']);
      }
      return matchesSearch &&
          matchesDistrict &&
          matchesNearby &&
          matchesSport &&
          matchesAmenities;
    }).toList();

    String displayLocationText = selectedLatitude != null
        ? 'Vị trí của tôi'
        : selectedProvinceFilter == 'Tất cả'
        ? 'Tất cả khu vực'
        : selectedProvinceFilter;
    if (selectedDistrictId != null && districts.isNotEmpty) {
      final dist = districts.firstWhere(
        (d) => d['id'].toString() == selectedDistrictId.toString(),
        orElse: () => {},
      );
      if (dist.isNotEmpty) {
        displayLocationText = '${dist['name']}, ${dist['province_name']}';
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
                          tooltip: 'Thông báo',
                          onPressed: _showBookingNotifications,
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none, size: 24),
                              if (_activeBookingNotifications.isNotEmpty)
                                Positioned(
                                  right: -5,
                                  top: -4,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = 84.0;
                      final rowWidth =
                          constraints.maxWidth > sports.length * itemWidth
                          ? constraints.maxWidth
                          : sports.length * itemWidth;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: rowWidth,
                          height: 94,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: sports.map((sport) {
                              final int id = int.parse(sport['id'].toString());
                              final isSelected = selectedSportIds.contains(id);
                              return GestureDetector(
                                onTap: () => _toggleSportSelection(id),
                                child: SizedBox(
                                  width: 72,
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: primaryColor,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: sport['icon_url'] != null
                                            ? Image.network(
                                                sport['icon_url'],
                                                width: 26,
                                                height: 26,
                                                errorBuilder: (_, _, _) => Icon(
                                                  sport['icon_fallback'] ??
                                                      Icons.sports,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : primaryColor,
                                                  size: 26,
                                                ),
                                              )
                                            : Icon(
                                                sport['icon_fallback'] ??
                                                    Icons.sports,
                                                color: isSelected
                                                    ? Colors.white
                                                    : primaryColor,
                                                size: 26,
                                              ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        sport['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
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
                            : 'Hiện tại không có sân',
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
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReviewScreen(
                                              userId:
                                                  int.tryParse(
                                                    currentUser['id']
                                                        .toString(),
                                                  ) ??
                                                  0,
                                              courtName:
                                                  court['name'].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.star, size: 16),
                                      label: const Text('Đánh giá'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryColor,
                                        side: const BorderSide(
                                          color: primaryColor,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        shape: const StadiumBorder(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                        ).then((booking) {
                                          _fetchMyBookings();
                                        });
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
              final bookingDate = booking['booking_date'] ?? booking['date'];
              final selectedSlots = booking['selected_slots'];

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
                    if (bookingDate != null) ...[
                      Text(
                        'Ngày đặt: ${bookingDate.toString().split('T')[0]}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (selectedSlots is List && selectedSlots.isNotEmpty) ...[
                      const Text(
                        'Khung giờ đã đặt:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...selectedSlots.map((slot) {
                        if (slot is! Map) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '${slot['court_detail_name'] ?? 'Sân'}: '
                            '${slot['start_time'] ?? ''} - '
                            '${slot['end_time'] ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      Text(
                        'Ngày tạo: ${booking['created_at']?.toString().split('T')[0] ?? ''}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
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
                            onPressed: _cancellingBookingKeys.contains(
                              _bookingKey(booking),
                            )
                                ? null
                                : () => _cancelBooking(booking),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: const BorderSide(color: primaryColor),
                            ),
                            child: const Text(
                              'Hủy sân',
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

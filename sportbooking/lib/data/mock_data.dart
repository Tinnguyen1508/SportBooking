import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MockData {
  static const bool enabled = false;
  static const String _bookingsKey = 'mock_bookings';
  static const String _favoritesKey = 'mock_favorite_court_ids';

  static const List<String> provinces = [
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bạc Liêu',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cần Thơ',
    'Cao Bằng',
    'Đà Nẵng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Nội',
    'Hà Tĩnh',
    'Hải Dương',
    'Hải Phòng',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'TP. Hồ Chí Minh',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];

  static const List<Map<String, dynamic>> sports = [
    {'id': 1, 'name': 'Cầu lông'},
    {'id': 2, 'name': 'Pickleball'},
    {'id': 3, 'name': 'Bóng đá'},
    {'id': 4, 'name': 'Tennis'},
    {'id': 5, 'name': 'Bóng chuyền'},
    {'id': 6, 'name': 'Bóng rổ'},
  ];

  static const List<Map<String, dynamic>> amenities = [
    {'id': 1, 'name': 'Wifi', 'icon_code': 'wifi'},
    {'id': 2, 'name': 'Đỗ ô tô', 'icon_code': 'directions_car'},
    {'id': 3, 'name': 'Căng tin', 'icon_code': 'local_cafe'},
    {'id': 4, 'name': 'Phòng tắm', 'icon_code': 'shower'},
  ];

  static const List<Map<String, dynamic>> courts = [
    {
      'id': 6,
      'name': 'Sân Cầu Lông HCMUTE',
      'address': 'Gần Trường Đại học Sư phạm Kỹ thuật TP.HCM, TP. Thủ Đức',
      'cover_image':
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=1200',
      'min_price': 70000,
      'district_id': 7,
      'sport_id': 1,
      'amenity_ids': [1, 3, 4],
      'latitude': 10.8509,
      'longitude': 106.7721,
    },
  ];

  static Future<List<Map<String, dynamic>>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_bookingsKey);
    if (value == null) return [];

    final decoded = jsonDecode(value);
    if (decoded is! List) {
      throw const FormatException('Dữ liệu đặt sân mẫu không hợp lệ');
    }
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> saveBookings(List<Map<String, dynamic>> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookingsKey, jsonEncode(bookings));
  }

  static Future<List<int>> loadFavoriteCourtIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey)?.map(int.parse).toList() ?? [];
  }

  static Future<void> saveFavoriteCourtIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesKey,
      ids.map((id) => id.toString()).toList(),
    );
  }

  static Future<List<Map<String, String>>> loadBookedSlots({
    required int courtId,
    required DateTime date,
  }) async {
    final bookings = await loadBookings();
    final dateKey =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final matchingBookings = bookings.where((booking) {
      final bookingCourtId = int.tryParse(
        booking['court_id']?.toString() ?? '',
      );
      final bookingDate =
          booking['booking_date']?.toString() ??
          booking['date']?.toString() ??
          '';
      return bookingCourtId == courtId && bookingDate.startsWith(dateKey);
    });

    final result = <Map<String, String>>[];
    for (final booking in matchingBookings) {
      final slots = booking['slots'];
      if (slots is! List) continue;

      for (final slot in slots.whereType<Map>()) {
        final detailId = slot['court_detail_id']?.toString();
        final start = slot['start_time']?.toString();
        final end = slot['end_time']?.toString();
        if (detailId == null || start == null || end == null) continue;

        var minutes = _minutesSinceMidnight(start);
        final endMinutes = _minutesSinceMidnight(end);
        while (minutes < endMinutes) {
          final hour = (minutes ~/ 60).toString().padLeft(2, '0');
          final minute = (minutes % 60).toString().padLeft(2, '0');
          result.add({'court_detail_id': detailId, 'time': '$hour:$minute'});
          minutes += 30;
        }
      }
    }
    return result;
  }

  static int _minutesSinceMidnight(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      throw FormatException('Giờ đặt sân không hợp lệ: $time');
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      throw FormatException('Giờ đặt sân không hợp lệ: $time');
    }
    return hour * 60 + minute;
  }
}

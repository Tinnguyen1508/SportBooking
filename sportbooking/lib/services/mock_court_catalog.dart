import 'package:flutter/material.dart';

class MockCourtCatalog {
  static const List<Map<String, dynamic>> sports = [
    {'id': 1, 'name': 'Cầu lông', 'icon': Icons.sports_tennis},
    {'id': 2, 'name': 'Pickleball', 'icon': Icons.sports_handball},
    {'id': 3, 'name': 'Bóng đá', 'icon': Icons.sports_soccer},
    {'id': 4, 'name': 'Tennis', 'icon': Icons.sports_tennis},
    {'id': 5, 'name': 'Bóng rổ', 'icon': Icons.sports_basketball},
    {'id': 6, 'name': 'Bóng chuyền', 'icon': Icons.sports_volleyball},
  ];

  static const List<Map<String, dynamic>> amenities = [
    {'id': 1, 'name': 'Wifi', 'icon_code': 'wifi'},
    {'id': 2, 'name': 'Đỗ ô tô', 'icon_code': 'directions_car'},
    {'id': 3, 'name': 'Căng tin', 'icon_code': 'local_cafe'},
    {'id': 4, 'name': 'Phòng tắm', 'icon_code': 'shower'},
  ];

  static const List<Map<String, dynamic>> courts = [
    {
      'id': 9001,
      'name': 'Sân bóng rổ Quy Nhơn',
      'address': 'TP. Quy Nhơn, Bình Định',
      'latitude': 13.7820,
      'longitude': 109.2190,
      'district_id': 7,
      'sport_id': 5,
      'sport_name': 'Bóng rổ',
      'amenity_ids': [1, 2, 3],
      'amenity_names': ['Wifi', 'Đỗ ô tô', 'Căng tin'],
      'min_price': 180000,
      'cover_image': null,
    },
    {
      'id': 9002,
      'name': 'Sân bóng chuyền trung tâm',
      'address': 'Quận 1, TP. Hồ Chí Minh',
      'latitude': 10.7769,
      'longitude': 106.7009,
      'district_id': 1,
      'sport_id': 6,
      'sport_name': 'Bóng chuyền',
      'amenity_ids': [1, 4],
      'amenity_names': ['Wifi', 'Phòng tắm'],
      'min_price': 120000,
      'cover_image': null,
    },
  ];
}

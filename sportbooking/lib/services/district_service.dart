import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DistrictService {
  DistrictService({http.Client? client, this.useMockData = false})
    : _client = client ?? http.Client();

  final http.Client _client;
  final bool useMockData;

  static String get apiBaseUrl {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'http://localhost:5000/api';
    }
    return 'http://10.0.2.2:5000/api';
  }

  static const List<Map<String, dynamic>> _mockDistricts = [
    {'id': 1, 'name': 'Quận 1', 'province_name': 'TP. Hồ Chí Minh'},
    {'id': 2, 'name': 'Quận 3', 'province_name': 'TP. Hồ Chí Minh'},
    {'id': 3, 'name': 'TP. Thủ Đức', 'province_name': 'TP. Hồ Chí Minh'},
    {'id': 4, 'name': 'Ba Đình', 'province_name': 'Hà Nội'},
    {'id': 5, 'name': 'Cầu Giấy', 'province_name': 'Hà Nội'},
    {'id': 6, 'name': 'Đống Đa', 'province_name': 'Hà Nội'},
    {'id': 7, 'name': 'TP. Quy Nhơn', 'province_name': 'Bình Định'},
    {'id': 8, 'name': 'Tuy Phước', 'province_name': 'Bình Định'},
    {'id': 9, 'name': 'An Nhơn', 'province_name': 'Bình Định'},
  ];

  static const List<String> hoChiMinhDistrictNames = [
    'Quận 1',
    'Quận 3',
    'Quận 4',
    'Quận 5',
    'Quận 6',
    'Quận 7',
    'Quận 8',
    'Quận 10',
    'Quận 11',
    'Quận 12',
    'TP. Thủ Đức',
    'Bình Tân',
    'Bình Thạnh',
    'Bình Chánh',
    'Cần Giờ',
    'Củ Chi',
    'Gò Vấp',
    'Hóc Môn',
    'Nhà Bè',
    'Phú Nhuận',
    'Tân Bình',
    'Tân Phú',
  ];

  static List<Map<String, dynamic>> withHoChiMinhDistricts(
    List<Map<String, dynamic>> districts,
  ) {
    final merged = districts
        .map((district) => Map<String, dynamic>.from(district))
        .toList();
    final existingNames = merged
        .where(
          (district) =>
              district['province_name'].toString().trim().toLowerCase() ==
              'tp. hồ chí minh',
        )
        .map((district) => district['name'].toString().trim().toLowerCase())
        .toSet();

    for (var index = 0; index < hoChiMinhDistrictNames.length; index++) {
      final name = hoChiMinhDistrictNames[index];
      if (existingNames.contains(name.toLowerCase())) continue;
      merged.add({
        'id': -(index + 1),
        'name': name,
        'province_name': 'TP. Hồ Chí Minh',
        'is_local_fallback': true,
      });
    }
    return merged;
  }

  static bool provinceMatchesSearch(String province, String query) {
    final normalizedQuery = _normalizeVietnamese(query);
    if (normalizedQuery.isEmpty) return true;

    final aliases = province == 'TP. Hồ Chí Minh'
        ? [province, 'Thành phố Hồ Chí Minh', 'Sài Gòn']
        : [province];
    return aliases.any(
      (alias) => _normalizeVietnamese(alias).contains(normalizedQuery),
    );
  }

  static String _normalizeVietnamese(String value) {
    var normalized = value.toLowerCase().replaceAll('đ', 'd');
    const replacements = {
      'a': 'áàảãạăắằẳẵặâấầẩẫậ',
      'e': 'éèẻẽẹêếềểễệ',
      'i': 'íìỉĩị',
      'o': 'óòỏõọôốồổỗộơớờởỡợ',
      'u': 'úùủũụưứừửữự',
      'y': 'ýỳỷỹỵ',
    };
    replacements.forEach((plain, accented) {
      for (final character in accented.split('')) {
        normalized = normalized.replaceAll(character, plain);
      }
    });
    return normalized;
  }

  static const List<String> vietnamProvinceNames = [
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

  void close() => _client.close();

  Future<List<Map<String, dynamic>>> getDistricts() async {
    if (useMockData) {
      return withHoChiMinhDistricts(_mockDistricts);
    }

    final response = await _client
        .get(Uri.parse('$apiBaseUrl/districts'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Không tải được danh sách khu vực (HTTP ${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    final dynamic payload = decoded is Map<String, dynamic>
        ? decoded['data']
        : decoded;
    if (payload is! List) {
      throw const FormatException('API districts phải trả về một danh sách.');
    }

    final loadedDistricts = payload.map<Map<String, dynamic>>((item) {
      if (item is! Map) {
        throw const FormatException('Dữ liệu khu vực không hợp lệ.');
      }

      final district = Map<String, dynamic>.from(item);
      final id = district['id'];
      final name = district['name'] ?? district['district_name'];
      final provinceName = district['province_name'];
      if (id == null || name == null || provinceName == null) {
        throw const FormatException(
          'Mỗi khu vực cần có id, name và province_name.',
        );
      }

      return {
        'id': id is num ? id.toInt() : int.parse(id.toString()),
        'name': name.toString(),
        'province_name': provinceName.toString(),
      };
    }).toList();
    return withHoChiMinhDistricts(loadedDistricts);
  }
}

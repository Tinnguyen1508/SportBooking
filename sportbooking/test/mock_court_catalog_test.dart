import 'package:flutter_test/flutter_test.dart';
import 'package:sportbooking/services/court_distance.dart';
import 'package:sportbooking/services/district_service.dart';
import 'package:sportbooking/services/mock_court_catalog.dart';

void main() {
  test('mock catalog includes basketball, volleyball and two test courts', () {
    final sportNames = MockCourtCatalog.sports
        .map((sport) => sport['name'])
        .toSet();

    expect(sportNames, contains('Bóng rổ'));
    expect(sportNames, contains('Bóng chuyền'));
    expect(MockCourtCatalog.courts, hasLength(2));
  });

  test('mock court sport and amenity references exist in the catalogs', () {
    final sportNames = MockCourtCatalog.sports
        .map((sport) => sport['name'])
        .toSet();
    final amenityIds = MockCourtCatalog.amenities
        .map((amenity) => amenity['id'])
        .toSet();

    for (final court in MockCourtCatalog.courts) {
      expect(sportNames, contains(court['sport_name']));
      expect(
        (court['amenity_ids'] as List<dynamic>).every(amenityIds.contains),
        isTrue,
      );
    }
  });

  test('nearby filtering excludes courts outside five kilometers', () {
    final location = {'latitude': 10.7769, 'longitude': 106.7009};
    final hcmCourt = MockCourtCatalog.courts.last;
    final quyNhonCourt = MockCourtCatalog.courts.first;

    expect(
      CourtDistance.isWithinNearbyRadius(
        court: hcmCourt,
        latitude: location['latitude']!,
        longitude: location['longitude']!,
      ),
      isTrue,
    );
    expect(
      CourtDistance.isWithinNearbyRadius(
        court: quyNhonCourt,
        latitude: location['latitude']!,
        longitude: location['longitude']!,
      ),
      isFalse,
    );
  });

  test('courts without coordinates are excluded from nearby results', () {
    expect(
      CourtDistance.isWithinNearbyRadius(
        court: const {'name': 'Sân chưa có tọa độ'},
        latitude: 10.7769,
        longitude: 106.7009,
      ),
      isFalse,
    );
  });

  test('nearby radius includes courts within 5 km only', () {
    expect(
      CourtDistance.isWithinNearbyRadius(
        court: const {'latitude': 10.8169, 'longitude': 106.7009},
        latitude: 10.7769,
        longitude: 106.7009,
      ),
      isTrue,
    );
    expect(
      CourtDistance.isWithinNearbyRadius(
        court: const {'latitude': 10.8269, 'longitude': 106.7009},
        latitude: 10.7769,
        longitude: 106.7009,
      ),
      isFalse,
    );
  });

  test(
    'province picker has the full legacy Vietnam province and city list',
    () {
      expect(DistrictService.vietnamProvinceNames, hasLength(63));
      expect(DistrictService.vietnamProvinceNames, contains('Bình Định'));
      expect(DistrictService.vietnamProvinceNames, contains('Hà Nội'));
      expect(DistrictService.vietnamProvinceNames, contains('TP. Hồ Chí Minh'));
    },
  );

  test('district picker includes all 22 Ho Chi Minh City districts', () {
    final districts = DistrictService.withHoChiMinhDistricts(const []);
    final hoChiMinhDistricts = districts
        .where((district) => district['province_name'] == 'TP. Hồ Chí Minh')
        .toList();
    final names = hoChiMinhDistricts
        .map((district) => district['name'])
        .toSet();

    expect(hoChiMinhDistricts, hasLength(22));
    expect(names, contains('Quận 1'));
    expect(names, contains('TP. Thủ Đức'));
    expect(names, contains('Củ Chi'));
    expect(names, contains('Cần Giờ'));
    expect(
      hoChiMinhDistricts.every((district) => district['id'] is int),
      isTrue,
    );
  });

  test('province search matches the full city name with unaccented typing', () {
    expect(
      DistrictService.provinceMatchesSearch(
        'TP. Hồ Chí Minh',
        'thanh pho ho chi minh',
      ),
      isTrue,
    );
    expect(
      DistrictService.provinceMatchesSearch('TP. Hồ Chí Minh', 'ho chi minh'),
      isTrue,
    );
    expect(
      DistrictService.provinceMatchesSearch('TP. Hồ Chí Minh', 'da nang'),
      isFalse,
    );
  });
}

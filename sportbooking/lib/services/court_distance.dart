import 'dart:math' as math;

class CourtDistance {
  static const double nearbyRadiusKm = 5;

  static bool isWithinNearbyRadius({
    required Map<String, dynamic> court,
    required double latitude,
    required double longitude,
  }) {
    final courtLatitude = _coordinate(court, const [
      'latitude',
      'lat',
      'court_latitude',
    ]);
    final courtLongitude = _coordinate(court, const [
      'longitude',
      'lng',
      'court_longitude',
    ]);
    if (courtLatitude == null || courtLongitude == null) return false;

    return _distanceInKm(latitude, longitude, courtLatitude, courtLongitude) <=
        nearbyRadiusKm;
  }

  static double? _coordinate(Map<String, dynamic> court, List<String> keys) {
    for (final key in keys) {
      final value = court[key];
      final coordinate = value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '');
      if (coordinate != null && coordinate.isFinite) return coordinate;
    }
    return null;
  }

  static double _distanceInKm(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadiusKm = 6371.0088;
    final latitudeDifference = _toRadians(latitude2 - latitude1);
    final longitudeDifference = _toRadians(longitude2 - longitude1);
    final haversine =
        math.pow(math.sin(latitudeDifference / 2), 2) +
        math.cos(_toRadians(latitude1)) *
            math.cos(_toRadians(latitude2)) *
            math.pow(math.sin(longitudeDifference / 2), 2);

    return earthRadiusKm * 2 * math.asin(math.sqrt(haversine));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

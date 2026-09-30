import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalBookingStore {
  static const String _storageKey = 'local_mock_bookings';

  static bool isSlotBooked({
    required List<Map<String, dynamic>> bookings,
    required int courtId,
    required int courtDetailId,
    required String date,
    required String startTime,
  }) {
    return bookings.any((booking) {
      if (booking['status'] == 'CANCELLED' ||
          booking['court_id']?.toString() != courtId.toString()) {
        return false;
      }

      final slots = booking['selected_slots'];
      if (slots is! List) return false;
      return slots.any((slot) {
        if (slot is! Map) return false;
        return slot['booking_date'] == date &&
            slot['court_detail_id']?.toString() == courtDetailId.toString() &&
            slot['start_time'] == startTime;
      });
    });
  }

  static Future<List<Map<String, dynamic>>> getBookings() async {
    final preferences = await SharedPreferences.getInstance();
    final storedBookings = preferences.getStringList(_storageKey) ?? [];
    return storedBookings.map<Map<String, dynamic>>((bookingJson) {
      final decoded = jsonDecode(bookingJson);
      if (decoded is! Map) {
        throw const FormatException('Dữ liệu lịch đặt đã lưu không hợp lệ.');
      }
      return Map<String, dynamic>.from(decoded);
    }).toList();
  }

  static Future<void> addBooking(Map<String, dynamic> booking) async {
    final preferences = await SharedPreferences.getInstance();
    final storedBookings = preferences.getStringList(_storageKey) ?? [];
    final bookingCode = booking['booking_code']?.toString();
    final updatedBookings = storedBookings
        .map<Map<String, dynamic>>((bookingJson) {
          final decoded = jsonDecode(bookingJson);
          if (decoded is! Map) {
            throw const FormatException(
              'Dữ liệu lịch đặt đã lưu không hợp lệ.',
            );
          }
          return Map<String, dynamic>.from(decoded);
        })
        .where(
          (savedBooking) =>
              savedBooking['booking_code']?.toString() != bookingCode,
        )
        .toList();

    updatedBookings.insert(0, Map<String, dynamic>.from(booking));
    await preferences.setStringList(
      _storageKey,
      updatedBookings.map(jsonEncode).toList(),
    );
  }

  static Future<void> cancelBooking(
    Map<String, dynamic> booking, {
    required String reason,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final storedBookings = preferences.getStringList(_storageKey) ?? [];
    final bookingCode = booking['booking_code']?.toString();
    final bookingId = (booking['id'] ?? booking['booking_id'])?.toString();
    var foundBooking = false;
    final updatedBookings = storedBookings.map<String>((bookingJson) {
      final decoded = jsonDecode(bookingJson);
      if (decoded is! Map) {
        throw const FormatException('Dữ liệu lịch đặt đã lưu không hợp lệ.');
      }
      final savedBooking = Map<String, dynamic>.from(decoded);
      final savedCode = savedBooking['booking_code']?.toString();
      final savedId = (savedBooking['id'] ?? savedBooking['booking_id'])
          ?.toString();
      final matches =
          (bookingCode != null &&
              bookingCode.isNotEmpty &&
              savedCode == bookingCode) ||
          (bookingId != null && bookingId.isNotEmpty && savedId == bookingId);
      if (matches) {
        foundBooking = true;
        savedBooking['status'] = 'CANCELLED';
        savedBooking['cancellation_reason'] = reason;
      }
      return jsonEncode(savedBooking);
    }).toList();

    if (!foundBooking) {
      final cancelledBooking = Map<String, dynamic>.from(booking)
        ..['status'] = 'CANCELLED'
        ..['cancellation_reason'] = reason;
      updatedBookings.insert(0, jsonEncode(cancelledBooking));
    }

    await preferences.setStringList(_storageKey, updatedBookings);
  }
}

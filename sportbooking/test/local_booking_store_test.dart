import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportbooking/services/local_booking_store.dart';

void main() {
  final booking = <String, dynamic>{
    'court_id': 17,
    'status': 'CONFIRMED',
    'selected_slots': [
      {
        'court_detail_id': 101,
        'booking_date': '2026-10-01',
        'start_time': '18:00',
      },
      {
        'court_detail_id': 101,
        'booking_date': '2026-10-01',
        'start_time': '18:30',
      },
    ],
  };

  test(
    'confirmed slot is blocked only for same court, date and court detail',
    () {
      expect(
        LocalBookingStore.isSlotBooked(
          bookings: [booking],
          courtId: 17,
          courtDetailId: 101,
          date: '2026-10-01',
          startTime: '18:00',
        ),
        isTrue,
      );
      expect(
        LocalBookingStore.isSlotBooked(
          bookings: [booking],
          courtId: 17,
          courtDetailId: 101,
          date: '2026-10-02',
          startTime: '18:00',
        ),
        isFalse,
      );
      expect(
        LocalBookingStore.isSlotBooked(
          bookings: [booking],
          courtId: 18,
          courtDetailId: 101,
          date: '2026-10-01',
          startTime: '18:00',
        ),
        isFalse,
      );
    },
  );

  test('cancelled booking does not block its former time slot', () {
    final cancelledBooking = {...booking, 'status': 'CANCELLED'};

    expect(
      LocalBookingStore.isSlotBooked(
        bookings: [cancelledBooking],
        courtId: 17,
        courtDetailId: 101,
        date: '2026-10-01',
        startTime: '18:00',
      ),
      isFalse,
    );
  });

  test('booking details persist locally and can be loaded again', () async {
    SharedPreferences.setMockInitialValues({});

    await LocalBookingStore.addBooking({
      'booking_code': 'BK-TEST-1',
      'court_id': 17,
      'court_name': 'Sân kiểm thử',
      'booking_date': '2026-10-01',
      'status': 'CONFIRMED',
      'selected_slots': booking['selected_slots'],
    });

    final savedBookings = await LocalBookingStore.getBookings();
    expect(savedBookings, hasLength(1));
    expect(savedBookings.single['booking_code'], 'BK-TEST-1');
    expect(savedBookings.single['selected_slots'], hasLength(2));
  });

  test(
    'cancelling a booking persists cancelled state and releases its slots',
    () async {
      SharedPreferences.setMockInitialValues({});
      final savedBooking = {
        ...booking,
        'booking_code': 'BK-TEST-CANCEL',
        'court_name': 'Sân kiểm thử',
      };
      await LocalBookingStore.addBooking(savedBooking);

      await LocalBookingStore.cancelBooking(
        savedBooking,
        reason: 'Người dùng hủy',
      );

      final bookings = await LocalBookingStore.getBookings();
      expect(bookings.single['status'], 'CANCELLED');
      expect(bookings.single['cancellation_reason'], 'Người dùng hủy');
      expect(
        LocalBookingStore.isSlotBooked(
          bookings: bookings,
          courtId: 17,
          courtDetailId: 101,
          date: '2026-10-01',
          startTime: '18:00',
        ),
        isFalse,
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'review_screen.dart';

class PaymentResultScreen extends StatelessWidget {
  final String bookingCode;
  final int totalAmount;
  final String courtName;
  final String courtType;
  final String courtDetail;
  final String date;
  final String time;
  final int courtPrice;
  final String serviceText;

  const PaymentResultScreen({
    super.key,
    required this.bookingCode,
    required this.totalAmount,
    required this.courtName,
    required this.courtType,
    required this.courtDetail,
    required this.date,
    required this.time,
    required this.courtPrice,
    required this.serviceText,
  });

  static const Color primaryColor =
      Color(0xFF6C4ED9);

  static const Color backgroundColor =
      Color(0xFFF7F7FB);

  static const Color textColor =
      Color(0xFF25232A);

  static const Color greyText =
      Color(0xFF7A7780);

  static const Color borderColor =
      Color(0xFFE5E3E8);

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        )}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildSuccessIcon(),
              const SizedBox(height: 20),
              const Text(
                'Đặt sân thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thông tin đặt sân của bạn đã được ghi nhận.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: greyText,
                ),
              ),
              const SizedBox(height: 30),
              _buildBookingInfo(),
              const SizedBox(height: 30),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F7EE),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 55,
        color: Colors.green,
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết đặt sân',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          _infoRow(
            Icons.confirmation_number_outlined,
            'Mã đặt sân',
            bookingCode,
          ),
          _infoRow(
            Icons.sports,
            'Tên sân',
            courtName,
          ),
          _infoRow(
            Icons.category_outlined,
            'Loại sân',
            courtType,
          ),
          _infoRow(
            Icons.looks_one_outlined,
            'Sân',
            courtDetail,
          ),
          _infoRow(
            Icons.calendar_month,
            'Ngày',
            date,
          ),
          _infoRow(
            Icons.access_time,
            'Thời gian',
            time,
          ),
          _infoRow(
            Icons.attach_money,
            'Giá sân',
            formatMoney(courtPrice),
          ),
          _infoRow(
            Icons.room_service_outlined,
            'Dịch vụ',
            serviceText,
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                formatMoney(totalAmount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: const TextStyle(
                color: greyText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ReviewScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Đánh giá sân',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(
                color: primaryColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Về trang chủ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
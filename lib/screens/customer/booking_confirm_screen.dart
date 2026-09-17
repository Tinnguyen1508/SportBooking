import 'package:flutter/material.dart';
import 'payment_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final String courtName;
  final String courtType;
  final String courtDetail;
  final String date;
  final String time;
  final int courtPrice;

  const BookingConfirmScreen({
    super.key,
    required this.courtName,
    required this.courtType,
    required this.courtDetail,
    required this.date,
    required this.time,
    required this.courtPrice,
  });

  @override
  State<BookingConfirmScreen> createState() =>
      _BookingConfirmScreenState();
}

class _BookingConfirmScreenState
    extends State<BookingConfirmScreen> {
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  final List<Map<String, dynamic>> services = [
    {
      'name': 'Nước suối',
      'price': 10000,
    },
    {
      'name': 'Khăn lạnh',
      'price': 5000,
    },
    {
      'name': 'Thuê vợt',
      'price': 30000,
    },
    {
      'name': 'Thuê bóng',
      'price': 20000,
    },
  ];

  final Set<int> selectedServices = {};

  int get serviceTotal {
    int total = 0;

    for (final index in selectedServices) {
      total += services[index]['price'] as int;
    }

    return total;
  }

  int get totalAmount {
    return widget.courtPrice + serviceTotal;
  }

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        )}đ';
  }

  String get selectedServiceText {
    if (selectedServices.isEmpty) {
      return 'Không sử dụng dịch vụ';
    }

    return selectedServices
        .map((index) => services[index]['name'] as String)
        .join(', ');
  }

  void _goToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          totalBill: totalAmount,
          bookingCode: 'BOOK001',
          courtName: widget.courtName,
          courtType: widget.courtType,
          courtDetail: widget.courtDetail,
          date: widget.date,
          time: widget.time,
          courtPrice: widget.courtPrice,
          serviceText: selectedServiceText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
          ),
        ),
        title: const Text(
          'Xác nhận đặt sân',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookingInfo(),
              const SizedBox(height: 25),
              _buildServices(),
              const SizedBox(height: 25),
              _buildTotal(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đặt sân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 18),
          _infoRow(
            Icons.sports,
            'Tên sân',
            widget.courtName,
          ),
          _infoRow(
            Icons.category_outlined,
            'Loại sân',
            widget.courtType,
          ),
          _infoRow(
            Icons.confirmation_number_outlined,
            'Sân',
            widget.courtDetail,
          ),
          _infoRow(
            Icons.calendar_month,
            'Ngày',
            widget.date,
          ),
          _infoRow(
            Icons.access_time,
            'Thời gian',
            widget.time,
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
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

  Widget _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ thêm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          services.length,
          (index) {
            final service = services[index];
            final bool selected =
                selectedServices.contains(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? primaryColor
                      : borderColor,
                ),
              ),
              child: CheckboxListTile(
                value: selected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedServices.add(index);
                    } else {
                      selectedServices.remove(index);
                    }
                  });
                },
                activeColor: primaryColor,
                title: Text(
                  service['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  formatMoney(service['price'] as int),
                  style: const TextStyle(
                    color: greyText,
                  ),
                ),
                controlAffinity:
                    ListTileControlAffinity.leading,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          _priceRow(
            'Giá sân',
            widget.courtPrice,
          ),
          const SizedBox(height: 12),
          _priceRow(
            'Dịch vụ',
            serviceTotal,
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
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

  Widget _priceRow(
    String title,
    int amount,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: greyText,
          ),
        ),
        Text(
          formatMoney(amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
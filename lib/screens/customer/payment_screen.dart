import 'package:flutter/material.dart';
import 'payment_result_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int totalBill;
  final String bookingCode;
  final String courtName;
  final String courtType;
  final String courtDetail;
  final String date;
  final String time;
  final int courtPrice;
  final String serviceText;

  const PaymentScreen({
    super.key,
    required this.totalBill,
    required this.bookingCode,
    required this.courtName,
    required this.courtType,
    required this.courtDetail,
    required this.date,
    required this.time,
    required this.courtPrice,
    required this.serviceText,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  String paymentMethod = 'bank';

  final String bankName = 'MB Bank';
  final String bankAccount = '123456789';
  final String accountName = 'SPORT BOOKING';

  String get transferContent {
    return widget.bookingCode;
  }

  int get depositAmount {
    return (widget.totalBill * 0.30).round();
  }

  int get remainingAmount {
    return widget.totalBill - depositAmount;
  }

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        )}đ';
  }

  void _handleConfirm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          bookingCode: widget.bookingCode,
          totalAmount: widget.totalBill,
          courtName: widget.courtName,
          courtType: widget.courtType,
          courtDetail: widget.courtDetail,
          date: widget.date,
          time: widget.time,
          courtPrice: widget.courtPrice,
          serviceText: widget.serviceText,
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
          'Thanh toán',
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildBookingSummary(),
              const SizedBox(height: 25),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildPaymentMethod(),
              const SizedBox(height: 25),
              if (paymentMethod == 'bank')
                _buildBankPayment(),
              if (paymentMethod == 'cash')
                _buildCashPayment(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận thanh toán',
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

  Widget _buildBookingSummary() {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn đặt sân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 18),
          _infoRow(
            'Mã đặt sân',
            widget.bookingCode,
          ),
          _infoRow(
            'Tên sân',
            widget.courtName,
          ),
          _infoRow(
            'Loại sân',
            widget.courtType,
          ),
          _infoRow(
            'Sân',
            widget.courtDetail,
          ),
          _infoRow(
            'Ngày',
            widget.date,
          ),
          _infoRow(
            'Thời gian',
            widget.time,
          ),
          _infoRow(
            'Dịch vụ',
            widget.serviceText,
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                formatMoney(widget.totalBill),
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
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
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

  Widget _buildPaymentMethod() {
    return Column(
      children: [
        _paymentOption(
          value: 'bank',
          title: 'Chuyển khoản ngân hàng',
          icon: Icons.account_balance,
        ),
        const SizedBox(height: 10),
        _paymentOption(
          value: 'cash',
          title: 'Thanh toán tại sân',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _paymentOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final bool selected = paymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          paymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? primaryColor
                : borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: paymentMethod,
              activeColor: primaryColor,
              onChanged: (newValue) {
                setState(() {
                  paymentMethod = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankPayment() {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin chuyển khoản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 18),
          _bankRow(
            'Ngân hàng',
            bankName,
          ),
          _bankRow(
            'Số tài khoản',
            bankAccount,
          ),
          _bankRow(
            'Chủ tài khoản',
            accountName,
          ),
          _bankRow(
            'Nội dung',
            transferContent,
          ),
          const Divider(height: 25),
          _bankRow(
            'Tiền cọc 30%',
            formatMoney(depositAmount),
          ),
          _bankRow(
            'Còn lại 70%',
            formatMoney(remainingAmount),
          ),
        ],
      ),
    );
  }

  Widget _buildCashPayment() {
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
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: primaryColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn sẽ thanh toán trực tiếp tại sân '
              'khi đến sử dụng dịch vụ.',
              style: TextStyle(
                color: greyText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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
}
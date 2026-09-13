import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  // bank = chuyển khoản
  // cash = tiền mặt
  String _paymentMethod = 'bank';

  // Dữ liệu giả frontend
  final int totalBill = 300000;

  // Thông tin ngân hàng
  final String bankName = 'MB Bank';
  final String bankAccount = '123456789';
  final String accountName = 'SPORT BOOKING';
  final String transferContent = 'BOOK001';

  // Cọc 30%
  int get depositAmount {
    return (totalBill * 0.30).round();
  }

  // Còn lại 70%
  int get remainingAmount {
    return totalBill - depositAmount;
  }

  String formatMoney(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(text[i]);
    }

    return '${buffer.toString()}đ';
  }

  void _handleConfirm() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 58,
          ),
          title: Text(
            _paymentMethod == 'bank'
                ? 'Đã ghi nhận chuyển khoản'
                : 'Xác nhận thanh toán',
            textAlign: TextAlign.center,
          ),
          content: Text(
            _paymentMethod == 'bank'
                ? 'Frontend đã ghi nhận yêu cầu chuyển khoản của bạn.'
                : 'Bạn sẽ thanh toán ${formatMoney(remainingAmount)} bằng tiền mặt tại sân.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _paymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = _paymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primaryColor : borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: greyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    bool highlight = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: greyText,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 15,
              fontWeight:
                  highlight ? FontWeight.bold : FontWeight.w600,
              color: valueColor ??
                  (highlight ? primaryColor : textColor),
            ),
          ),
        ],
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
          onPressed: () {
            Navigator.pop(context);
          },
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================================
                  // CHI TIẾT THANH TOÁN
                  // =========================================
                  const Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          'Tổng bill',
                          formatMoney(totalBill),
                        ),

                        _infoRow(
                          'Đã cọc (30%)',
                          '-${formatMoney(depositAmount)}',
                          valueColor: Colors.green,
                        ),

                        const Divider(height: 30),

                        _infoRow(
                          'Còn phải thanh toán',
                          formatMoney(remainingAmount),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================================
                  // PHƯƠNG THỨC
                  // =========================================
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _paymentOption(
                    value: 'bank',
                    title: 'Chuyển khoản ngân hàng',
                    subtitle: 'Quét mã QR để thanh toán',
                    icon: Icons.account_balance_outlined,
                  ),

                  _paymentOption(
                    value: 'cash',
                    title: 'Tiền mặt',
                    subtitle: 'Thanh toán trực tiếp khi đến sân',
                    icon: Icons.payments_outlined,
                  ),

                  // =========================================
                  // QR
                  // =========================================
                  if (_paymentMethod == 'bank') ...[
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Quét QR để thanh toán',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: 220,
                            height: 220,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/qr_payment.png',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 20),

                          _infoRow(
                            'Ngân hàng',
                            bankName,
                          ),

                          _infoRow(
                            'Số tài khoản',
                            bankAccount,
                          ),

                          _infoRow(
                            'Chủ tài khoản',
                            accountName,
                          ),

                          _infoRow(
                            'Số tiền',
                            formatMoney(remainingAmount),
                            highlight: true,
                          ),

                          _infoRow(
                            'Nội dung',
                            transferContent,
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Vui lòng chuyển đúng số tiền và nội dung.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF8A6116),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // =========================================
                  // TIỀN MẶT
                  // =========================================
                  if (_paymentMethod == 'cash') ...[
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: primaryColor,
                            size: 50,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Thanh toán tại sân',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Bạn sẽ thanh toán ${formatMoney(remainingAmount)} khi đến sân.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _paymentMethod == 'bank'
                            ? 'Tôi đã chuyển khoản'
                            : 'Xác nhận thanh toán tiền mặt',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
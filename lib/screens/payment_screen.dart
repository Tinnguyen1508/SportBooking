import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount;
  final String bookingCode;

  const PaymentScreen({
    super.key,
    this.bookingId = 1,
    this.amount = 300000.0,
    this.bookingCode = 'BK99212',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  String _paymentMethod = 'VIETQR';

  // Tự động chuyển đổi ảnh QR tương ứng với phương thức thanh toán
  String get _qrImagePath {
    if (_paymentMethod == 'MOMO') {
      return 'assets/images/momo_qr.png';
    }
    return 'assets/images/my_qr.png';
  }

  String formatMoney(double value) {
    return '${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  void _handleConfirm() {
    final paymentData = {
      'booking_id': widget.bookingId,
      'amount': widget.amount,
      'payment_method': _paymentMethod,
      'status': _paymentMethod == 'CASH' ? 'PENDING' : 'SUCCESS',
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 58),
          title: const Text('Ghi nhận thanh toán', textAlign: TextAlign.center),
          content: Text(
            _paymentMethod == 'CASH'
                ? 'Bạn sẽ thanh toán ${formatMoney(widget.amount)} bằng tiền mặt tại sân.'
                : 'Hệ thống đang xác nhận giao dịch chuyển khoản cho đơn ${widget.bookingCode}.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, paymentData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hoàn tất'),
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
      onTap: () => setState(() => _paymentMethod = value),
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
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: greyText)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: greyText, fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 17 : 15,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? primaryColor : textColor,
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
        title: const Text('Thanh toán', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _infoRow('Mã đơn hàng', widget.bookingCode),
                    const Divider(height: 20),
                    _infoRow('Tổng tiền thanh toán', formatMoney(widget.amount), highlight: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 14),

              _paymentOption(
                value: 'VIETQR',
                title: 'Thanh toán VietQR',
                subtitle: 'Quét mã QR Ngân hàng',
                icon: Icons.qr_code_2,
              ),
              _paymentOption(
                value: 'MOMO',
                title: 'Ví MoMo',
                subtitle: 'Quét mã QR Ví MoMo',
                icon: Icons.account_balance_wallet_outlined,
              ),
              _paymentOption(
                value: 'CASH',
                title: 'Tiền mặt',
                subtitle: 'Thanh toán trực tiếp khi đến sân',
                icon: Icons.payments_outlined,
              ),

              const SizedBox(height: 16),

              if (_paymentMethod == 'VIETQR' || _paymentMethod == 'MOMO') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Quét mã QR để thanh toán ($_paymentMethod)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _qrImagePath,
                          width: 260,
                          height: 260,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: const Color(0xFFF2EFFF),
                              child: Center(
                                child: Text(
                                  'Không thể tải file $_qrImagePath\nVui lòng kiểm tra file ảnh trong assets.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                      _infoRow('Nội dung chuyển khoản', widget.bookingCode),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _paymentMethod == 'CASH' ? 'Xác nhận thanh toán tiền mặt' : 'Tôi đã chuyển khoản',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

// Model ánh xạ theo đúng thiết kế CSDL Bảng `services`
class ServiceModel {
  final int id;
  final int courtId;
  final String name;
  final double price; // Giá bán lẻ
  final double costPrice; // Giá vốn nhập hàng
  final String unit; // Đơn vị tính
  final String imagePath; // Ảnh từ assets
  int stockQuantity; // Số lượng tồn kho
  int soldQuantity; // Số lượng đã bán
  bool isActive; // Trạng thái kinh doanh

  ServiceModel({
    required this.id,
    required this.courtId,
    required this.name,
    required this.price,
    required this.costPrice,
    required this.unit,
    required this.imagePath,
    required this.stockQuantity,
    required this.soldQuantity,
    this.isActive = true,
  });
}

class OwnerShopScreen extends StatefulWidget {
  const OwnerShopScreen({super.key});

  @override
  State<OwnerShopScreen> createState() => _OwnerShopScreenState();
}

class _OwnerShopScreenState extends State<OwnerShopScreen> {
  // Danh sách dịch vụ giả lập theo CSDL và Assets thực tế
  final List<ServiceModel> servicesList = [
    ServiceModel(
      id: 1,
      courtId: 101,
      name: 'Nước Revive Chanh Muối',
      price: 15000,
      costPrice: 8000,
      unit: 'Chai',
      imagePath: 'assets/images/revive chanh.jpg',
      stockQuantity: 48,
      soldQuantity: 120,
    ),
    ServiceModel(
      id: 2,
      courtId: 101,
      name: 'Nước Revive Thường',
      price: 15000,
      costPrice: 8000,
      unit: 'Chai',
      imagePath: 'assets/images/revive thuong.jpg',
      stockQuantity: 32,
      soldQuantity: 95,
    ),
    ServiceModel(
      id: 3,
      courtId: 101,
      name: 'Ống Cầu VinaStar 1',
      price: 240000,
      costPrice: 210000,
      unit: 'Ống',
      imagePath: 'assets/images/vinastar1.jpg',
      stockQuantity: 15,
      soldQuantity: 42,
    ),
    ServiceModel(
      id: 4,
      courtId: 101,
      name: 'Khăn Mặt Thể Thao',
      price: 35000,
      costPrice: 18000,
      unit: 'Cái',
      imagePath: 'assets/images/khan mat.jpg',
      stockQuantity: 20,
      soldQuantity: 18,
    ),
  ];

  // Giỏ hàng bán tại quầy {service_id: quantity}
  final Map<int, int> cart = {};

  void _addToCart(ServiceModel service) {
    if (service.stockQuantity <= 0) {
      _showSnackBar('Mặt hàng đã hết trong kho!', isError: true);
      return;
    }
    setState(() {
      int currentInCart = cart[service.id] ?? 0;
      if (currentInCart < service.stockQuantity) {
        cart[service.id] = currentInCart + 1;
      } else {
        _showSnackBar('Đã đạt giới hạn tồn kho khả dụng!', isError: true);
      }
    });
  }

  void _removeFromCart(int serviceId) {
    setState(() {
      if (cart.containsKey(serviceId)) {
        if (cart[serviceId]! > 1) {
          cart[serviceId] = cart[serviceId]! - 1;
        } else {
          cart.remove(serviceId);
        }
      }
    });
  }

  // Mở Hộp thoại Chọn Phương thức Thanh toán
  void _checkout() {
    if (cart.isEmpty) {
      _showSnackBar('Giỏ hàng trống!', isError: true);
      return;
    }

    String selectedMethod = 'cash'; // Mặc định chọn Tiền mặt ('cash' hoặc 'qr')

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.payments, color: Color(0xFF0D5C40)),
                  SizedBox(width: 8),
                  Text('Xác nhận thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D5C40).withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng tiền thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              _formatPrice(_calculateTotal()),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D5C40)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Hình thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(height: 8),

                      // TÙY CHỌN 1: TIỀN MẶT
                      Card(
                        elevation: 0,
                        color: selectedMethod == 'cash' ? Colors.green[50] : Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: selectedMethod == 'cash' ? const Color(0xFF0D5C40) : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: 'cash',
                          groupValue: selectedMethod,
                          activeColor: const Color(0xFF0D5C40),
                          title: const Text('Tiền mặt tại quầy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text('Thu tiền trực tiếp từ khách hàng'),
                          secondary: const Icon(Icons.money, color: Colors.green),
                          onChanged: (value) => setDialogState(() => selectedMethod = value!),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // TÙY CHỌN 2: CHUYỂN KHOẢN QR
                      Card(
                        elevation: 0,
                        color: selectedMethod == 'qr' ? Colors.green[50] : Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: selectedMethod == 'qr' ? const Color(0xFF0D5C40) : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: 'qr',
                          groupValue: selectedMethod,
                          activeColor: const Color(0xFF0D5C40),
                          title: const Text('Chuyển khoản qua QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: const Text('Quét mã QR ngân hàng/Momo'),
                          secondary: const Icon(Icons.qr_code_2, color: Colors.blue),
                          onChanged: (value) => setDialogState(() => selectedMethod = value!),
                        ),
                      ),

                      // HIỂN THỊ MÃ QR KHI CHỌN CHUYỂN KHOẢN
                      if (selectedMethod == 'qr') ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text('Quét mã bên dưới để thanh toán:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                            child: Image.asset(
                              'assets/images/qr_payment.png',
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/qr_payment.jpg',
                                  height: 220,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, e, s) => Container(
                                    height: 180,
                                    width: 180,
                                    color: Colors.grey[200],
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_scanner, size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Không tìm thấy ảnh qr_payment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C40),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _processPaymentSuccess(
                      selectedMethod == 'cash' ? 'Tiền mặt' : 'Chuyển khoản QR',
                    );
                  },
                  child: Text(
                    selectedMethod == 'cash' ? 'Xác nhận thanh toán' : 'Xác nhận đã nhận tiền',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Cập nhật tồn kho & thông báo sau khi hoàn tất thanh toán
  void _processPaymentSuccess(String method) {
    setState(() {
      cart.forEach((serviceId, quantity) {
        final item = servicesList.firstWhere((element) => element.id == serviceId);
        item.stockQuantity -= quantity;
        item.soldQuantity += quantity;
      });
      cart.clear();
    });

    _showSnackBar(
      'Thanh toán ($method) thành công! Đã cập nhật tồn kho & số lượng bán.',
      isError: false,
    );
  }

  double _calculateTotal() {
    double total = 0;
    cart.forEach((serviceId, quantity) {
      final item = servicesList.firstWhere((e) => e.id == serviceId);
      total += item.price * quantity;
    });
    return total;
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Bán hàng tại quầy & Quản lý Kho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0D5C40),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới kho',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Row(
        children: [
          // DANH SÁCH MẶT HÀNG / KHO
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh mục dịch vụ & Hàng hóa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: servicesList.length,
                      itemBuilder: (context, index) {
                        final item = servicesList[index];
                        return _buildProductCard(item);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GIỎ HÀNG THANH TOÁN TẠI QUẦY
          Container(
            width: 340,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  color: Colors.grey[200],
                  width: double.infinity,
                  child: const Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Color(0xFF0D5C40)),
                      SizedBox(width: 8),
                      Text('Đơn hàng tại quầy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text('Chưa có sản phẩm nào được chọn', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: cart.entries.map((entry) {
                            final item = servicesList.firstWhere((e) => e.id == entry.key);
                            final qty = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(
                                          '${_formatPrice(item.price)} x $qty = ${_formatPrice(item.price * qty)}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                        onPressed: () => _removeFromCart(item.id),
                                      ),
                                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                        onPressed: () => _addToCart(item),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, -2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng tiền:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(
                            _formatPrice(_calculateTotal()),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D5C40)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D5C40),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _checkout,
                          child: const Text('Thanh toán tại quầy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductCard(ServiceModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Giá bán: ${_formatPrice(item.price)} / ${item.unit}',
                    style: const TextStyle(color: Color(0xFF0D5C40), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    'Giá vốn: ${_formatPrice(item.costPrice)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          'Đã bán: ${item.soldQuantity}',
                          style: TextStyle(fontSize: 10, color: Colors.blue[800], fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.stockQuantity > 0 ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: item.stockQuantity > 0 ? Colors.green[200]! : Colors.red[200]!),
                        ),
                        child: Text(
                          'Tồn kho: ${item.stockQuantity}',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.stockQuantity > 0 ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF0D5C40)),
              onPressed: () => _addToCart(item),
            )
          ],
        ),
      ),
    );
  }

  // Phương thức định dạng tiền tệ đơn giản chuẩn Dart
  String _formatPrice(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }
}
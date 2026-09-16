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
  int soldQuantity; // Số lượng đã bán (Giả lập)
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

  void _checkout() {
    if (cart.isEmpty) {
      _showSnackBar('Giỏ hàng trống!', isError: true);
      return;
    }

    setState(() {
      cart.forEach((serviceId, quantity) {
        final item = servicesList.firstWhere((element) => element.id == serviceId);
        item.stockQuantity -= quantity;
        item.soldQuantity += quantity;
      });
      cart.clear();
    });

    _showSnackBar('Thanh toán thành công! Đã cập nhật tồn kho & số lượng bán.', isError: false);
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
        duration: const Duration(seconds: 2),
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
                        childAspectRatio: 1.25,
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
            // CỘT HÌNH ẢNH
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imagePath,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 75,
                  height: 75,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // CỘT THÔNG TIN MẶT HÀNG (Ánh xạ từ CSDL)
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
                    style: const TextStyle(color: Color(0xFF0D5C40), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Giá vốn: ${_formatPrice(item.costPrice)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
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
                          style: TextStyle(fontSize: 11, color: Colors.blue[800], fontWeight: FontWeight.bold),
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
                            fontSize: 11,
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

            // NÚT CHỌN MUA
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF0D5C40)),
              onPressed: () => _addToCart(item),
            )
          ],
        ),
      ),
    );
  }

  String _formatPrice(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllRegExp(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1.')} đ';
  }
}

extension StringRegExtension on String {
  String replaceAllRegExp(RegExp regex, String replacement) {
    return replaceAllMapped(regex, (match) => '${match[1]}.');
  }
}
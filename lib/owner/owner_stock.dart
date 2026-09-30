import 'package:flutter/material.dart';

// Model dữ liệu tương thích 100% với SQL
class ProductItem {
  final String id;
  final String name;
  final String category;
  final double sellingPrice;
  final double costPrice;
  final String unit;
  final int soldQuantity;
  final int stockQuantity;
  final String imageUrl;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sellingPrice,
    required this.costPrice,
    required this.unit,
    required this.soldQuantity,
    required this.stockQuantity,
    required this.imageUrl,
  });

  // Chuyển đổi từ JSON SQL
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Khác',
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'Cái',
      soldQuantity: json['sold_quantity'] ?? 0,
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class OwnerStockScreen extends StatefulWidget {
  const OwnerStockScreen({super.key});

  @override
  State<OwnerStockScreen> createState() => _OwnerStockScreenState();
}

class _OwnerStockScreenState extends State<OwnerStockScreen> {
  static const Color primaryColor = Color(0xFF0D5C40);
  String selectedCategory = 'Tất cả';
  String searchQuery = '';

  // Danh sách mặt hàng đa dạng mẫu
  final List<ProductItem> allProducts = [
    ProductItem(
      id: 'P01',
      name: 'Nước Revive Chanh Muối',
      category: 'Nước uống',
      sellingPrice: 15000,
      costPrice: 8000,
      unit: 'Chai',
      soldQuantity: 120,
      stockQuantity: 48,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2405/2405479.png',
    ),
    ProductItem(
      id: 'P02',
      name: 'Nước Revive Thường',
      category: 'Nước uống',
      sellingPrice: 15000,
      costPrice: 8000,
      unit: 'Chai',
      soldQuantity: 95,
      stockQuantity: 32,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2405/2405479.png',
    ),
    ProductItem(
      id: 'P03',
      name: 'Ống Cầu VinaStar 1',
      category: 'Dụng cụ & Cầu',
      sellingPrice: 240000,
      costPrice: 190000,
      unit: 'Ống',
      soldQuantity: 42,
      stockQuantity: 15,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3099/3099380.png',
    ),
    ProductItem(
      id: 'P04',
      name: 'Khăn Mặt Thể Thao',
      category: 'Trang phục & Phụ kiện',
      sellingPrice: 35000,
      costPrice: 18000,
      unit: 'Cái',
      soldQuantity: 60,
      stockQuantity: 25,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2913/2913520.png',
    ),
    ProductItem(
      id: 'P05',
      name: 'Vợt Cầu Lông Yonex Astrox',
      category: 'Vợt & Lưới',
      sellingPrice: 1250000,
      costPrice: 950000,
      unit: 'Cây',
      soldQuantity: 14,
      stockQuantity: 6,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2906/2906803.png',
    ),
    ProductItem(
      id: 'P06',
      name: 'Lưới / Cước Cầu Lông Yonex BG65',
      category: 'Vợt & Lưới',
      sellingPrice: 130000,
      costPrice: 85000,
      unit: 'Sợi',
      soldQuantity: 88,
      stockQuantity: 30,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/1165/1165187.png',
    ),
    ProductItem(
      id: 'P07',
      name: 'Tất / Vớ Cổ Cao Chống Trượt',
      category: 'Trang phục & Phụ kiện',
      sellingPrice: 45000,
      costPrice: 22000,
      unit: 'Đôi',
      soldQuantity: 110,
      stockQuantity: 50,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/888/888062.png',
    ),
    ProductItem(
      id: 'P08',
      name: 'Quấn Cán Vợt Cầu Lông (Yonex)',
      category: 'Trang phục & Phụ kiện',
      sellingPrice: 20000,
      costPrice: 9000,
      unit: 'Cái',
      soldQuantity: 210,
      stockQuantity: 85,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2548/2548537.png',
    ),
    ProductItem(
      id: 'P09',
      name: 'Nước Suối Aquafina 500ml',
      category: 'Nước uống',
      sellingPrice: 10000,
      costPrice: 4500,
      unit: 'Chai',
      soldQuantity: 340,
      stockQuantity: 120,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2405/2405479.png',
    ),
  ];

  final List<String> categories = [
    'Tất cả',
    'Nước uống',
    'Dụng cụ & Cầu',
    'Vợt & Lưới',
    'Trang phục & Phụ kiện',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Lọc theo danh mục & từ khóa tìm kiếm
    List<ProductItem> filteredProducts = allProducts.where((item) {
      bool matchesCategory = selectedCategory == 'Tất cả' || item.category == selectedCategory;
      bool matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text('Kho & Dịch vụ (Stock)'),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100), // Cân đối trên Web & PC
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. THANH TÌM KIẾM & THÊM HÀNG MỚI
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm mặt hàng (Nước, Vợt, Lưới, Tất,...)...',
                          prefixIcon: const Icon(Icons.search, color: primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Modal thêm sản phẩm mới vào SQL
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Thêm mặt hàng', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 2. DANH MỤC LỌC (CHIPS)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      bool isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: primaryColor.withValues(alpha: 0.15),
                          checkmarkColor: primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? primaryColor : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (val) {
                            setState(() {
                              selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. LƯỚI SẢN PHẨM (GRID VIEW)
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('Không tìm thấy mặt hàng phù hợp'))
                      : GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 800 ? 3 : (screenWidth > 500 ? 2 : 1),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: screenWidth > 800 ? 1.6 : 1.3,
                          ),
                          itemBuilder: (context, index) {
                            final item = filteredProducts[index];
                            return _buildProductCard(item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET THẺ SẢN PHẨM (Mô phỏng 100% thiết kế Ảnh 18)
  Widget _buildProductCard(ProductItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2), // Màu nền nhẹ chuẩn ảnh
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.network(
              item.imageUrl,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2, color: primaryColor),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Giá bán: ${_formatPrice(item.sellingPrice)} / ${item.unit}',
                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  'Giá vốn: ${_formatPrice(item.costPrice)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const Spacer(),

                // Badges Đã bán & Tồn kho
                Row(
                  children: [
                    _buildBadge('Đã bán: ${item.soldQuantity}', Colors.blue.shade50, Colors.blue.shade700),
                    const SizedBox(width: 6),
                    _buildBadge('Tồn kho: ${item.stockQuantity}', Colors.green.shade50, Colors.green.shade700),
                  ],
                ),
              ],
            ),
          ),

          // Nút thao tác nhanh (Thêm vào giỏ / Sửa)
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: primaryColor, size: 20),
            onPressed: () {
              // Thêm vào giỏ hoặc điều chỉnh kho
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toInt().toString().replaceAllRegExp(r'\B(?=(\d{3})+(?!\d))', '.')}đ';
  }
}

extension RegExpExtension on String {
  String replaceAllRegExp(RegExp regex, String replacement) {
    return replaceAllMapped(regex, (match) => replacement);
  }
}
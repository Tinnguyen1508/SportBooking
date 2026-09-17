import 'package:flutter/material.dart';

import 'court_detail_screen.dart';

class CourtListScreen extends StatefulWidget {
  const CourtListScreen({super.key});

  @override
  State<CourtListScreen> createState() => _CourtListScreenState();
}

class _CourtListScreenState extends State<CourtListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedSport = 'Tất cả';
  String _selectedDistrict = 'Tất cả';

  final List<String> _sports = [
    'Tất cả',
    'Cầu lông',
    'Bóng đá',
    'Bóng rổ',
    'Tennis',
  ];

  final List<String> _districts = [
    'Tất cả',
    'Thủ Dầu Một',
    'Dĩ An',
    'Thuận An',
  ];

  final List<Map<String, dynamic>> _courts = [
    {
      'name': 'Sân cầu lông Hoàng Gia',
      'sport': 'Cầu lông',
      'district': 'Thủ Dầu Một',
      'address': '123 Đại lộ Bình Dương',
      'price': 80000,
      'rating': 4.8,
      'image': 'assets/images/court1.jpg',
    },
    {
      'name': 'Badminton Center',
      'sport': 'Cầu lông',
      'district': 'Dĩ An',
      'address': '45 Nguyễn Tri Phương',
      'price': 70000,
      'rating': 4.6,
      'image': 'assets/images/court2.jpg',
    },
    {
      'name': 'Sport Arena',
      'sport': 'Bóng đá',
      'district': 'Thuận An',
      'address': '88 Lê Lợi',
      'price': 250000,
      'rating': 4.7,
      'image': 'assets/images/court3.jpg',
    },
    {
      'name': 'Tennis Garden',
      'sport': 'Tennis',
      'district': 'Thủ Dầu Một',
      'address': '12 Yersin',
      'price': 150000,
      'rating': 4.9,
      'image': 'assets/images/court4.jpg',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCourts {
    final keyword = _searchController.text.toLowerCase();

    return _courts.where((court) {
      final matchesSearch =
          court['name'].toString().toLowerCase().contains(keyword) ||
          court['address'].toString().toLowerCase().contains(keyword);

      final matchesSport = _selectedSport == 'Tất cả' ||
          court['sport'] == _selectedSport;

      final matchesDistrict = _selectedDistrict == 'Tất cả' ||
          court['district'] == _selectedDistrict;

      return matchesSearch && matchesSport && matchesDistrict;
    }).toList();
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        )}đ/giờ';
  }

  @override
  Widget build(BuildContext context) {
    final courts = _filteredCourts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tìm sân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),

          Expanded(
            child: courts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      return _buildCourtCard(courts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tìm tên sân hoặc địa chỉ...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _selectedSport,
                  items: _sports,
                  icon: Icons.sports,
                  onChanged: (value) {
                    setState(() {
                      _selectedSport = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildDropdown(
                  value: _selectedDistrict,
                  items: _districts,
                  icon: Icons.location_on_outlined,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã chọn ${court['name']}'),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.asset(
                court['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          court['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.star,
                        size: 19,
                        color: Colors.amber,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        court['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${court['address']}, ${court['district']}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          court['sport'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        _formatPrice(court['price']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CourtDetailScreen(
                                        name: court['name'],
                                        type: court['sport'],
                                        price: _formatPrice(court['price']),
                                        address: '${court['address']}, ${court['district']}',
                                        rating: court['rating'],
                                        courtPrice: court['price'],
                                    ),
                                ),
                            );
                        },
                        child: const Text(
                            'Xem chi tiết',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                     ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không tìm thấy sân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thử thay đổi từ khóa hoặc bộ lọc',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
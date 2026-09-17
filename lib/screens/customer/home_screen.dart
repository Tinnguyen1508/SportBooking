import 'package:flutter/material.dart';
import 'court_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> featuredCourts = [
    {
      'name': 'Sân cầu lông Hoàng Gia',
      'type': 'Cầu lông',
      'district': 'Thủ Dầu Một',
      'address': '123 Đại lộ Bình Dương',
      'price': 80000,
      'rating': 4.8,
      'image': 'assets/images/court1.jpg',
    },
    {
      'name': 'Sân cầu lông Bình Dương',
      'type': 'Cầu lông',
      'district': 'Dĩ An',
      'address': '45 Nguyễn Tri Phương',
      'price': 70000,
      'rating': 4.6,
      'image': 'assets/images/court2.jpg',
    },
    {
      'name': 'Sân Tennis Phú Cường',
      'type': 'Tennis',
      'district': 'Thủ Dầu Một',
      'address': '88 Phú Lợi',
      'price': 150000,
      'rating': 4.7,
      'image': 'assets/images/court3.jpg',
    },
    {
      'name': 'Sân bóng đá Thành Công',
      'type': 'Bóng đá',
      'district': 'Thuận An',
      'address': '20 Lê Lợi',
      'price': 250000,
      'rating': 4.9,
      'image': 'assets/images/court4.jpg',
    },
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Cầu lông',
      'icon': Icons.sports_tennis,
    },
    {
      'name': 'Tennis',
      'icon': Icons.sports_tennis,
    },
    {
      'name': 'Bóng đá',
      'icon': Icons.sports_soccer,
    },
    {
      'name': 'Bóng rổ',
      'icon': Icons.sports_basketball,
    },
  ];

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        )}đ';
  }

  void _openCourts() {
    Navigator.pushNamed(context, '/courts');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: [
            _buildHome(),
            _buildPlaceholder(
              Icons.calendar_month,
              'Lịch đặt sân',
            ),
            _buildPlaceholder(
              Icons.receipt_long,
              'Đơn đặt sân',
            ),
            _buildPlaceholder(
              Icons.person_outline,
              'Tài khoản',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C4ED9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn đặt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 22),
          _buildSearch(),
          const SizedBox(height: 25),
          _buildCategories(),
          const SizedBox(height: 28),
          _buildBookingButton(),
          const SizedBox(height: 30),
          _buildFeaturedTitle(),
          const SizedBox(height: 15),
          _buildFeaturedCourts(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.sports,
            color: Color(0xFF6C4ED9),
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào 👋',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Đặt sân thể thao',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF25232A),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            size: 28,
            color: Color(0xFF25232A),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm sân thể thao...',
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Môn thể thao',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF25232A),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];

              return InkWell(
                onTap: _openCourts,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 92,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 32,
                        color: const Color(0xFF6C4ED9),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _openCourts,
        icon: const Icon(Icons.calendar_month),
        label: const Text(
          'Đặt sân ngay',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C4ED9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Sân nổi bật',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF25232A),
          ),
        ),
        TextButton(
          onPressed: _openCourts,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: Color(0xFF6C4ED9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCourts() {
    return SizedBox(
      height: 285,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featuredCourts.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final court = featuredCourts[index];

          return Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Image.asset(
                      court['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8E8EE),
                          child: const Icon(
                            Icons.sports,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        court['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 17,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${court['rating']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              court['district'] as String,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatMoney(court['price'] as int)} / giờ',
                        style: const TextStyle(
                          color: Color(0xFF6C4ED9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(
    IconData icon,
    String title,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 70,
            color: const Color(0xFF6C4ED9),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chức năng sẽ được hoàn thiện sau.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
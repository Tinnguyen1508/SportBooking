import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminManageCourtsScreen extends StatefulWidget {
  const AdminManageCourtsScreen({super.key});

  @override
  State<AdminManageCourtsScreen> createState() => _AdminManageCourtsScreenState();
}

class _AdminManageCourtsScreenState extends State<AdminManageCourtsScreen> {
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  List<Map<String, dynamic>> courts = [
    {'name': 'Pickleball 1', 'type': 'Sân trong nhà', 'price': 150000, 'status': 'Hoạt động'},
    {'name': 'Pickleball 2', 'type': 'Sân trong nhà', 'price': 150000, 'status': 'Hoạt động'},
    {'name': 'Pickleball 3', 'type': 'Sân ngoài trời', 'price': 120000, 'status': 'Bảo trì'},
  ];

  String searchQuery = '';

  String formatMoney(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}đ';
  }

  void _showCourtDialog({int? index}) {
    final bool isEditing = index != null;
    final nameController = TextEditingController(text: isEditing ? courts[index]['name'] : '');
    final typeController = TextEditingController(text: isEditing ? courts[index]['type'] : 'Sân trong nhà');
    final priceController = TextEditingController(text: isEditing ? courts[index]['price'].toString() : '');
    String selectedStatus = isEditing ? courts[index]['status'] : 'Hoạt động';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEditing ? 'Sửa thông tin sân' : 'Thêm sân mới', style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sân',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập tên sân' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: typeController,
                        decoration: InputDecoration(
                          labelText: 'Loại sân',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập loại sân' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Giá tiền / giờ (VNĐ)',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập giá tiền' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Trạng thái',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: ['Hoạt động', 'Bảo trì'].map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setStateDialog(() => selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: greyText)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        final newCourt = {
                          'name': nameController.text.trim(),
                          'type': typeController.text.trim(),
                          'price': int.parse(priceController.text.trim()),
                          'status': selectedStatus,
                        };
                        if (isEditing) {
                          courts[index] = newCourt;
                        } else {
                          courts.add(newCourt);
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sân "${courts[index]['name']}" không?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: greyText))),
            ElevatedButton(
              onPressed: () {
                setState(() => courts.removeAt(index));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    final filteredCourts = courts.where((c) {
      return c['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             c['type'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             c['status'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Quản lý sân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: isDesktop ? 900 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên sân, loại, trạng thái...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredCourts.isEmpty
                        ? const Center(child: Text('Không tìm thấy sân nào.', style: TextStyle(color: Colors.white70, fontSize: 16)))
                        : ListView.builder(
                            itemCount: filteredCourts.length,
                            itemBuilder: (context, index) {
                              final court = filteredCourts[index];
                              final originalIndex = courts.indexOf(court);
                              bool isActive = court['status'] == 'Hoạt động';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.sports_tennis, color: primaryColor, size: 26),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(court['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                          const SizedBox(height: 4),
                                          Text('${court['type']} • ${formatMoney(court['price'])}/h', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text(court['status'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _showCourtDialog(index: originalIndex),
                                      icon: const Icon(Icons.edit_outlined, color: greyText),
                                    ),
                                    IconButton(
                                      onPressed: () => _confirmDelete(originalIndex),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourtDialog(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm sân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
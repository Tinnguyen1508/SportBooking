import 'package:flutter/material.dart';

class AdminManageUsersScreen extends StatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  State<AdminManageUsersScreen> createState() => _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState extends State<AdminManageUsersScreen> {
  static const Color primaryColor = Color(0xFF1E5631);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);

  List<Map<String, dynamic>> users = [
    {'name': 'Nguyễn Văn A', 'phone': '0901234567', 'email': 'nguyenvana@gmail.com', 'bookingsCount': 5},
    {'name': 'Trần Thị B', 'phone': '0912345678', 'email': 'tranthib@gmail.com', 'bookingsCount': 2},
    {'name': 'Lê Văn C', 'phone': '0987654321', 'email': 'levanc@gmail.com', 'bookingsCount': 10},
  ];

  String searchQuery = '';

  void _showUserDialog({int? index}) {
    final bool isEditing = index != null;
    final nameController = TextEditingController(text: isEditing ? users[index]['name'] : '');
    final phoneController = TextEditingController(text: isEditing ? users[index]['phone'] : '');
    final emailController = TextEditingController(text: isEditing ? users[index]['email'] : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Sửa thông tin khách hàng' : 'Thêm khách hàng mới', style: const TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (value) => value!.trim().isEmpty ? 'Vui lòng nhập email' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: greyText))),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    final newUser = {
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'email': emailController.text.trim(),
                      'bookingsCount': isEditing ? users[index]['bookingsCount'] : 0,
                    };
                    if (isEditing) {
                      users[index] = newUser;
                    } else {
                      users.add(newUser);
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
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa khách hàng "${users[index]['name']}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: greyText))),
            ElevatedButton(
              onPressed: () {
                setState(() => users.removeAt(index));
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

    final filteredUsers = users.where((u) {
      return u['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             u['phone'].contains(searchQuery) ||
             u['email'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Quản lý khách hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            // Giới hạn chiều rộng trên màn hình Windows lớn để không bị bè ngang
            child: Container(
              width: isDesktop ? 900 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, SĐT, email...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(child: Text('Không tìm thấy khách hàng nào.', style: TextStyle(color: Colors.white70, fontSize: 16)))
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
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
                                      child: const Icon(Icons.person_outline, color: primaryColor, size: 26),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                          const SizedBox(height: 4),
                                          Text('SĐT: ${user['phone']} | Email: ${user['email']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text('Đã đặt: ${user['bookingsCount']} lần', style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _showUserDialog(index: users.indexOf(user)),
                                      icon: const Icon(Icons.edit_outlined, color: greyText),
                                    ),
                                    IconButton(
                                      onPressed: () => _confirmDelete(users.indexOf(user)),
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
        onPressed: () => _showUserDialog(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm khách hàng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
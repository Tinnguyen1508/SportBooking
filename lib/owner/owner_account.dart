import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class OwnerAccountScreen extends StatefulWidget {
  const OwnerAccountScreen({super.key});

  @override
  State<OwnerAccountScreen> createState() => _OwnerAccountScreenState();
}

class _OwnerAccountScreenState extends State<OwnerAccountScreen> {
  static const Color primaryColor = Color(0xFF0D5C40);

  // Lưu trữ ảnh dạng Byte
  Uint8List? _selectedImageBytes;

  final String _fullName = 'Trần Huy Hoàng';
  final String _phone = '0905682143';
  final String _email = 'admin@alobadminton.com';
  final String _role = 'OWNER';

  // Mở cửa sổ chọn ảnh của Windows/Mac trực tiếp trên trình duyệt Web
  void _pickImageFromComputer() {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click(); // Kích hoạt hộp thoại chọn file của máy tính

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedImageBytes = reader.result as Uint8List?;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã cập nhật ảnh đại diện thành công!'),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ẢNH ĐẠI DIỆN & NÚT CẶP NHẬT ẢNH
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImageBytes != null
                              ? Image.memory(
                                  _selectedImageBytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  size: 65,
                                  color: Colors.grey[500],
                                ),
                        ),
                      ),
                      // Nút Camera bấm đổi ảnh
                      InkWell(
                        onTap: _pickImageFromComputer,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 20),

                  // SÂN YÊU THÍCH
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        const Text('Sân yêu thích của tôi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('0 sân >', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),

                  // THÔNG TIN CHI TIẾT
                  _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', _phone),
                  _buildInfoRow(Icons.email_outlined, 'Email', _email),
                  _buildInfoRow(Icons.shield_outlined, 'Quyền hạn', _role, isRole: true),

                  const SizedBox(height: 24),

                  // NÚT ĐĂNG XUẤT
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    label: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isRole = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isRole ? primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
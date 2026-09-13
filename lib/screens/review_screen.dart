import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const Color primaryColor = Color(0xFF6C4ED9);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textColor = Color(0xFF25232A);
  static const Color greyText = Color(0xFF7A7780);
  static const Color borderColor = Color(0xFFE5E3E8);

  int _rating = 0;

  final TextEditingController _reviewController =
      TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  final List<Uint8List> _reviewImages = [];

  String get ratingText {
    switch (_rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Tuyệt vời';
      default:
        return 'Chọn số sao';
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedImages =
        await _imagePicker.pickMultiImage();

    if (pickedImages.isEmpty) {
      return;
    }

    final int remaining =
        3 - _reviewImages.length;

    if (remaining <= 0) {
      return;
    }

    final imagesToAdd =
        pickedImages.take(remaining);

    for (final image in imagesToAdd) {
      final Uint8List bytes =
          await image.readAsBytes();

      _reviewImages.add(bytes);
    }

    if (mounted) {
      setState(() {});
    }

    if (pickedImages.length > remaining &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bạn chỉ có thể thêm tối đa 3 ảnh',
          ),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _reviewImages.removeAt(index);
    });
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng chọn số sao đánh giá',
          ),
        ),
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập nhận xét của bạn',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 58,
          ),
          title: const Text(
            'Cảm ơn bạn!',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Bạn đã gửi đánh giá $_rating sao thành công.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment:
              MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _rating = 0;
                  _reviewController.clear();
                  _reviewImages.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Đóng',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final int starNumber =
              index + 1;

          return InkWell(
            onTap: () {
              setState(() {
                _rating = starNumber;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 6,
              ),
              child: Icon(
                starNumber <= _rating
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 46,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Thêm ảnh',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Bạn có thể thêm tối đa 3 ảnh',
          style: TextStyle(
            fontSize: 13,
            color: greyText,
          ),
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (_reviewImages.length < 3)
              InkWell(
                onTap: _pickImages,
                borderRadius:
                    BorderRadius.circular(14),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFBFBFD),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .add_a_photo_outlined,
                        color: primaryColor,
                        size: 34,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Thêm ảnh',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ...List.generate(
              _reviewImages.length,
              (index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(14),
                      child: Image.memory(
                        _reviewImages[index],
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () {
                          _removeImage(index);
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xCC25232A),
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewCard({
    required String initials,
    required String name,
    required int stars,
    required String date,
    required String comment,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    const Color(0xFFF2EFFF),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children:
                          List.generate(
                        5,
                        (index) {
                          return Icon(
                            index < stars
                                ? Icons.star
                                : Icons
                                    .star_border,
                            color:
                                Colors.amber,
                            size: 19,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                date,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            comment,
            style: const TextStyle(
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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
          'Đánh giá sân',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 650,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // THÔNG TIN SÂN
                  Container(
                    padding:
                        const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              primaryColor,
                          child: Icon(
                            Icons.sports_tennis,
                            color: Colors.white,
                            size: 31,
                          ),
                        ),

                        SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Sport Center ABC',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Cầu lông - Sân 3',
                                style: TextStyle(
                                  color: greyText,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '15/09/2026 • 18:00 - 20:00',
                                style: TextStyle(
                                  color: greyText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FORM ĐÁNH GIÁ
                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Bạn thấy địa điểm này thế nào?',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildStars(),

                        const SizedBox(height: 8),

                        Text(
                          ratingText,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: _rating == 0
                                ? greyText
                                : primaryColor,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Chia sẻ trải nghiệm của bạn',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller:
                              _reviewController,
                          minLines: 4,
                          maxLines: 6,
                          maxLength: 500,
                          keyboardType:
                              TextInputType
                                  .multiline,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Viết nhận xét về sân...',
                            filled: true,
                            fillColor:
                                const Color(
                              0xFFFBFBFD,
                            ),
                            contentPadding:
                                const EdgeInsets.all(
                              16,
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                              borderSide:
                                  const BorderSide(
                                color:
                                    borderColor,
                              ),
                            ),
                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                              borderSide:
                                  const BorderSide(
                                color:
                                    primaryColor,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildImagePicker(),

                        const SizedBox(height: 24),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _submitReview,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  primaryColor,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(14),
                              ),
                            ),
                            child: const Text(
                              'Gửi đánh giá',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Đánh giá của người dùng',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _reviewCard(
                    initials: 'NA',
                    name: 'Nguyễn Minh Anh',
                    stars: 5,
                    date: '12/09/2026',
                    comment:
                        'Sân sạch sẽ, nhân viên nhiệt tình. Mình sẽ quay lại.',
                  ),

                  _reviewCard(
                    initials: 'TB',
                    name: 'Trần Quốc Bảo',
                    stars: 4,
                    date: '05/09/2026',
                    comment:
                        'Sân khá tốt, giá hợp lý và dễ tìm.',
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
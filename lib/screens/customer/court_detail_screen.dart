import 'package:flutter/material.dart';
import 'booking_confirm_screen.dart';

class CourtDetailScreen extends StatefulWidget {
  final String name;
  final String type;
  final String price;
  final String address;
  final double rating;
  final int courtPrice;

  const CourtDetailScreen({
    super.key,
    required this.name,
    required this.type,
    required this.price,
    required this.address,
    required this.rating,
    required this.courtPrice,
  });

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  int selectedCourt = 0;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  final List<String> courtNames = [
    'Sân 1',
    'Sân 2',
    'Sân 3',
    'Sân 4',
  ];

  final List<String> timeSlots = [
    '06:00 - 07:00',
    '07:00 - 08:00',
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
  ];

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF25232A),
          ),
        ),
        title: const Text(
          'Chi tiết sân',
          style: TextStyle(
            color: Color(0xFF25232A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= IMAGE =================
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8EE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.sports,
                  size: 80,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // ================= NAME =================
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF25232A),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.type,
                      style: const TextStyle(
                        color: Color(0xFF6C4ED9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: const TextStyle(
                        color: Color(0xFF7A7780),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C4ED9),
                ),
              ),

              const SizedBox(height: 25),

              // ================= DESCRIPTION =================
              const Text(
                'Thông tin sân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Sân thể thao được trang bị đầy đủ tiện nghi, '
                'phù hợp cho việc luyện tập và thi đấu.',
                style: TextStyle(
                  color: Color(0xFF7A7780),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // ================= COURT =================
              const Text(
                'Chọn sân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  courtNames.length,
                  (index) {
                    final bool selected = selectedCourt == index;

                    return ChoiceChip(
                      label: Text(courtNames[index]),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          selectedCourt = index;
                        });
                      },
                      selectedColor: const Color(0xFF6C4ED9),
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF25232A),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ================= DATE =================
              const Text(
                'Chọn ngày',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE5E3E8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF6C4ED9),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= TIME =================
              const Text(
                'Chọn giờ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timeSlots.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final String time = timeSlots[index];
                  final bool selected = selectedTime == time;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF6C4ED9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF6C4ED9)
                              : const Color(0xFFE5E3E8),
                        ),
                      ),
                      child: Text(
                        time,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF25232A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ================= BOOK =================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedTime == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingConfirmScreen(
                                courtName: widget.name,
                                courtType: widget.type,
                                courtDetail:
                                    courtNames[selectedCourt],
                                date: _formatDate(selectedDate),
                                time: selectedTime!,
                                courtPrice: widget.courtPrice,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C4ED9),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục đặt sân',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
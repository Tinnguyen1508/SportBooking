import 'package:flutter/material.dart';

// ==========================================
// 1. DATA MODELS MAP 100% VỚI DATABASE SQL
// ==========================================

/// Map bảng 'sports'
class SportModel {
  final int id;
  final String name;
  final String? iconUrl;
  final bool isActive;

  SportModel({required this.id, required this.name, this.iconUrl, this.isActive = true});

  factory SportModel.fromJson(Map<String, dynamic> json) => SportModel(
        id: json['id'],
        name: json['name'],
        iconUrl: json['icon_url'],
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon_url': iconUrl, 'is_active': isActive};
}

/// Map bảng 'districts'
class DistrictModel {
  final int id;
  final String provinceName;
  final String districtName;

  DistrictModel({required this.id, required this.provinceName, required this.districtName});

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        id: json['id'],
        provinceName: json['province_name'],
        districtName: json['district_name'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'province_name': provinceName, 'district_name': districtName};
}

/// Map bảng 'amenities'
class AmenityModel {
  final int id;
  final String name;
  final String? iconCode;
  bool isSelected;

  AmenityModel({required this.id, required this.name, this.iconCode, this.isSelected = false});

  factory AmenityModel.fromJson(Map<String, dynamic> json) => AmenityModel(
        id: json['id'],
        name: json['name'],
        iconCode: json['icon_code'],
      );
}

/// Map bảng 'court_details' (Sân con)
class CourtDetailModel {
  int? id;
  int? courtId;
  String name;
  bool isActive;

  CourtDetailModel({this.id, this.courtId, required this.name, this.isActive = true});

  factory CourtDetailModel.fromJson(Map<String, dynamic> json) => CourtDetailModel(
        id: json['id'],
        courtId: json['court_id'],
        name: json['name'],
        isActive: json['is_active'] ?? true,
      );

  Map<String, dynamic> toJson() => {'id': id, 'court_id': courtId, 'name': name, 'is_active': isActive};
}

/// Map bảng 'slot_pricings' (Bảng giá theo khung giờ & ngày)
class SlotPricingModel {
  int? id;
  int? courtId;
  String startTime; // hh:mm:ss
  String endTime;   // hh:mm:ss
  double pricePerHour;
  String dayType;   // 'WEEKDAY', 'WEEKEND', 'HOLIDAY'

  SlotPricingModel({
    this.id,
    this.courtId,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    required this.dayType,
  });

  factory SlotPricingModel.fromJson(Map<String, dynamic> json) => SlotPricingModel(
        id: json['id'],
        courtId: json['court_id'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        pricePerHour: (json['price_per_hour'] as num).toDouble(),
        dayType: json['day_type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'court_id': courtId,
        'start_time': startTime,
        'end_time': endTime,
        'price_per_hour': pricePerHour,
        'day_type': dayType,
      };
}

/// Map bảng 'services' (Dịch vụ đi kèm)
class ServiceModel {
  int? id;
  int? courtId;
  String name;
  double price;

  ServiceModel({this.id, this.courtId, required this.name, required this.price});

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        courtId: json['court_id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'court_id': courtId, 'name': name, 'price': price};
}

/// Map bảng 'court_images'
class CourtImageModel {
  int? id;
  int? courtId;
  String imageUrl;
  bool isPrimary;

  CourtImageModel({this.id, this.courtId, required this.imageUrl, this.isPrimary = false});

  factory CourtImageModel.fromJson(Map<String, dynamic> json) => CourtImageModel(
        id: json['id'],
        courtId: json['court_id'],
        imageUrl: json['image_url'],
        isPrimary: json['is_primary'] ?? false,
      );

  Map<String, dynamic> toJson() => {'id': id, 'court_id': courtId, 'image_url': imageUrl, 'is_primary': isPrimary};
}

/// Map bảng chính 'courts' (Cụm sân)
class CourtModel {
  int? id;
  int ownerId;
  int? sportId;
  int? districtId;
  String name;
  String address;
  double? latitude;
  double? longitude;
  String openingTime;
  String closingTime;
  String status; // 'PENDING', 'ACTIVE', 'SUSPENDED'
  String? bankName;
  String? bankAccountNumber;
  String? bankAccountHolder;
  String? businessLicenseUrl;

  // Danh sách quan hệ (Child Tables)
  List<CourtDetailModel> courtDetails;
  List<SlotPricingModel> slotPricings;
  List<ServiceModel> services;
  List<CourtImageModel> images;
  List<int> amenityIds;

  CourtModel({
    this.id,
    required this.ownerId,
    this.sportId,
    this.districtId,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    required this.openingTime,
    required this.closingTime,
    this.status = 'PENDING',
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.businessLicenseUrl,
    List<CourtDetailModel>? courtDetails,
    List<SlotPricingModel>? slotPricings,
    List<ServiceModel>? services,
    List<CourtImageModel>? images,
    List<int>? amenityIds,
  })  : courtDetails = courtDetails ?? [],
        slotPricings = slotPricings ?? [],
        services = services ?? [],
        images = images ?? [],
        amenityIds = amenityIds ?? [];

  factory CourtModel.fromJson(Map<String, dynamic> json) => CourtModel(
        id: json['id'],
        ownerId: json['owner_id'],
        sportId: json['sport_id'],
        districtId: json['district_id'],
        name: json['name'],
        address: json['address'],
        latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
        longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
        openingTime: json['opening_time'],
        closingTime: json['closing_time'],
        status: json['status'] ?? 'PENDING',
        bankName: json['bank_name'],
        bankAccountNumber: json['bank_account_number'],
        bankAccountHolder: json['bank_account_holder'],
        businessLicenseUrl: json['business_license_url'],
        courtDetails: json['court_details'] != null
            ? (json['court_details'] as List).map((i) => CourtDetailModel.fromJson(i)).toList()
            : [],
        slotPricings: json['slot_pricings'] != null
            ? (json['slot_pricings'] as List).map((i) => SlotPricingModel.fromJson(i)).toList()
            : [],
        services: json['services'] != null
            ? (json['services'] as List).map((i) => ServiceModel.fromJson(i)).toList()
            : [],
        images: json['court_images'] != null
            ? (json['court_images'] as List).map((i) => CourtImageModel.fromJson(i)).toList()
            : [],
        amenityIds: json['amenity_ids'] != null ? List<int>.from(json['amenity_ids']) : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'sport_id': sportId,
        'district_id': districtId,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'status': status,
        'bank_name': bankName,
        'bank_account_number': bankAccountNumber,
        'bank_account_holder': bankAccountHolder,
        'business_license_url': businessLicenseUrl,
        'court_details': courtDetails.map((v) => v.toJson()).toList(),
        'slot_pricings': slotPricings.map((v) => v.toJson()).toList(),
        'services': services.map((v) => v.toJson()).toList(),
        'court_images': images.map((v) => v.toJson()).toList(),
        'amenity_ids': amenityIds,
      };
}

// ==========================================
// 2. GIAO DIỆN QUẢN LÝ CỤM SÂN (OWNER)
// ==========================================

class OwnerBranchScreen extends StatefulWidget {
  const OwnerBranchScreen({super.key});

  @override
  State<OwnerBranchScreen> createState() => _OwnerBranchScreenState();
}

class _OwnerBranchScreenState extends State<OwnerBranchScreen> {
  static const Color primaryColor = Color(0xFF0D5C40);

  // Danh mục mẫu từ Database (Sports, Districts, Amenities)
  final List<SportModel> _sports = [
    SportModel(id: 1, name: 'Cầu lông'),
    SportModel(id: 2, name: 'Pickleball'),
    SportModel(id: 3, name: 'Tennis'),
  ];

  final List<DistrictModel> _districts = [
    DistrictModel(id: 1, provinceName: 'TP. Hồ Chí Minh', districtName: 'Quận 7'),
    DistrictModel(id: 2, provinceName: 'TP. Hồ Chí Minh', districtName: 'Quận Tân Bình'),
    DistrictModel(id: 3, provinceName: 'TP. Hồ Chí Minh', districtName: 'TP. Thủ Đức'),
  ];

  final List<AmenityModel> _allAmenities = [
    AmenityModel(id: 1, name: 'Wifi miễn phí', iconCode: 'wifi'),
    AmenityModel(id: 2, name: 'Bãi đỗ ô tô', iconCode: 'directions_car'),
    AmenityModel(id: 3, name: 'Canteen / Nước uống', iconCode: 'local_cafe'),
    AmenityModel(id: 4, name: 'Máy lạnh / Quạt mát', iconCode: 'ac_unit'),
    AmenityModel(id: 5, name: 'Phòng thay đồ & Tắm', iconCode: 'shower'),
  ];

  // Danh sách Cụm sân mẫu (Courts)
  final List<CourtModel> _courts = [
    CourtModel(
      id: 1,
      ownerId: 101,
      sportId: 1,
      districtId: 1,
      name: 'Alo Badminton - Cơ sở Quận 7',
      address: '123 Nguyễn Hữu Thọ, P. Tân Hưng, Quận 7',
      latitude: 10.7324,
      longitude: 106.6992,
      openingTime: '05:00:00',
      closingTime: '23:00:00',
      status: 'ACTIVE',
      bankName: 'MBBank',
      bankAccountNumber: '0905682143',
      bankAccountHolder: 'TRAN HUY HOANG',
      businessLicenseUrl: 'https://example.com/license1.pdf',
      amenityIds: [1, 2, 3],
      courtDetails: [
        CourtDetailModel(id: 101, courtId: 1, name: 'Sân 01 - VIP', isActive: true),
        CourtDetailModel(id: 102, courtId: 1, name: 'Sân 02', isActive: true),
        CourtDetailModel(id: 103, courtId: 1, name: 'Sân 03', isActive: true),
      ],
      slotPricings: [
        SlotPricingModel(id: 1, courtId: 1, startTime: '05:00:00', endTime: '16:00:00', pricePerHour: 80000, dayType: 'WEEKDAY'),
        SlotPricingModel(id: 2, courtId: 1, startTime: '16:00:00', endTime: '23:00:00', pricePerHour: 120000, dayType: 'WEEKDAY'),
        SlotPricingModel(id: 3, courtId: 1, startTime: '05:00:00', endTime: '23:00:00', pricePerHour: 140000, dayType: 'WEEKEND'),
      ],
      services: [
        ServiceModel(id: 1, courtId: 1, name: 'Nước suối 500ml', price: 10000),
        ServiceModel(id: 2, courtId: 1, name: 'Thuê vợt Yonex', price: 30000),
      ],
      images: [
        CourtImageModel(id: 1, courtId: 1, imageUrl: 'https://picsum.photos/400/200', isPrimary: true),
      ],
    ),
  ];

  // Mở Form Thêm/Sửa Cụm sân đầy đủ thuộc tính
  void _openCourtFormDialog({CourtModel? existingCourt}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _CourtFormSheet(
        existingCourt: existingCourt,
        sports: _sports,
        districts: _districts,
        amenities: _allAmenities,
        onSave: (savedCourt) {
          setState(() {
            if (existingCourt == null) {
              _courts.add(savedCourt);
            } else {
              int idx = _courts.indexWhere((c) => c.id == existingCourt.id);
              if (idx != -1) _courts[idx] = savedCourt;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(existingCourt == null ? 'Đã thêm cụm sân mới thành công!' : 'Đã cập nhật thông tin cụm sân!'),
              backgroundColor: primaryColor,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCourts = _courts.length;
    int activeCourts = _courts.where((c) => c.status == 'ACTIVE').length;
    int totalChildCourts = _courts.fold(0, (sum, c) => sum + c.courtDetails.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text('Quản lý Cụm sân (Courts)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCourtFormDialog(),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: const Text('Thêm Cụm Sân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Thống kê nhanh
          Container(
            color: primaryColor,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Tổng Cụm Sân', '$totalCourts', Icons.store_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Hoạt Động', '$activeCourts', Icons.check_circle_rounded)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Tổng Sân Con', '$totalChildCourts sân', Icons.sports_tennis_rounded)),
              ],
            ),
          ),

          // Danh sách cụm sân
          Expanded(
            child: _courts.isEmpty
                ? const Center(child: Text('Chưa có cụm sân nào trong cơ sở dữ liệu.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _courts.length,
                    itemBuilder: (context, index) {
                      final court = _courts[index];
                      return _buildCourtCard(court);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCourtCard(CourtModel court) {
    Color statusColor = court.status == 'ACTIVE'
        ? Colors.green
        : (court.status == 'PENDING' ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề & Trạng thái (status CHECK 'PENDING', 'ACTIVE', 'SUSPENDED')
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.storefront_rounded, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(court.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    court.status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Địa chỉ & Giờ mở cửa
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(child: Text(court.address, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text('Mở cửa: ${court.openingTime.substring(0, 5)} - ${court.closingTime.substring(0, 5)}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                const Spacer(),
                Icon(Icons.sports_tennis_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${court.courtDetails.length} Sân con', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),

            // Thông tin Ngân hàng (bank_name, bank_account_number)
            if (court.bankName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_rounded, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text('${court.bankName} - ${court.bankAccountNumber} (${court.bankAccountHolder})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],

            const Divider(height: 20),

            // Nút Chỉnh sửa cấu hình toàn bộ Cụm sân
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giá từ: ${_getMinPrice(court.slotPricings)}đ/giờ', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                OutlinedButton.icon(
                  onPressed: () => _openCourtFormDialog(existingCourt: court),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Cấu hình / Sửa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMinPrice(List<SlotPricingModel> pricings) {
    if (pricings.isEmpty) return '0';
    double min = pricings.map((e) => e.pricePerHour).reduce((a, b) => a < b ? a : b);
    return min.toInt().toString();
  }
}

// ==========================================
// 3. FORM SHEET CẤU HÌNH ĐẦY ĐỦ CÁC BẢNG CHILD
// ==========================================

class _CourtFormSheet extends StatefulWidget {
  final CourtModel? existingCourt;
  final List<SportModel> sports;
  final List<DistrictModel> districts;
  final List<AmenityModel> amenities;
  final Function(CourtModel) onSave;

  const _CourtFormSheet({
    this.existingCourt,
    required this.sports,
    required this.districts,
    required this.amenities,
    required this.onSave,
  });

  @override
  State<_CourtFormSheet> createState() => _CourtFormSheetState();
}

class _CourtFormSheetState extends State<_CourtFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccNumController;
  late TextEditingController _bankAccHolderController;

  int? _selectedSportId;
  int? _selectedDistrictId;
  String _status = 'ACTIVE';

  List<CourtDetailModel> _courtDetails = [];
  List<SlotPricingModel> _slotPricings = [];
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    final c = widget.existingCourt;
    _nameController = TextEditingController(text: c?.name ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _openTimeController = TextEditingController(text: c?.openingTime ?? '05:00:00');
    _closeTimeController = TextEditingController(text: c?.closingTime ?? '23:00:00');
    _bankNameController = TextEditingController(text: c?.bankName ?? '');
    _bankAccNumController = TextEditingController(text: c?.bankAccountNumber ?? '');
    _bankAccHolderController = TextEditingController(text: c?.bankAccountHolder ?? '');

    _selectedSportId = c?.sportId ?? (widget.sports.isNotEmpty ? widget.sports.first.id : null);
    _selectedDistrictId = c?.districtId ?? (widget.districts.isNotEmpty ? widget.districts.first.id : null);
    _status = c?.status ?? 'ACTIVE';

    _courtDetails = c != null ? List.from(c.courtDetails) : [CourtDetailModel(name: 'Sân 01')];
    _slotPricings = c != null ? List.from(c.slotPricings) : [];
    _services = c != null ? List.from(c.services) : [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingCourt == null ? 'Thêm Cụm Sân Mới' : 'Sửa Thông Tin Cụm Sân',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D5C40)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const Text('1. Thông tin chung (Bảng courts)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên cụm sân (name)', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Địa chỉ đầy đủ (address)', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedSportId,
                          decoration: const InputDecoration(labelText: 'Bộ môn (sport_id)', border: OutlineInputBorder()),
                          items: widget.sports.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                          onChanged: (val) => setState(() => _selectedSportId = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedDistrictId,
                          decoration: const InputDecoration(labelText: 'Khu vực (district_id)', border: OutlineInputBorder()),
                          items: widget.districts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.districtName))).toList(),
                          onChanged: (val) => setState(() => _selectedDistrictId = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _openTimeController,
                          decoration: const InputDecoration(labelText: 'Giờ mở cửa (opening_time)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _closeTimeController,
                          decoration: const InputDecoration(labelText: 'Giờ đóng cửa (closing_time)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('2. Tài khoản ngân hàng (Thanh toán VietQR)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(labelText: 'Tên ngân hàng (bank_name)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bankAccNumController,
                          decoration: const InputDecoration(labelText: 'Số tài khoản (bank_account_number)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _bankAccHolderController,
                          decoration: const InputDecoration(labelText: 'Chủ tài khoản (bank_account_holder)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3. Danh sách Sân con (court_details)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _courtDetails.add(CourtDetailModel(name: 'Sân 0${_courtDetails.length + 1}'));
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm Sân Con'),
                      ),
                    ],
                  ),
                  ..._courtDetails.asMap().entries.map((entry) {
                    int index = entry.key;
                    var detail = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: detail.name,
                              decoration: InputDecoration(labelText: 'Tên sân #${index + 1}', border: const OutlineInputBorder()),
                              onChanged: (val) => detail.name = val,
                            ),
                          ),
                          Switch(
                            value: detail.isActive,
                            onChanged: (val) => setState(() => detail.isActive = val),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _courtDetails.removeAt(index)),
                          )
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
                  const Text('4. Trạng thái hoạt động (status)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'PENDING', child: Text('PENDING (Chờ duyệt)')),
                      DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE (Đang hoạt động)')),
                      DropdownMenuItem(value: 'SUSPENDED', child: Text('SUSPENDED (Tạm ngưng)')),
                    ],
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C40)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newCourt = CourtModel(
                      id: widget.existingCourt?.id ?? DateTime.now().millisecondsSinceEpoch,
                      ownerId: widget.existingCourt?.ownerId ?? 101,
                      sportId: _selectedSportId,
                      districtId: _selectedDistrictId,
                      name: _nameController.text.trim(),
                      address: _addressController.text.trim(),
                      openingTime: _openTimeController.text.trim(),
                      closingTime: _closeTimeController.text.trim(),
                      status: _status,
                      bankName: _bankNameController.text.trim(),
                      bankAccountNumber: _bankAccNumController.text.trim(),
                      bankAccountHolder: _bankAccHolderController.text.trim(),
                      courtDetails: _courtDetails,
                      slotPricings: _slotPricings,
                      services: _services,
                    );
                    widget.onSave(newCourt);
                    Navigator.pop(context);
                  }
                },
                child: const Text('LƯU DỮ LIỆU CỤM SÂN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
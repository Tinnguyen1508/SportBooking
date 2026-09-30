import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/district_service.dart';

class LocationSelectionModal extends StatefulWidget {
  const LocationSelectionModal({
    super.key,
    this.initialDistrictId,
    this.initialProvinceName,
    this.initialLatitude,
    this.initialLongitude,
    this.useMockData = false,
  });

  final int? initialDistrictId;
  final String? initialProvinceName;
  final double? initialLatitude;
  final double? initialLongitude;
  final bool useMockData;

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  static const Color _primaryColor = Color(0xFF00A86B);

  late final DistrictService _districtService;
  late Future<void> _loadTask;
  late final TextEditingController _provinceSearchController;
  List<Map<String, dynamic>> _districts = [];
  String? _selectedProvince;
  int? _selectedDistrictId;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;
  bool _showProvinceOptions = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _districtService = DistrictService(useMockData: widget.useMockData);
    _selectedProvince = widget.initialProvinceName;
    _provinceSearchController = TextEditingController(
      text: widget.initialProvinceName ?? '',
    );
    _selectedDistrictId = widget.initialDistrictId;
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _loadTask = _loadDistricts();
  }

  @override
  void dispose() {
    _provinceSearchController.dispose();
    _districtService.close();
    super.dispose();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await _districtService.getDistricts();
      if (!mounted) return;
      setState(() {
        _districts = districts;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _districts = [];
      });
      debugPrint('Không tải được danh sách quận/huyện: $error');
    }
  }

  List<String> get _provinces {
    final provinces = <String>{
      ...DistrictService.vietnamProvinceNames,
      ..._districts.map((district) => district['province_name'].toString()),
    }.toList();
    provinces.sort((a, b) => a.compareTo(b));
    return provinces;
  }

  List<String> get _matchingProvinces {
    final query = _provinceSearchController.text.trim();
    if (query.isEmpty) return _provinces;
    return _provinces
        .where(
          (province) =>
              DistrictService.provinceMatchesSearch(province, query),
        )
        .toList();
  }

  void _selectProvince(String? province) {
    setState(() {
      _selectedProvince = province;
      _provinceSearchController.text = province ?? '';
      _showProvinceOptions = false;
      if (!_visibleDistricts.any(
        (district) => district['id'] == _selectedDistrictId,
      )) {
        _selectedDistrictId = null;
      }
      _latitude = null;
      _longitude = null;
    });
  }

  List<Map<String, dynamic>> get _visibleDistricts {
    if (_selectedProvince == null) return const [];
    final availableDistricts = DistrictService.withHoChiMinhDistricts(
      _districts,
    );
    return availableDistricts
        .where((district) => district['province_name'] == _selectedProvince)
        .toList();
  }

  Future<void> _findNearbyCourts() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Vui lòng bật dịch vụ định vị trên thiết bị.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Ứng dụng chưa được cấp quyền truy cập vị trí.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Quyền vị trí đang bị chặn. Hãy bật quyền này trong cài đặt ứng dụng.',
        );
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _selectedProvince = null;
        _selectedDistrictId = null;
        _provinceSearchController.clear();
        _showProvinceOptions = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _locationError = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _applySelection() {
    final hasPosition = _latitude != null && _longitude != null;
    Navigator.of(context).pop(<String, dynamic>{
      'district_id': hasPosition ? null : _selectedDistrictId,
      'province_name': hasPosition ? null : _selectedProvince,
      'lat': _latitude,
      'lng': _longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Chọn vị trí đặt sân',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLocating ? null : _findNearbyCourts,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isLocating
                          ? 'Đang lấy vị trí...'
                          : 'Tìm sân gần vị trí của tôi',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: const BorderSide(color: _primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              if (_locationError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    _locationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    'Đã lấy vị trí GPS (${_latitude!.toStringAsFixed(5)}, '
                    '${_longitude!.toStringAsFixed(5)})',
                    style: const TextStyle(color: _primaryColor, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tỉnh / Thành phố',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: _provinceSearchController,
                      onTap: () => setState(() {
                        _showProvinceOptions = true;
                      }),
                      onChanged: (_) => setState(() {
                        _selectedProvince = null;
                        _selectedDistrictId = null;
                        _latitude = null;
                        _longitude = null;
                        _showProvinceOptions = true;
                      }),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên tỉnh/thành phố để tìm',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: _showProvinceOptions
                              ? 'Đóng danh sách'
                              : 'Mở danh sách',
                          onPressed: () => setState(() {
                            _showProvinceOptions = !_showProvinceOptions;
                          }),
                          icon: Icon(
                            _showProvinceOptions
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: _primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_showProvinceOptions)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 190),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _matchingProvinces.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: Text('Không tìm thấy tỉnh/thành phố.'),
                              )
                            : ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: const Text('Tất cả tỉnh/thành phố'),
                                    trailing: _selectedProvince == null
                                        ? const Icon(
                                            Icons.check,
                                            color: _primaryColor,
                                          )
                                        : null,
                                    onTap: () => _selectProvince(null),
                                  ),
                                  ..._matchingProvinces.map(
                                    (province) => ListTile(
                                      dense: true,
                                      title: Text(province),
                                      trailing: _selectedProvince == province
                                          ? const Icon(
                                              Icons.check,
                                              color: _primaryColor,
                                            )
                                          : null,
                                      onTap: () => _selectProvince(province),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<void>(
                  future: _loadTask,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primaryColor),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          if (_selectedProvince != null) ...[
                            const Text(
                              'Quận / Huyện',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (_visibleDistricts.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Chưa có dữ liệu quận/huyện cho $_selectedProvince.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildChip(
                                  label: 'Tất cả $_selectedProvince',
                                  selected: _selectedDistrictId == null,
                                  onSelected: () {
                                    setState(() {
                                      _selectedDistrictId = null;
                                      _latitude = null;
                                      _longitude = null;
                                    });
                                  },
                                ),
                                ..._visibleDistricts.map(
                                  (district) => _buildChip(
                                    label: district['name'].toString(),
                                    selected:
                                        district['id'] == _selectedDistrictId,
                                    onSelected: () {
                                      setState(() {
                                        _selectedDistrictId =
                                            district['id'] as int;
                                        _selectedProvince =
                                            district['province_name']
                                                .toString();
                                        _provinceSearchController.text =
                                            _selectedProvince!;
                                        _latitude = null;
                                        _longitude = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _applySelection,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Áp dụng',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: _primaryColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? _primaryColor : Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

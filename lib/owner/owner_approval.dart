// lib/owner/owner_approval_screen.dart
// Màn hình "Duyệt đơn" của chủ sân - kết nối backend Node.js (SQL Server)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ===================== CẤU HÌNH =====================
// Flutter Web / Desktop: localhost | Android emulator: 10.0.2.2 | Máy thật: IP LAN
// Đổi cổng cho khớp PORT của backend
const String kApiBase = 'http://localhost:3000/api';

const Color _kGreen = Color(0xFF0D5C40);

// ===================== MODEL =====================
double _num(dynamic v) => v == null ? 0 : (double.tryParse('$v') ?? 0);

// SQL Server có thể trả cột BIGINT dạng chuỗi ("1") -> đọc được cả số lẫn chuỗi
int _int(dynamic v) => v is int ? v : (int.tryParse('$v') ?? 0);

DateTime? _parseDT(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString().replaceFirst(' ', 'T'));
}

class BookingItem {
  final String courtName;
  final String bookingDate; // yyyy-MM-dd
  final String startTime;
  final String endTime;
  final double price;

  BookingItem({
    required this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  factory BookingItem.fromJson(Map<String, dynamic> j) => BookingItem(
    courtName: (j['court_name'] ?? 'Sân #${j['court_id']}').toString(),
    bookingDate: (j['booking_date'] ?? '').toString(),
    startTime: (j['start_time'] ?? '').toString(),
    endTime: (j['end_time'] ?? '').toString(),
    price: _num(j['price']),
  );
}

class ApprovalBooking {
  final int id;
  final int userId;
  final String code;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final double refundAmount;
  final String? cancellationReason;
  final String customerName;
  final String customerPhone;
  final List<BookingItem> items;

  ApprovalBooking({
    required this.id,
    required this.userId,
    required this.code,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.cancelledAt,
    required this.refundAmount,
    required this.cancellationReason,
    required this.customerName,
    required this.customerPhone,
    required this.items,
  });

  factory ApprovalBooking.fromJson(Map<String, dynamic> j) => ApprovalBooking(
    id: _int(j['id']),
    userId: _int(j['user_id']),
    code: (j['booking_code'] ?? '').toString(),
    totalAmount: _num(j['total_amount']),
    status: (j['status'] ?? '').toString().trim().toUpperCase(),
    createdAt: _parseDT(j['created_at']),
    cancelledAt: _parseDT(j['cancelled_at']),
    refundAmount: _num(j['refund_amount']),
    cancellationReason: j['cancellation_reason']?.toString(),
    customerName: (j['customer_name'] ?? 'Khách #${j['user_id']}').toString(),
    customerPhone: (j['customer_phone'] ?? '').toString(),
    items: ((j['items'] ?? []) as List)
        .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ApprovalResult {
  final Map<String, int> counts;
  final List<ApprovalBooking> data;
  ApprovalResult(this.counts, this.data);
}

// ===================== API =====================
class ApprovalApi {
  // Token do AuthService.login lưu trong SharedPreferences (key 'userToken').
  // Đọc lại mỗi lần gọi để luôn đúng với tài khoản đang đăng nhập.
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> _run(Future<http.Response> request) async {
    http.Response res;
    try {
      res = await request.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Server phản hồi quá lâu, vui lòng thử lại');
    } catch (_) {
      throw Exception(
        'Không kết nối được server (kiểm tra backend đang chạy, địa chỉ API và CORS)',
      );
    }

    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Lỗi server (${res.statusCode})';
    throw Exception(msg);
  }

  static Future<ApprovalResult> fetch({String? status, String search = ''}) async {
    final uri = Uri.parse('$kApiBase/owner/bookings').replace(
      queryParameters: {
        'status': status ?? 'ALL',
        if (search.isNotEmpty) 'search': search,
      },
    );
    final body = await _run(http.get(uri, headers: await _headers())) as Map<String, dynamic>;
    final counts = <String, int>{};
    (body['counts'] as Map<String, dynamic>? ?? {}).forEach(
      (k, v) => counts[k.toString().toUpperCase()] = _int(v),
    );
    final data = (body['data'] as List)
        .map((e) => ApprovalBooking.fromJson(e as Map<String, dynamic>))
        .toList();
    return ApprovalResult(counts, data);
  }

  static Future<void> approve(int id) async {
    await _run(
      http.patch(
        Uri.parse('$kApiBase/owner/bookings/$id/approve'),
        headers: await _headers(),
      ),
    );
  }

  static Future<void> reject(int id, String reason, double refund) async {
    await _run(
      http.patch(
        Uri.parse('$kApiBase/owner/bookings/$id/reject'),
        headers: await _headers(),
        body: jsonEncode({'reason': reason, 'refund_amount': refund}),
      ),
    );
  }

  static Future<bool> getAutoApprove() async {
    final body = await _run(
      http.get(
        Uri.parse('$kApiBase/owner/settings/auto-approve'),
        headers: await _headers(),
      ),
    ) as Map<String, dynamic>;
    return body['enabled'] == true;
  }

  /// Trả về số đơn đang chờ đã được duyệt luôn (khi approvePending = true)
  static Future<int> setAutoApprove(
    bool enabled, {
    bool approvePending = false,
  }) async {
    final body = await _run(
      http.put(
        Uri.parse('$kApiBase/owner/settings/auto-approve'),
        headers: await _headers(),
        body: jsonEncode({'enabled': enabled, 'approve_pending': approvePending}),
      ),
    ) as Map<String, dynamic>;
    return _int(body['approved_count']);
  }
}

// ===================== HELPER HIỂN THỊ =====================
String _money(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf VNĐ';
}

String _two(int n) => n.toString().padLeft(2, '0');

String _fmtDT(DateTime? d) =>
    d == null ? '—' : '${_two(d.hour)}:${_two(d.minute)} ${_two(d.day)}/${_two(d.month)}/${d.year}';

String _fmtDate(String ymd) {
  final p = ymd.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : ymd;
}

String _statusLabel(String s) {
  switch (s) {
    case 'PENDING':
      return 'Chờ duyệt';
    case 'CONFIRMED':
      return 'Đã duyệt';
    case 'PAID':
      return 'Đã duyệt';
    case 'CHECKED_IN':
      return 'Đã nhận sân';
    case 'CANCELLED':
      return 'Đã hủy';
    default:
      return s;
  }
}

Color _statusColor(String s) {
  switch (s) {
    case 'PENDING':
      return Colors.orange;
    case 'CONFIRMED':
    case 'PAID':
      return Colors.green;
    case 'CHECKED_IN':
      return Colors.blue;
    case 'CANCELLED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

// ===================== MÀN HÌNH =====================
class OwnerApprovalScreen extends StatefulWidget {
  /// true khi nhúng vào tab "Duyệt đơn" (đã có AppBar + thanh điều hướng bên ngoài)
  final bool embedded;
  const OwnerApprovalScreen({super.key, this.embedded = false});

  @override
  State<OwnerApprovalScreen> createState() => _OwnerApprovalScreenState();
}

class _OwnerApprovalScreenState extends State<OwnerApprovalScreen> {
  static const List<(String?, String)> _tabs = [
    ('PENDING', 'Chờ duyệt'),
    ('PAID', 'Đã duyệt'),
    ('CANCELLED', 'Đã hủy'),
    (null, 'Tất cả'),
  ];

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  String? _filter = 'PENDING';
  bool _loading = true;
  String? _error;
  List<ApprovalBooking> _bookings = [];
  Map<String, int> _counts = {};
  final Set<int> _busy = {};

  // Tự động duyệt đơn
  bool _autoApprove = false;
  bool _autoLoaded = false;
  bool _autoBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadAutoApprove();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------- DATA ----------
  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final r = await ApprovalApi.fetch(
        status: _filter,
        search: _searchCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _bookings = r.data;
        _counts = r.counts;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _msg(e);
        _loading = false;
      });
    }
  }

  int _countFor(String? key) => key == null
      ? _counts.values.fold(0, (a, b) => a + b)
      : (_counts[key] ?? 0);

  void _toast(String text, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  // ---------- TỰ ĐỘNG DUYỆT ----------
  Future<void> _loadAutoApprove() async {
    try {
      final v = await ApprovalApi.getAutoApprove();
      if (!mounted) return;
      setState(() {
        _autoApprove = v;
        _autoLoaded = true;
      });
    } catch (_) {
      // Chưa đọc được cài đặt: công tắc tạm khóa, bấm tải lại để thử lại
    }
  }

  Future<void> _toggleAutoApprove(bool value) async {
    var approvePending = false;

    if (value) {
      final pending = _countFor('PENDING');
      final choice = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Bật tự động duyệt đơn?'),
          content: Text(
            pending > 0
                ? 'Từ giờ các đơn mới sẽ được duyệt ngay khi khách đặt.\n'
                    'Hiện có $pending đơn đang chờ duyệt, bạn muốn xử lý thế nào?'
                : 'Từ giờ các đơn mới sẽ được duyệt ngay khi khách đặt.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
            ),
            if (pending > 0)
              OutlinedButton(
                onPressed: () => Navigator.pop(c, 'new'),
                child: const Text('Chỉ đơn mới'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(c, pending > 0 ? 'all' : 'new'),
              child: Text(pending > 0 ? 'Duyệt luôn $pending đơn chờ' : 'Bật'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      approvePending = choice == 'all';
    }

    setState(() => _autoBusy = true);
    try {
      final approved = await ApprovalApi.setAutoApprove(
        value,
        approvePending: approvePending,
      );
      if (!mounted) return;
      setState(() => _autoApprove = value);
      _toast(
        value
            ? (approved > 0
                  ? 'Đã bật tự động duyệt và duyệt $approved đơn đang chờ'
                  : 'Đã bật tự động duyệt đơn')
            : 'Đã tắt tự động duyệt đơn',
        Colors.green[700]!,
      );
      await _load(showSpinner: false);
    } catch (e) {
      _toast(_msg(e), Colors.red[700]!);
    } finally {
      if (mounted) setState(() => _autoBusy = false);
    }
  }

  // ---------- HÀNH ĐỘNG ----------
  Future<void> _approve(ApprovalBooking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Duyệt đơn ${b.code}?'),
        content: Text(
          'Xác nhận duyệt đơn của ${b.customerName} (${_money(b.totalAmount)}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Duyệt đơn'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy.add(b.id));
    try {
      await ApprovalApi.approve(b.id);
      _toast('Đã duyệt đơn ${b.code}', Colors.green[700]!);
      await _load(showSpinner: false);
    } catch (e) {
      _toast(_msg(e), Colors.red[700]!);
    } finally {
      if (mounted) setState(() => _busy.remove(b.id));
    }
  }

  Future<void> _reject(ApprovalBooking b) async {
    final result = await showDialog<_RejectResult>(
      context: context,
      builder: (_) => _RejectDialog(booking: b),
    );
    if (result == null) return;

    setState(() => _busy.add(b.id));
    try {
      await ApprovalApi.reject(b.id, result.reason, result.refund);
      _toast('Đã từ chối đơn ${b.code}', Colors.red[600]!);
      await _load(showSpinner: false);
    } catch (e) {
      _toast(_msg(e), Colors.red[700]!);
    } finally {
      if (mounted) setState(() => _busy.remove(b.id));
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildAutoApproveCard(),
        _buildSearch(),
        _buildFilters(),
        Expanded(child: _buildList()),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Duyệt đơn'),
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildAutoApproveCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _autoApprove ? _kGreen : Colors.grey.shade300,
          ),
        ),
        child: SwitchListTile(
          dense: true,
          secondary: Icon(
            Icons.bolt,
            color: _autoApprove ? _kGreen : Colors.grey,
          ),
          title: const Text(
            'Tự động duyệt đơn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            _autoApprove
                ? 'Đang bật: đơn mới được duyệt ngay, không cần chờ chủ sân'
                : 'Đang tắt: đơn mới ở trạng thái chờ chủ sân duyệt',
            style: const TextStyle(fontSize: 12),
          ),
          value: _autoApprove,
          onChanged: (_autoLoaded && !_autoBusy) ? _toggleAutoApprove : null,
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) {
          _debounce?.cancel();
          _debounce = Timer(
            const Duration(milliseconds: 400),
            () => _load(showSpinner: false),
          );
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo mã đơn, tên hoặc số điện thoại',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: _tabs.map((t) {
          final selected = _filter == t.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${t.$2} (${_countFor(t.$1)})'),
              selected: selected,
              selectedColor: _kGreen,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              onSelected: (_) {
                if (_filter == t.$1) return;
                setState(() => _filter = t.$1);
                _load();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      child: _bookings.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'Không có đơn nào',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _bookings.length,
              itemBuilder: (_, i) => _buildCard(_bookings[i]),
            ),
    );
  }

  Widget _buildCard(ApprovalBooking b) {
    final busy = _busy.contains(b.id);
    final isPending = b.status == 'PENDING';
    final contact = [b.customerName, b.customerPhone]
        .where((s) => s.isNotEmpty)
        .join(' • ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    b.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                _statusTag(b.status),
              ],
            ),
            const Divider(height: 20),
            _infoRow(Icons.person_outline, contact),
            _infoRow(Icons.access_time, 'Đặt lúc: ${_fmtDT(b.createdAt)}'),
            if (b.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Chi tiết đặt sân',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              ...b.items.map(_itemRow),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền', style: TextStyle(fontSize: 13)),
                Text(
                  _money(b.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _kGreen,
                  ),
                ),
              ],
            ),
            if (b.status == 'CANCELLED') _buildCancelInfo(b),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Từ chối'),
                      onPressed: busy ? null : () => _reject(b),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Duyệt đơn'),
                      onPressed: busy ? null : () => _approve(b),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCancelInfo(ApprovalBooking b) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hủy lúc: ${_fmtDT(b.cancelledAt)}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            'Hoàn tiền: ${_money(b.refundAmount)}',
            style: const TextStyle(fontSize: 12),
          ),
          if ((b.cancellationReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Lý do: ${b.cancellationReason}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusTag(String s) {
    final c = _statusColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusLabel(s),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _itemRow(BookingItem it) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.sports_tennis, size: 15, color: _kGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${it.courtName} • ${_fmtDate(it.bookingDate)} • ${it.startTime}-${it.endTime}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            _money(it.price),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ===================== DIALOG TỪ CHỐI =====================
class _RejectResult {
  final String reason;
  final double refund;
  _RejectResult(this.reason, this.refund);
}

class _RejectDialog extends StatefulWidget {
  final ApprovalBooking booking;
  const _RejectDialog({required this.booking});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonCtrl = TextEditingController();
  late final TextEditingController _refundCtrl = TextEditingController(
    text: widget.booking.totalAmount.round().toString(),
  );

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _refundCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Từ chối đơn ${b.code}', style: const TextStyle(fontSize: 17)),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 2,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Lý do từ chối *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập lý do'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _refundCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền hoàn lại (VNĐ)',
                  helperText: 'Tối đa ${_money(b.totalAmount)}',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null || n < 0) return 'Số tiền không hợp lệ';
                  if (n > b.totalAmount) return 'Vượt quá tổng tiền đơn';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _RejectResult(
                _reasonCtrl.text.trim(),
                double.parse(_refundCtrl.text.trim()),
              ),
            );
          },
          child: const Text('Xác nhận từ chối'),
        ),
      ],
    );
  }
}
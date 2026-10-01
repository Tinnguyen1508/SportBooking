// routes/bookingRoutes.js
// Khách đặt sân: POST /api/bookings
// Trạng thái đơn mới do công tắc "Tự động duyệt đơn" quyết định:
//   bật  -> PAID (đã duyệt ngay)      tắt -> PENDING (chờ chủ sân duyệt)

const express = require('express');
const jwt = require('jsonwebtoken');
const { QueryTypes } = require('sequelize');
const { sequelize } = require('../config/db.js');
const approval = require('./Approvalroutes.js'); // dùng approval.getInitialBookingStatus()

const router = express.Router();

// ===================== GIẢ ĐỊNH VỀ DATABASE (sửa nếu khác) =====================
//   courts(id, price_slot)                     -> giá MỖI Ô 30 PHÚT của sân (đổi tên cột ở dòng dưới)
//   booking_details(booking_id, court_id, booking_date, start_time, end_time, price)
const COURT_PRICE_COLUMN = 'price_slot';

const OPEN_MIN = 6 * 60;        // 06:00
const CLOSE_MIN = 23 * 60 + 30; // 23:30 (ô cuối: 23:00 - 23:30)

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
const TIME_RE = /^([01]\d|2[0-3]):[0-5]\d$/;
const toMin = (t) => {
  const [h, m] = t.split(':').map(Number);
  return h * 60 + m;
};

const httpError = (status, message) => Object.assign(new Error(message), { http: status });

const errMsg = (e) => {
  if (process.env.NODE_ENV === 'production') return 'Lỗi server';
  const inner = (e && e.errors && e.errors[0]) || (e && e.parent) || (e && e.original) || e;
  return (inner && inner.message) || (e && e.message) || 'Lỗi không xác định';
};

function todayStr() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

// ===================== XÁC THỰC =====================
function requireLogin(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ success: false, message: 'Vui lòng đăng nhập' });

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const uid = payload.id ?? payload.userId ?? payload.user_id;
    if (!uid) {
      return res.status(401).json({ success: false, message: 'Token không chứa mã người dùng' });
    }
    req.userId = uid;
    next();
  } catch (e) {
    res.status(401).json({ success: false, message: 'Phiên đăng nhập hết hạn hoặc không hợp lệ' });
  }
}

// ===================== KIỂM TRA DỮ LIỆU GỬI LÊN =====================
function validateItems(items) {
  if (!Array.isArray(items) || items.length === 0 || items.length > 20) {
    return 'Vui lòng chọn từ 1 đến 20 khung giờ';
  }
  const today = todayStr();

  for (const it of items) {
    if (!Number.isInteger(it.court_id)) return 'Thiếu hoặc sai mã sân (court_id)';
    if (!DATE_RE.test(it.booking_date || '')) return 'Ngày đặt không hợp lệ (yyyy-MM-dd)';
    if (it.booking_date < today) return 'Không thể đặt sân cho ngày đã qua';
    if (!TIME_RE.test(it.start_time || '') || !TIME_RE.test(it.end_time || '')) {
      return 'Giờ không hợp lệ (HH:mm)';
    }
    const s = toMin(it.start_time);
    const e = toMin(it.end_time);
    if (e <= s) return 'Giờ kết thúc phải sau giờ bắt đầu';
    if (s % 30 !== 0 || e % 30 !== 0) return 'Giờ đặt phải theo bội số 30 phút';
    if (s < OPEN_MIN || e > CLOSE_MIN) return 'Giờ đặt nằm ngoài giờ mở cửa (06:00 - 23:30)';
  }

  // Các khung giờ trong cùng một đơn không được chồng nhau
  for (let i = 0; i < items.length; i++) {
    for (let j = i + 1; j < items.length; j++) {
      const a = items[i];
      const b = items[j];
      if (
        a.court_id === b.court_id &&
        a.booking_date === b.booking_date &&
        toMin(a.start_time) < toMin(b.end_time) &&
        toMin(b.start_time) < toMin(a.end_time)
      ) {
        return 'Các khung giờ trong đơn bị trùng nhau';
      }
    }
  }
  return null;
}

// ===================== POST /api/bookings =====================
// Body: { items: [{ court_id, booking_date: 'yyyy-MM-dd', start_time: 'HH:mm', end_time: 'HH:mm' }] }
router.post('/', requireLogin, async (req, res) => {
  const items = req.body.items;
  const invalid = validateItems(items);
  if (invalid) return res.status(400).json({ success: false, message: invalid });

  try {
    // Đọc công tắc tự động duyệt (lỗi -> PENDING cho an toàn)
    const status = await approval.getInitialBookingStatus();

    const result = await sequelize.transaction(async (t) => {
      const q = (text, replacements = {}) =>
        sequelize.query(text, { replacements, type: QueryTypes.SELECT, transaction: t });

      let total = 0;
      const priced = [];

      for (const it of items) {
        const court = await q(
          `SELECT ${COURT_PRICE_COLUMN} AS price_slot FROM courts WHERE id = :id`,
          { id: it.court_id }
        );
        if (!court.length) throw httpError(404, `Sân #${it.court_id} không tồn tại`);

        // Khóa dòng để hai khách không đặt trùng cùng lúc
        const clash = await q(
          `SELECT TOP 1 1 AS x
           FROM booking_details d WITH (UPDLOCK, HOLDLOCK)
           JOIN bookings b ON b.id = d.booking_id
           WHERE d.court_id = :court AND d.booking_date = :date
             AND b.status <> 'CANCELLED'
             AND d.start_time < :endTime AND d.end_time > :startTime`,
          {
            court: it.court_id,
            date: it.booking_date,
            startTime: it.start_time,
            endTime: it.end_time,
          }
        );
        if (clash.length) {
          throw httpError(
            409,
            `Sân #${it.court_id} đã có người đặt ${it.start_time}-${it.end_time} ngày ${it.booking_date}`
          );
        }

        const slots = (toMin(it.end_time) - toMin(it.start_time)) / 30;
        const price = Number(court[0].price_slot) * slots;
        priced.push({ ...it, price });
        total += price;
      }

      const code = 'BK-' + Date.now().toString(36).toUpperCase();

      const ins = await q(
        `INSERT INTO bookings (user_id, booking_code, total_amount, status, created_at)
         VALUES (:uid, :code, :total, :status, SYSDATETIME());
         SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS id;`,
        { uid: req.userId, code, total, status }
      );
      const bookingId = ins[0].id;

      for (const it of priced) {
        await sequelize.query(
          `INSERT INTO booking_details
             (booking_id, court_id, booking_date, start_time, end_time, price)
           VALUES (:bid, :court, :date, :startTime, :endTime, :price)`,
          {
            replacements: {
              bid: bookingId,
              court: it.court_id,
              date: it.booking_date,
              startTime: it.start_time,
              endTime: it.end_time,
              price: it.price,
            },
            transaction: t,
          }
        );
      }

      return { code, total };
    });

    res.status(201).json({
      success: true,
      message: status === 'PENDING' ? 'Đặt sân thành công, chờ chủ sân duyệt' : 'Đặt sân thành công, đơn đã được duyệt',
      booking_code: result.code,
      status,
      total_amount: result.total,
      auto_approved: status !== 'PENDING',
    });
  } catch (e) {
    if (e.http) return res.status(e.http).json({ success: false, message: e.message });
    console.error('POST /bookings', e);
    res.status(500).json({ success: false, message: 'Không tạo được đơn: ' + errMsg(e) });
  }
});

module.exports = router;
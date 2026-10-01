// routes/approvalRoutes.js
// Chức năng "Duyệt đơn" cho chủ sân - dùng kết nối Sequelize có sẵn (SQL Server)

const express = require('express');
const { QueryTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const router = express.Router();

// Bỏ comment nếu muốn bắt buộc đăng nhập (dùng middleware có sẵn của bạn)
// const auth = require('../middleware/auth');
// router.use(auth);

// ===================== TRẠNG THÁI =====================
// Đổi giá trị cho khớp với dữ liệu / CHECK constraint trong DB của bạn
const STATUS = {
  PENDING: 'PENDING',     // chờ duyệt
  APPROVED: 'PAID',       // đã duyệt (DB chỉ cho phép: PENDING, PAID, CHECKED_IN, CANCELLED)
  REJECTED: 'CANCELLED',  // đã từ chối / hủy
};

// In ra khi backend khởi động để biết đang chạy đúng bản code này
console.log('✅ approvalRoutes đã nạp - trạng thái "đã duyệt" =', STATUS.APPROVED);

// ===================== GIẢ ĐỊNH VỀ CÁC BẢNG KHÁC =====================
// bookings: đúng như ảnh bạn gửi.  users(id, full_name, phone): đúng như seedMockUsers.js.
// Hai bảng dưới là GIẢ ĐỊNH, hãy sửa tên bảng/cột nếu khác (xem thư mục models/):
//   booking_details(booking_id, court_id, booking_date, start_time, end_time, price)
//   courts(id, name)

const select = (text, replacements = {}) =>
  sequelize.query(text, { replacements, type: QueryTypes.SELECT });

// SQL Server qua Sequelize hay trả AggregateError có message rỗng -> lấy message trong errors[0] / parent
const errMsg = (e) => {
  if (process.env.NODE_ENV === 'production') return 'Lỗi server';
  const inner = (e && e.errors && e.errors[0]) || (e && e.parent) || (e && e.original) || e;
  return (inner && inner.message) || (e && e.message) || String(e) || 'Lỗi không xác định';
};

// ===================== GET /api/owner/bookings =====================
// Query: ?status=PENDING|CONFIRMED|CANCELLED|ALL  &search=từ khóa (mã đơn / tên / sđt)
router.get('/owner/bookings', async (req, res) => {
  try {
    const status = (req.query.status || '').toString().trim().toUpperCase();
    const search = (req.query.search || '').toString().trim();

    const bookings = await select(
      `SELECT TOP (200)
              b.id, b.user_id, b.booking_code, b.total_amount, b.status,
              CONVERT(varchar(19), b.created_at, 120)   AS created_at,
              CONVERT(varchar(19), b.cancelled_at, 120) AS cancelled_at,
              b.refund_amount, b.cancellation_reason,
              u.full_name AS customer_name, u.phone AS customer_phone
       FROM bookings b
       LEFT JOIN users u ON u.id = b.user_id
       WHERE (:status IS NULL OR b.status = :status)
         AND (:like IS NULL OR b.booking_code LIKE :like
              OR u.full_name LIKE :like OR u.phone LIKE :like)
       ORDER BY CASE WHEN b.status = :pending THEN 0 ELSE 1 END, b.created_at DESC`,
      {
        status: status && status !== 'ALL' ? status : null,
        like: search ? `%${search}%` : null,
        pending: STATUS.PENDING,
      }
    );

    // Chi tiết khung giờ của các đơn trên
    bookings.forEach((b) => (b.items = []));
    if (bookings.length) {
      try {
      const items = await select(
        `SELECT d.booking_id, d.court_id, c.name AS court_name, d.price,
                CONVERT(varchar(10), d.booking_date, 23) AS booking_date,
                CONVERT(varchar(5), d.start_time, 108)   AS start_time,
                CONVERT(varchar(5), d.end_time, 108)     AS end_time
         FROM booking_details d
         LEFT JOIN courts c ON c.id = d.court_id
         WHERE d.booking_id IN (:ids)
         ORDER BY d.booking_date, d.start_time`,
        { ids: bookings.map((b) => b.id) }
      );
      const byBooking = {};
      for (const it of items) {
        (byBooking[it.booking_id] = byBooking[it.booking_id] || []).push(it);
      }
      bookings.forEach((b) => (b.items = byBooking[b.id] || []));
      } catch (e) {
        // Sai tên bảng/cột booking_details, courts -> vẫn trả danh sách đơn, chỉ thiếu chi tiết
        console.warn('Không lấy được chi tiết khung giờ (kiểm tra tên bảng booking_details / courts):', errMsg(e));
      }
    }

    // Số lượng theo từng trạng thái (cho các tab)
    const cnt = await select('SELECT status, COUNT(*) AS cnt FROM bookings GROUP BY status');
    const counts = {};
    cnt.forEach((r) => (counts[r.status] = r.cnt));

    res.json({ counts, data: bookings });
  } catch (e) {
    console.error('GET /owner/bookings', e);
    res.status(500).json({ message: 'Không lấy được danh sách đơn: ' + errMsg(e) });
  }
});

// ===================== PATCH /api/owner/bookings/:id/approve =====================
router.patch('/owner/bookings/:id/approve', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (!Number.isInteger(id)) return res.status(400).json({ message: 'ID không hợp lệ' });

  try {
    const rows = await select(
      `UPDATE bookings SET status = :approved WHERE id = :id AND status = :pending;
       SELECT @@ROWCOUNT AS n;`,
      { id, approved: STATUS.APPROVED, pending: STATUS.PENDING }
    );
    const n = rows.length ? rows[0].n : 0;
    if (n === 0) {
      return res.status(409).json({ message: 'Đơn không tồn tại hoặc không còn ở trạng thái chờ duyệt' });
    }
    res.json({ message: 'Đã duyệt đơn' });
  } catch (e) {
    console.error('approve', e);
    res.status(500).json({ message: 'Lỗi duyệt đơn: ' + errMsg(e) });
  }
});

// ===================== PATCH /api/owner/bookings/:id/reject =====================
// Body: { reason: string (bắt buộc), refund_amount: number (0 .. total_amount) }
router.patch('/owner/bookings/:id/reject', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const reason = (req.body.reason || '').toString().trim();
  const refund = Number(req.body.refund_amount ?? 0);

  if (!Number.isInteger(id)) return res.status(400).json({ message: 'ID không hợp lệ' });
  if (!reason) return res.status(400).json({ message: 'Vui lòng nhập lý do từ chối' });
  if (!Number.isFinite(refund) || refund < 0) {
    return res.status(400).json({ message: 'Số tiền hoàn không hợp lệ' });
  }

  try {
    const cur = await select('SELECT status, total_amount FROM bookings WHERE id = :id', { id });
    if (!cur.length) return res.status(404).json({ message: 'Không tìm thấy đơn' });

    if (cur[0].status !== STATUS.PENDING) {
      return res.status(409).json({ message: 'Đơn không còn ở trạng thái chờ duyệt' });
    }
    if (refund > Number(cur[0].total_amount)) {
      return res.status(400).json({ message: 'Số tiền hoàn vượt quá tổng tiền đơn' });
    }

    const rows = await select(
      `UPDATE bookings
       SET status = :rejected,
           cancelled_at = SYSDATETIME(),
           cancellation_reason = :reason,
           refund_amount = :refund
       WHERE id = :id AND status = :pending;
       SELECT @@ROWCOUNT AS n;`,
      { id, rejected: STATUS.REJECTED, reason, refund, pending: STATUS.PENDING }
    );
    const n = rows.length ? rows[0].n : 0;
    if (n === 0) {
      return res.status(409).json({ message: 'Đơn vừa được xử lý ở nơi khác, hãy tải lại' });
    }
    res.json({ message: 'Đã từ chối đơn' });
  } catch (e) {
    console.error('reject', e);
    res.status(500).json({ message: 'Lỗi từ chối đơn: ' + errMsg(e) });
  }
});

// ===================== TỰ ĐỘNG DUYỆT ĐƠN =====================
// Cài đặt lưu trong bảng app_settings (tự tạo nếu chưa có). Hiện áp dụng chung cho cả hệ thống.
const AUTO_KEY = 'auto_approve_bookings';

let settingsReady;
function ensureSettingsTable() {
  if (!settingsReady) {
    settingsReady = sequelize
      .query(`
        IF OBJECT_ID('dbo.app_settings', 'U') IS NULL
          CREATE TABLE dbo.app_settings (
            setting_key   NVARCHAR(100) NOT NULL PRIMARY KEY,
            setting_value NVARCHAR(500) NOT NULL,
            updated_at    DATETIME2 NOT NULL DEFAULT SYSDATETIME()
          );`)
      .catch((e) => {
        settingsReady = undefined; // thử lại lần sau
        throw e;
      });
  }
  return settingsReady;
}

async function isAutoApproveEnabled() {
  await ensureSettingsTable();
  const rows = await select('SELECT setting_value FROM app_settings WHERE setting_key = :k', {
    k: AUTO_KEY,
  });
  return rows.length > 0 && rows[0].setting_value === '1';
}

async function setAutoApprove(enabled) {
  await ensureSettingsTable();
  await sequelize.query(
    `UPDATE app_settings SET setting_value = :v, updated_at = SYSDATETIME() WHERE setting_key = :k;
     IF @@ROWCOUNT = 0 INSERT INTO app_settings (setting_key, setting_value) VALUES (:k, :v);`,
    { replacements: { k: AUTO_KEY, v: enabled ? '1' : '0' } }
  );
}

// Trạng thái ban đầu cho đơn MỚI: PAID nếu đang bật tự động duyệt, ngược lại PENDING.
// Lỗi bất kỳ -> an toàn nhất là để PENDING (chủ sân tự duyệt).
// Route tạo đơn của khách gọi hàm này khi INSERT vào bookings.
async function getInitialBookingStatus() {
  try {
    return (await isAutoApproveEnabled()) ? STATUS.APPROVED : STATUS.PENDING;
  } catch (e) {
    console.error('getInitialBookingStatus', errMsg(e));
    return STATUS.PENDING;
  }
}

// ===================== GET /api/owner/settings/auto-approve =====================
router.get('/owner/settings/auto-approve', async (req, res) => {
  try {
    res.json({ enabled: await isAutoApproveEnabled() });
  } catch (e) {
    console.error('get auto-approve', e);
    res.status(500).json({ message: 'Không đọc được cài đặt tự động duyệt: ' + errMsg(e) });
  }
});

// ===================== PUT /api/owner/settings/auto-approve =====================
// Body: { enabled: boolean, approve_pending: boolean }
// approve_pending = true (chỉ có tác dụng khi enabled = true): duyệt luôn các đơn đang chờ
router.put('/owner/settings/auto-approve', async (req, res) => {
  const { enabled, approve_pending } = req.body;
  if (typeof enabled !== 'boolean') {
    return res.status(400).json({ message: 'Thiếu hoặc sai giá trị enabled (true/false)' });
  }

  try {
    await setAutoApprove(enabled);

    let approvedCount = 0;
    if (enabled && approve_pending === true) {
      const rows = await select(
        `UPDATE bookings SET status = :approved WHERE status = :pending;
         SELECT @@ROWCOUNT AS n;`,
        { approved: STATUS.APPROVED, pending: STATUS.PENDING }
      );
      approvedCount = rows.length ? rows[0].n : 0;
    }

    res.json({ enabled, approved_count: approvedCount });
  } catch (e) {
    console.error('set auto-approve', e);
    res.status(500).json({ message: 'Không lưu được cài đặt tự động duyệt: ' + errMsg(e) });
  }
});

// Cho phép route tạo đơn dùng: require('./Approvalroutes.js').getInitialBookingStatus()
router.getInitialBookingStatus = getInitialBookingStatus;
router.isAutoApproveEnabled = isAutoApproveEnabled;

module.exports = router;
const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const { connectDB } = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const districtRoutes = require('./routes/districtRoutes');
// Nếu bạn đổi tên file thành approvalRoutes.js thì sửa lại dòng này cho khớp
const approvalRoutes = require('./routes/Approvalroutes.js');
const bookingRoutes = require('./routes/bookingRoutes'); // Khách đặt sân (tự động duyệt nếu bật)

const app = express();

// ===================== MIDDLEWARE =====================
app.use(
  cors({
    origin: '*', // Cho phép mọi domain (bao gồm localhost của Flutter Web)
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'], // PATCH cho Duyệt đơn
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);
app.use(express.json());

// Cho phép truy cập public các file trong thư mục uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ===================== ROUTES =====================
app.get('/', (req, res) => {
  res.json({ message: 'SportBooking API đang chạy' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/districts', districtRoutes);
app.use('/api', approvalRoutes); // Duyệt đơn: /api/owner/bookings...
app.use('/api/bookings', bookingRoutes); // Khách đặt sân: POST /api/bookings

// Đường dẫn không tồn tại -> trả JSON thay vì "Cannot GET ..."
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Không tìm thấy đường dẫn: ${req.method} ${req.originalUrl}`,
  });
});

// Lỗi không bắt được ở route -> trả JSON, không làm sập server
app.use((err, req, res, next) => {
  console.error('Lỗi server:', err);
  res.status(500).json({ success: false, message: 'Lỗi server' });
});

// ===================== KHỞI ĐỘNG =====================
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`🚀 Server đang chạy tại cổng ${PORT}`);
    });
  } catch (error) {
    console.error('Không thể khởi động server:', error);
    process.exit(1);
  }
};

startServer();
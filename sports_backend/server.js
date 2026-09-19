const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { connectDB } = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const app = express();

app.use(cors({origin: '*', // Cho phép mọi domain (bao gồm localhost của Flutter Web)
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']}));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
const PORT = process.env.PORT || 5000;

const startServer = async () => {
    await connectDB();
    app.listen(PORT, () => {
        console.log(`🚀 Server đang chạy tại cổng ${PORT}`);
    });
};
const path = require('path');

// Thêm dòng này để cho phép truy cập public các file trong thư mục uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
startServer();
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(process.env.DB_NAME || 'BadmintonBookingDB', process.env.DB_USER || 'sa', process.env.DB_PASS || '15082006', {
    dialect: 'mssql',
    host: '127.0.0.1', // Dùng 127.0.0.1 thay vì localhost
    logging: false,
    dialectOptions: {
        options: {
            instanceName: 'SQLEXPRESS02',
            encrypt: false,
            trustServerCertificate: true,
            enableArithAbort: true
        }
    }
});

const connectDB = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Kết nối SQL Server thành công!');
    } catch (error) {
        console.error('❌ Lỗi kết nối SQL Server:', error.message);
        process.exit(1);
    }
};

module.exports = { sequelize, connectDB };
const { Sequelize } = require('sequelize');
require('dotenv').config();

for (const variable of ['DB_NAME', 'DB_USER', 'DB_PASS']) {
  if (!process.env[variable]) {
    throw new Error(`Missing required environment variable: ${variable}`);
  }
}

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    dialect: 'mssql',
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number.parseInt(process.env.DB_PORT || '1433', 10),
    logging: false,
    dialectOptions: {
      options: {
        encrypt: false,
        trustServerCertificate: true,
        enableArithAbort: true,
      },
    },
  },
);

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

const bcrypt = require('bcryptjs');
const { Op } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('../models/User');

const mockPassword = 'Sport@123';
const mockUsers = [
    {
        full_name: 'Nguyễn Minh Anh',
        phone: '0000000001',
        email: 'minhanh.customer@example.test',
        role: 'CUSTOMER',
        avatar_url: null
    },
    {
        full_name: 'Trần Quốc Bảo',
        phone: '0000000002',
        email: 'quocbao.customer@example.test',
        role: 'CUSTOMER',
        avatar_url: null
    },
    {
        full_name: 'Lê Thị Ngọc',
        phone: '0000000003',
        email: 'ngoc.owner@example.test',
        role: 'OWNER',
        avatar_url: null
    },
    {
        full_name: 'Phạm Hoàng Nam',
        phone: '0000000004',
        email: 'hoangnam.owner@example.test',
        role: 'OWNER',
        avatar_url: null
    }
];

async function seedMockUsers() {
    await sequelize.authenticate();

    let created = 0;
    let skipped = 0;

    for (const mockUser of mockUsers) {
        const existingUser = await User.findOne({
            where: {
                [Op.or]: [
                    { phone: mockUser.phone },
                    { email: mockUser.email }
                ]
            }
        });

        if (existingUser) {
            console.log(`[BỎ QUA] ${mockUser.phone} đã tồn tại.`);
            skipped += 1;
            continue;
        }

        await User.create({
            ...mockUser,
            password_hash: await bcrypt.hash(mockPassword, 10),
            created_at: new Date()
        });

        console.log(`[ĐÃ TẠO] ${mockUser.role}: ${mockUser.phone} (${mockUser.email})`);
        created += 1;
    }

    console.log(`Hoàn tất: tạo ${created}, bỏ qua ${skipped}.`);
    console.log(`Mật khẩu dùng thử cho các tài khoản mới: ${mockPassword}`);
}

seedMockUsers()
    .catch((error) => {
        console.error('Không thể tạo mock users:', error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await sequelize.close();
    });

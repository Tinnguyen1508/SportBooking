const District = require('../models/District');

exports.getDistricts = async (req, res) => {
    try {
        const districts = await District.findAll({
            attributes: ['id', 'name', 'province_name'],
            order: [['province_name', 'ASC'], ['name', 'ASC']],
            raw: true
        });

        res.status(200).json(districts);
    } catch (error) {
        console.error('Lỗi getDistricts:', error);
        res.status(500).json({
            success: false,
            message: 'Không thể tải danh sách tỉnh/thành phố và quận/huyện.'
        });
    }
};

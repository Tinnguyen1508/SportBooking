const express = require('express');
const districtController = require('../controllers/districtController');

const router = express.Router();

router.get('/', districtController.getDistricts);

module.exports = router;

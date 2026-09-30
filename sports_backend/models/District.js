const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const District = sequelize.define('District', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        field: 'id'
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
        field: 'name'
    },
    province_name: {
        type: DataTypes.STRING,
        allowNull: false,
        field: 'province_name'
    }
}, {
    tableName: 'districts',
    schema: 'dbo',
    timestamps: false
});

module.exports = District;

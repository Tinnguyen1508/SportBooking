const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const User = sequelize.define('User', {
    id: {
        type: DataTypes.BIGINT,
        primaryKey: true,
        autoIncrement: true,
        field: 'id'
    },
    phone: {
        type: DataTypes.STRING(15),
        allowNull: false,
        field: 'phone'
    },
    password_hash: {
        type: DataTypes.STRING(255),
        allowNull: true,
        field: 'password_hash'
    },
    full_name: {
        type: DataTypes.STRING(100),
        allowNull: true,
        field: 'full_name'
    },
    role: {
        type: DataTypes.STRING(20),
        allowNull: false,
        field: 'role'
    },
    email: {
        type: DataTypes.STRING(100),
        allowNull: true,
        field: 'email'
    },
    avatar_url: {
        type: DataTypes.STRING(500),
        allowNull: true,
        field: 'avatar_url'
    },
    created_at: {
        type: DataTypes.DATE,
        allowNull: true,
        field: 'created_at'
    }
}, {
    tableName: 'users',
    schema: 'dbo',
    timestamps: false
});

module.exports = User;
const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

// Listar todos los usuarios
router.get('/users', adminController.getAllUsers);

// Borrar un usuario (Profesional/Particular)
// Flutter llama a: /api/admin/users/:id
router.delete('/users/:id', adminController.deleteUser);

// Listar propiedades (Vista de tabla admin)
router.get('/properties', adminController.getAllProperties);

module.exports = router;
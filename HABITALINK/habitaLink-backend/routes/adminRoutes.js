const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');


//console.log("Funciones cargadas:", Object.keys(adminController));

// GESTIÓN DE USUARIOS
router.get('/users', adminController.getAllUsers);
router.delete('/users/:id', adminController.deleteUser);

// GESTIÓN DE INMUEBLES
router.get('/properties', adminController.getAllProperties);
router.put('/properties/:id/status', adminController.updatePropertyStatus);

module.exports = router;
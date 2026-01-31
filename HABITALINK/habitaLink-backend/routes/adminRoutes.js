const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

// ✅ Ahora 'adminController.obtenerInformeGeneral' NO es undefined, es la función de arriba
// La URL completa será: http://localhost:3000/api/admin/informe
router.get('/informe', adminController.obtenerInformeGeneral);

module.exports = router;
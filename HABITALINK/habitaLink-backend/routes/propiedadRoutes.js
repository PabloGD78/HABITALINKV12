const express = require('express');
const router = express.Router();
const propiedadController = require('../controllers/propiedadController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// --- Configuración Multer (Fotos) ---
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const uploadPath = 'uploads/';
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// --- RUTAS ---

// Crear propiedad (con hasta 8 fotos)
router.post('/crear', upload.array('imagenes', 8), propiedadController.crearPropiedad);

// Obtener todas (público)
router.get('/', propiedadController.obtenerPropiedades);

// Obtener detalle
router.get('/:id', propiedadController.obtenerDetallePropiedad);

// --- ZONA ADMIN ---

// ✅ CORREGIDO: Antes tenías '/:id/aprobar'. Lo cambiamos a '/:id/estado' para que Flutter lo encuentre.
router.put('/:id/estado', propiedadController.aprobarPropiedad); 

// ✅ AÑADIDO: Faltaba esta ruta, por eso el botón de borrar no hacía nada.
router.delete('/:id', propiedadController.eliminarPropiedad);

module.exports = router;
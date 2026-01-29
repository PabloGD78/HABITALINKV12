const express = require('express');
const router = express.Router();
const propiedadController = require('../controllers/propiedadController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// --- 1. CONFIGURACIÓN DE IMÁGENES (MULTER) ---
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

// --- 2. DEFINICIÓN DE RUTAS ---
// A) Crear una propiedad
router.post('/crear', upload.array('imagenes', 8), propiedadController.crearPropiedad);

// B) Ver TODAS las propiedades
router.get('/', propiedadController.obtenerPropiedades);

// C) Ver propiedades de un usuario
router.get('/usuario/:id_usuario', propiedadController.obtenerMisAnuncios);

// D) Ver detalle de una propiedad por ID
router.get('/:id', propiedadController.obtenerPropiedadDetalle);

// ✅ E) Editar una propiedad existente
router.put(
    '/editar/:id',
    upload.array('imagenes', 8), // Permite subir nuevas imágenes
    propiedadController.editarPropiedad
);

module.exports = router;

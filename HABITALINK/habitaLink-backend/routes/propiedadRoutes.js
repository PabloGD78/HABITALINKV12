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
        // Crear carpeta si no existe
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        cb(null, uploadPath);
    },
    filename: function (req, file, cb) {
        // Nombre único: fecha + extensión original
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// --- 2. DEFINICIÓN DE RUTAS ---

// A) Crear una propiedad (POST) -> Acepta hasta 8 imágenes
router.post('/crear', upload.array('imagenes', 8), propiedadController.crearPropiedad);

// B) Ver TODAS las propiedades (Para el buscador general)
router.get('/', propiedadController.obtenerPropiedades);

// ✅ C) NUEVO: Ver SOLO las propiedades de un usuario específico (Para el Dashboard)
router.get('/usuario/:id_usuario', propiedadController.obtenerMisAnuncios);

// D) Ver detalle de una propiedad por ID (Para la pantalla de detalle)
router.get('/:id', propiedadController.obtenerPropiedadDetalle);

module.exports = router;
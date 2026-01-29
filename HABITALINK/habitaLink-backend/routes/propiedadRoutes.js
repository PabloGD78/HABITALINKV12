const express = require('express');
const router = express.Router();
const propiedadController = require('../controllers/propiedadController');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 1. Configurar dónde se guardan las fotos (Storage)
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

// 2. Definir las Rutas (Endpoints)
router.post('/crear', upload.array('imagenes', 8), propiedadController.crearPropiedad);
router.get('/', propiedadController.obtenerPropiedades);
router.get('/:id', propiedadController.obtenerPropiedadDetalle);
router.put('/:id/aprobar', propiedadController.aprobarPropiedad); // Ruta para aprobar
router.delete('/:id', propiedadController.eliminarPropiedad);
module.exports = router;

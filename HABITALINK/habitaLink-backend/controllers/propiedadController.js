const PropiedadModel = require('../models/propiedadModel');

/**
 * CREAR PROPIEDAD (POST)
 */
exports.crearPropiedad = async (req, res) => {
    try {
        // Obtener múltiples imágenes si existen
        const imagenesUrls = [];
        if (req.files && Array.isArray(req.files) && req.files.length > 0) {
            req.files.forEach(f => {
                imagenesUrls.push(`/uploads/${f.filename}`);
            });
        }

        // 3️⃣ Preparar datos para el modelo
        const latitude = req.body.latitude ? Number(req.body.latitude) : 0.0;
        const longitude = req.body.longitude ? Number(req.body.longitude) : 0.0;
        
        // 🔍 DEBUG: Mostrar coordenadas recibidas
        console.log('📍 Coordenadas recibidas en crear propiedad:', {
            latitude,
            longitude,
            ubicacion: req.body.ubicacion,
            titulo: req.body.titulo,
        });
        
        const nuevaPropiedad = {
            id_usuario: req.body.id_usuario,
            titulo: req.body.titulo || '',
            precio: Number(req.body.precio) || 0,
            descripcion: req.body.descripcion || '',
            dormitorios: Number(req.body.dormitorios) || 0,
            banos: Number(req.body.banos) || 0,
            superficie: Number(req.body.superficie) || 0,
            tipo: req.body.tipo || '',
            ubicacion: req.body.ubicacion || 'Sevilla',
            
            // ✅ NUEVO: Capturamos las coordenadas enviadas desde Flutter
            // Las convertimos a Number para asegurar que MySQL las reciba como decimales
            latitude: latitude,
            longitude: longitude,
            
            caracteristicas: req.body.caracteristicas ? req.body.caracteristicas : null,
            imagenes: imagenesUrls,
        };

        // 4️⃣ Guardar en la base de datos
        // IMPORTANTE: Asegúrate de que PropiedadModel.crear use estos nuevos campos
        const propiedadId = await PropiedadModel.crear(nuevaPropiedad);

        return res.status(201).json({
            success: true,
            message: 'Propiedad creada exitosamente',
            propiedadId,
        });

    } catch (error) {
        console.error('🔥 Error al crear propiedad:', error);
        return res.status(500).json({
            success: false,
            message: 'Error interno del servidor al crear propiedad',
            error: error.message,
        });
    }
};

/**
 * OBTENER TODAS LAS PROPIEDADES (GET /)
 */
exports.obtenerPropiedades = async (req, res) => {
    try {
        const propiedades = await PropiedadModel.obtenerTodas();
        
        return res.status(200).json({
            success: true,
            propiedades: propiedades
        });
    } catch (error) {
        console.error('🔥 Error al obtener propiedades:', error);
        return res.status(500).json({
            success: false,
            message: 'Error interno del servidor al obtener propiedades',
            error: error.message
        });
    }
};

/**
 * 🔑 OBTENER DETALLES DE UNA SOLA PROPIEDAD (GET /:id)
 */
exports.obtenerPropiedadDetalle = async (req, res) => {
    try {
        const propertyId = req.params.id; 
        
        const propiedad = await PropiedadModel.obtenerPorId(propertyId);
        
        if (!propiedad) {
            return res.status(404).json({
                success: false,
                message: `Property with ref ${propertyId} not found.`, 
            });
        }

        return res.status(200).json({
            success: true,
            propiedad: propiedad 
        });

    } catch (error) {
        console.error('🔥 Error al obtener detalles de propiedad:', error);
        return res.status(500).json({
            success: false,
            message: 'Error interno del servidor al obtener detalles',
            error: error.message
        });
    }
};
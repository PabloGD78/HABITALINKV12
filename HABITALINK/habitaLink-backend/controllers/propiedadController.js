const PropiedadModel = require('../models/propiedadModel');
const db = require('../config/db'); // ✅ NECESARIO para la consulta directa

/**
 * 1. CREAR PROPIEDAD (POST)
 */
exports.crearPropiedad = async (req, res) => {
    try {
        // Procesar imágenes subidas
        const imagenesUrls = [];
        if (req.files && Array.isArray(req.files) && req.files.length > 0) {
            req.files.forEach(f => {
                imagenesUrls.push(`/uploads/${f.filename}`);
            });
        }

        console.log('📍 Coordenadas recibidas:', {
            lat: req.body.latitude,
            lon: req.body.longitude,
            titulo: req.body.titulo,
        });
        
        // Preparar objeto para el modelo
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
            // Aseguramos que sean números para MySQL
            latitude: req.body.latitude ? Number(req.body.latitude) : 0.0,
            longitude: req.body.longitude ? Number(req.body.longitude) : 0.0,
            caracteristicas: req.body.caracteristicas ? req.body.caracteristicas : null,
            imagenes: imagenesUrls,
        };

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
            message: 'Error interno al crear propiedad',
            error: error.message,
        });
    }
};

/**
 * 2. OBTENER TODAS LAS PROPIEDADES (Para el Feed)
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
            message: 'Error interno',
            error: error.message
        });
    }
};

/**
 * 3. OBTENER DETALLE DE UNA PROPIEDAD
 */
exports.obtenerPropiedadDetalle = async (req, res) => {
    try {
        const propertyId = req.params.id; 
        const propiedad = await PropiedadModel.obtenerPorId(propertyId);
        
        if (!propiedad) {
            return res.status(404).json({
                success: false,
                message: `Propiedad con id ${propertyId} no encontrada.`, 
            });
        }

        return res.status(200).json({
            success: true,
            propiedad: propiedad 
        });

    } catch (error) {
        console.error('🔥 Error al obtener detalle:', error);
        return res.status(500).json({
            success: false,
            message: 'Error interno',
            error: error.message
        });
    }
};

/**
 * ✅ 4. NUEVO: OBTENER PROPIEDADES DE UN USUARIO (Para tu Dashboard)
 * Esta función busca en la base de datos filtrando por ID de usuario.
 */
exports.obtenerMisAnuncios = async (req, res) => {
    try {
        const { id_usuario } = req.params;

        // CONSULTA SQL DIRECTA:
        // Asegúrate de que tu tabla se llame 'inmueble_anuncio' o 'propiedades'.
        // Si usas el mismo nombre que en tu modelo, probablemente sea 'inmueble_anuncio'.
        const [rows] = await db.execute(
            `SELECT * FROM inmueble_anuncio WHERE id_usuario = ? ORDER BY id DESC`, 
            [id_usuario]
        );

        // Procesamos las imágenes para enviar una URL limpia al frontend
        const dataProcesada = rows.map(item => {
            let imagenPrincipal = ''; // Imagen por defecto si no hay
            
            try {
                // Caso 1: La imagen viene como un string JSON '["ruta1", "ruta2"]'
                if (item.imagenes && (item.imagenes.startsWith('[') || item.imagenes.startsWith('{'))) {
                    const imgs = JSON.parse(item.imagenes);
                    if (Array.isArray(imgs) && imgs.length > 0) {
                        imagenPrincipal = imgs[0];
                    }
                } 
                // Caso 2: Ya es texto plano
                else if (item.imagenes) {
                    imagenPrincipal = item.imagenes;
                }
            } catch (e) {
                // Si falla el parseo, usamos el valor tal cual
                imagenPrincipal = item.imagenes;
            }

            return {
                ...item,
                imagenPrincipal: imagenPrincipal // Campo simplificado para el Flutter
            };
        });

        res.json({ success: true, data: dataProcesada });

    } catch (error) {
        console.error("🔥 Error obteniendo mis anuncios:", error);
        res.status(500).json({ success: false, message: "Error al cargar tus anuncios" });
    }
};
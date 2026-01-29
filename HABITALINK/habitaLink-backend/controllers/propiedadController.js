const PropiedadModel = require('../models/propiedadModel');
const db = require('../config/db');
const fs = require('fs');
const path = require('path');

/**
 * 1. CREAR PROPIEDAD
 */
exports.crearPropiedad = async (req, res) => {
    try {
        const imagenesUrls = [];
        if (req.files && req.files.length > 0) {
            req.files.forEach(f => imagenesUrls.push(`/uploads/${f.filename}`));
        }

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
            latitude: req.body.latitude ? Number(req.body.latitude) : 0.0,
            longitude: req.body.longitude ? Number(req.body.longitude) : 0.0,
            caracteristicas: req.body.caracteristicas || null,
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
 * 2. OBTENER TODAS LAS PROPIEDADES
 */
exports.obtenerPropiedades = async (req, res) => {
    try {
        const propiedades = await PropiedadModel.obtenerTodas();
        return res.status(200).json({ success: true, propiedades });
    } catch (error) {
        console.error('🔥 Error al obtener propiedades:', error);
        return res.status(500).json({ success: false, message: 'Error interno', error: error.message });
    }
};

/**
 * 3. OBTENER DETALLE DE UNA PROPIEDAD
 */
exports.obtenerPropiedadDetalle = async (req, res) => {
    try {
        const propertyId = req.params.id; 
        const propiedad = await PropiedadModel.obtenerPorId(propertyId);
        
        if (!propiedad) return res.status(404).json({ success: false, message: `Propiedad con id ${propertyId} no encontrada.` });

        return res.status(200).json({ success: true, propiedad });
    } catch (error) {
        console.error('🔥 Error al obtener detalle:', error);
        return res.status(500).json({ success: false, message: 'Error interno', error: error.message });
    }
};

/**
 * 4. OBTENER PROPIEDADES DE UN USUARIO
 */
exports.obtenerMisAnuncios = async (req, res) => {
    try {
        const { id_usuario } = req.params;
        const [rows] = await db.execute(
            `SELECT * FROM inmueble_anuncio WHERE id_usuario = ? ORDER BY id DESC`, 
            [id_usuario]
        );

        const dataProcesada = rows.map(item => {
            let imagenPrincipal = '';
            try {
                if (item.imagenes && (item.imagenes.startsWith('[') || item.imagenes.startsWith('{'))) {
                    const imgs = JSON.parse(item.imagenes);
                    if (Array.isArray(imgs) && imgs.length > 0) imagenPrincipal = imgs[0];
                } else if (item.imagenes) imagenPrincipal = item.imagenes;
            } catch (e) {
                imagenPrincipal = item.imagenes;
            }
            return { ...item, imagenPrincipal };
        });

        res.json({ success: true, data: dataProcesada });

    } catch (error) {
        console.error("🔥 Error obteniendo mis anuncios:", error);
        res.status(500).json({ success: false, message: "Error al cargar tus anuncios" });
    }
};

/**
 * 5. NUEVO: EDITAR PROPIEDAD
 */
exports.editarPropiedad = async (req, res) => {
    try {
        const propertyId = req.params.id;

        // Obtener propiedad actual
        const propiedadActual = await PropiedadModel.obtenerPorId(propertyId);
        if (!propiedadActual) {
            return res.status(404).json({ success: false, message: 'Propiedad no encontrada' });
        }

        // Procesar nuevas imágenes si las hay
        let imagenesUrls = propiedadActual.imagenes || [];
        if (req.files && req.files.length > 0) {
            req.files.forEach(f => imagenesUrls.push(`/uploads/${f.filename}`));
        }

        // Actualizar campos
        const datosActualizados = {
            titulo: req.body.titulo || propiedadActual.titulo,
            precio: req.body.precio ? Number(req.body.precio) : propiedadActual.precio,
            descripcion: req.body.descripcion || propiedadActual.descripcion,
            dormitorios: req.body.dormitorios ? Number(req.body.dormitorios) : propiedadActual.dormitorios,
            banos: req.body.banos ? Number(req.body.banos) : propiedadActual.banos,
            superficie: req.body.superficie ? Number(req.body.superficie) : propiedadActual.superficie,
            tipo: req.body.tipo || propiedadActual.tipo,
            ubicacion: req.body.ubicacion || propiedadActual.ubicacion,
            latitude: req.body.latitude ? Number(req.body.latitude) : propiedadActual.latitude,
            longitude: req.body.longitude ? Number(req.body.longitude) : propiedadActual.longitude,
            caracteristicas: req.body.caracteristicas || propiedadActual.caracteristicas,
            imagenes: imagenesUrls
        };

        await PropiedadModel.actualizar(propertyId, datosActualizados);

        return res.status(200).json({ success: true, message: 'Propiedad actualizada exitosamente' });
    } catch (error) {
        console.error('🔥 Error editando propiedad:', error);
        return res.status(500).json({ success: false, message: 'Error al actualizar propiedad', error: error.message });
    }
};

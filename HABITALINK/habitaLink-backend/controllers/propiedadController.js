const db = require('../config/db');

/**
 * CREAR PROPIEDAD (POST)
 * Maneja la subida de datos e imágenes
 */
exports.crearPropiedad = async (req, res) => {
    try {
        // Gestión de imágenes (si usas multer en las rutas)
        const imagenesUrls = [];
        if (req.files && Array.isArray(req.files) && req.files.length > 0) {
            req.files.forEach(f => {
                imagenesUrls.push(`/uploads/${f.filename}`);
            });
        }
        // Convertimos a string separado por comas para guardar en BD (ajusta si usas otra tabla para fotos)
        const fotosString = imagenesUrls.join(',');

        // Datos del body
        const {
            id_usuario, titulo, precio, descripcion, 
            dormitorios, banos, metros_cuadrados, 
            ubicacion, tipo, latitude, longitude
        } = req.body;

        const estadoInicial = 'pendiente'; // Siempre pendiente hasta que el admin apruebe

        const query = `
            INSERT INTO inmueble_anuncio 
            (id_usuario, nombre, descripcion, precio, ubicacion, estado, dormitorios, banos, metros_cuadrados, tipo, fotos)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        const [result] = await db.execute(query, [
            id_usuario, 
            titulo || 'Sin título', 
            descripcion || '', 
            precio || 0, 
            ubicacion || '', 
            estadoInicial, 
            dormitorios || 0, 
            banos || 0, 
            metros_cuadrados || 0, 
            tipo || 'venta',
            fotosString
        ]);

        res.status(201).json({ 
            success: true, 
            message: "Propiedad creada correctamente", 
            id: result.insertId 
        });

    } catch (error) {
        console.error("Error creando propiedad:", error);
        res.status(500).json({ success: false, message: "Error al crear propiedad" });
    }
};

/**
 * OBTENER TODAS LAS PROPIEDADES (Para la APP de usuario)
 * Solo devuelve las que estén 'disponible' (aprobadas)
 */
exports.obtenerPropiedades = async (req, res) => {
    try {
        // Filtramos por estado 'disponible' para usuarios normales
        const [rows] = await db.execute("SELECT * FROM inmueble_anuncio WHERE estado = 'disponible'");
        res.json(rows);
    } catch (error) {
        console.error("Error obteniendo propiedades:", error);
        res.status(500).json({ error: "Error al obtener propiedades" });
    }
};

/**
 * OBTENER DETALLE DE UNA PROPIEDAD
 */
exports.obtenerDetallePropiedad = async (req, res) => {
    try {
        const { id } = req.params;
        const [rows] = await db.execute("SELECT * FROM inmueble_anuncio WHERE id = ?", [id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ message: "Propiedad no encontrada" });
        }
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Error al obtener detalle" });
    }
};

/**
 * APROBAR PROPIEDAD (Admin)
 * Esta función es la que usa el PropertiesView.dart
 */
exports.aprobarPropiedad = async (req, res) => {
    try {
        const { id } = req.params;
        const { estado } = req.body; // Flutter enviará "disponible"

        const [result] = await db.execute(
            'UPDATE inmueble_anuncio SET estado = ? WHERE id = ?', 
            [estado || 'disponible', id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "No se encontró la propiedad" });
        }

        res.json({ message: "Propiedad aprobada correctamente" });
    } catch (error) {
        console.error("Error en aprobarPropiedad:", error);
        res.status(500).json({ error: "Error interno del servidor" });
    }
};

/**
 * ELIMINAR PROPIEDAD (Admin)
 */
exports.eliminarPropiedad = async (req, res) => {
    try {
        const { id } = req.params;
        
        // Borrado físico de la base de datos
        const [result] = await db.execute('DELETE FROM inmueble_anuncio WHERE id = ?', [id]);
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "No se encontró la propiedad para eliminar" });
        }
        
        res.json({ message: "Propiedad eliminada correctamente" });
    } catch (error) {
        console.error("Error al eliminar propiedad:", error);
        res.status(500).json({ success: false, message: 'Error al eliminar la propiedad' });
    }
};
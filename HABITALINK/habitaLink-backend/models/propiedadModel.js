const db = require('../config/db');
const { v4: uuidv4 } = require('uuid'); 

class PropiedadModel {

    // 1. CREAR un nuevo anuncio (POST)
    static async crear(datos) {
        const connection = await db.getConnection();
        try {
            await connection.beginTransaction(); 

            const anuncioId = uuidv4();
            let imagenId = null;
            
            if (datos.imagenes && Array.isArray(datos.imagenes) && datos.imagenes.length > 0) {
                imagenId = uuidv4();
                await connection.execute(
                    `INSERT INTO imagen (id, url_imagen) VALUES (?, ?)`,
                    [imagenId, datos.imagenes[0]]
                );
            }

            // ✅ MODIFICADO: Añadidas columnas latitude y longitude y sus valores (?, ?)
            await connection.execute(
                `INSERT INTO inmueble_anuncio 
                    (id, id_usuario, nombre, desc_inmueble, precio, ubicacion, estado, m2, num_habitaciones, num_baños, tipo, id_imagen, imagenes, caracteristicas, latitude, longitude) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    anuncioId,
                    datos.id_usuario,
                    datos.titulo,
                    datos.descripcion,
                    datos.precio,
                    datos.ubicacion || 'Sevilla', 
                    datos.estado || 'Activo',     
                    datos.superficie,
                    datos.dormitorios,
                    datos.banos,
                    datos.tipo,
                    imagenId,
                    datos.imagenes ? JSON.stringify(datos.imagenes) : null,
                    datos.caracteristicas ? (typeof datos.caracteristicas === 'string' ? datos.caracteristicas : JSON.stringify(datos.caracteristicas)) : null,
                    datos.latitude || 0.0, // ✅ Valor real
                    datos.longitude || 0.0 // ✅ Valor real
                ]
            );

            await connection.commit(); 
            return anuncioId; 

        } catch (error) {
            await connection.rollback(); 
            console.error('🔥 Error al crear anuncio:', error);
            throw error;
        } finally {
            connection.release();
        }
    }

    // 2. LISTAR todas las propiedades
    static async obtenerTodas() {
        const [rows] = await db.execute(`
            SELECT 
                a.id, 
                a.id_usuario, 
                a.nombre AS titulo, 
                a.desc_inmueble AS descripcion,
                a.precio, 
                a.m2 AS superficie,
                a.num_habitaciones AS dormitorios,
                a.num_baños AS banos,
                a.tipo,
                i.url_imagen,
                a.imagenes AS imagenes,
                a.ubicacion AS ubicacion,
                a.caracteristicas AS caracteristicas,
                a.latitude,  -- ✅ Traer valor real de la DB
                a.longitude  -- ✅ Traer valor real de la DB
            FROM inmueble_anuncio a
            LEFT JOIN imagen i ON a.id_imagen = i.id
            ORDER BY a.id DESC 
        `);

        const normalized = rows.map(r => {
            // ✅ Asegurar que latitude y longitude son números (no strings o null)
            if (r.latitude !== null && r.latitude !== undefined) {
                r.latitude = Number(r.latitude);
            } else {
                r.latitude = 0.0;
            }
            
            if (r.longitude !== null && r.longitude !== undefined) {
                r.longitude = Number(r.longitude);
            } else {
                r.longitude = 0.0;
            }
            
            try {
                if (r.caracteristicas) {
                    if (typeof r.caracteristicas === 'string') {
                        r.caracteristicas = JSON.parse(r.caracteristicas);
                    }
                } else {
                    r.caracteristicas = [];
                }
            } catch (e) {
                r.caracteristicas = (r.caracteristicas || '').split(',').map(s => s.trim()).filter(Boolean);
            }
            
            try {
                if (r.imagenes) {
                    if (typeof r.imagenes === 'string') {
                        r.imagenes = JSON.parse(r.imagenes);
                    }
                } else if (r.url_imagen) {
                    r.imagenes = [r.url_imagen];
                } else {
                    r.imagenes = [];
                }
            } catch (e) {
                r.imagenes = r.url_imagen ? [r.url_imagen] : [];
            }
            return r;
        });
        return normalized;
    }

    // 3. OBTENER una propiedad por ID
    static async obtenerPorId(id) {
        const [rows] = await db.execute(`
            SELECT 
                a.id, 
                a.id_usuario, 
                a.nombre AS titulo_completo, 
                a.nombre AS titulo, 
                a.desc_inmueble AS descripcion_corta, 
                a.desc_inmueble AS descripcion_larga, 
                a.precio, 
                a.m2 AS superficie,
                a.num_habitaciones AS dormitorios,
                a.num_baños AS banos,
                a.tipo,
                i.url_imagen,
                a.imagenes AS imagenes,
                a.caracteristicas,
                a.latitude,  -- ✅ CAMBIADO: Antes era 0.0 fijo
                a.longitude  -- ✅ CAMBIADO: Antes era 0.0 fijo
            FROM inmueble_anuncio a
            LEFT JOIN imagen i ON a.id_imagen = i.id
            WHERE a.id = ?
        `, [id]);
        
        if (rows.length > 0) {
            const propiedad = rows[0];
            
            // ✅ Asegurar que latitude y longitude son números (no strings)
            if (propiedad.latitude !== null && propiedad.latitude !== undefined) {
                propiedad.latitude = Number(propiedad.latitude);
            } else {
                propiedad.latitude = 0.0;
            }
            
            if (propiedad.longitude !== null && propiedad.longitude !== undefined) {
                propiedad.longitude = Number(propiedad.longitude);
            } else {
                propiedad.longitude = 0.0;
            }
            
            // 🔍 DEBUG: Log de coordenadas devueltas
            console.log('📍 obtenerPorId - Devolviendo coordenadas:', {
                id: propiedad.id,
                titulo: propiedad.titulo_completo,
                latitude: propiedad.latitude,
                longitude: propiedad.longitude,
            });
            
            try {
                if (propiedad.imagenes) {
                    if (typeof propiedad.imagenes === 'string') propiedad.imagenes = JSON.parse(propiedad.imagenes);
                } else if (propiedad.url_imagen) {
                    propiedad.imagenes = [propiedad.url_imagen];
                } else {
                    propiedad.imagenes = [];
                }
            } catch (e) {
                propiedad.imagenes = propiedad.url_imagen ? [propiedad.url_imagen] : [];
            }

            try {
                if (propiedad.caracteristicas) {
                    if (typeof propiedad.caracteristicas === 'string') {
                        try {
                            propiedad.caracteristicas = JSON.parse(propiedad.caracteristicas);
                        } catch (e) {
                            propiedad.caracteristicas = propiedad.caracteristicas.split(',').map(s => s.trim()).filter(Boolean);
                        }
                    }
                } else {
                    propiedad.caracteristicas = [];
                }
            } catch (e) {
                propiedad.caracteristicas = [];
            }
            return propiedad;
        }

        return null; 
    }
    
}
PropiedadModel.cambiarEstado = async (id, nuevoEstado) => {
    const sql = `UPDATE inmueble_anuncio SET estado = ? WHERE id = ?`;
    const [result] = await db.execute(sql, [nuevoEstado, id]);
    return result;
};

// ✅ CORRECCIÓN: Usa PropiedadModel en lugar de Propiedad
PropiedadModel.eliminar = async (id) => {
    const sql = `DELETE FROM inmueble_anuncio WHERE id = ?`;
    const [result] = await db.execute(sql, [id]);
    return result;
};
// ✅ AÑADE O CORRIGE ESTA FUNCIÓN
exports.aprobarPropiedad = async (req, res) => {
    try {
        const { id } = req.params;
        // Llamamos al método que definimos en el modelo antes
        const resultado = await PropiedadModel.cambiarEstado(id, 'Aprobado');
        
        if (resultado.affectedRows === 0) {
            return res.status(404).json({ message: "Propiedad no encontrada" });
        }

        res.json({ message: "Propiedad aprobada correctamente" });
    } catch (error) {
        console.error("Error en aprobarPropiedad:", error);
        res.status(500).json({ error: "Error interno del servidor" });
    }
};

// ✅ REVISA TAMBIÉN LA DE ELIMINAR (por si acaso)
exports.eliminarPropiedad = async (req, res) => {
    try {
        const { id } = req.params;
        await PropiedadModel.eliminar(id);
        res.json({ message: "Propiedad eliminada" });
    } catch (error) {
        res.status(500).json({ error: "Error al eliminar" });
    }
};
module.exports = PropiedadModel;
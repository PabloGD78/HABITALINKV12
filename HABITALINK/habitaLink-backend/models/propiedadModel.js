const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

class PropiedadModel {

    // Función auxiliar para convertir a número de forma segura
    static parseNumber(value, fallback) {
        const n = Number(value);
        return isNaN(n) ? fallback : n;
    }

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

            await connection.execute(
                `INSERT INTO inmueble_anuncio 
                    (id, id_usuario, nombre, desc_inmueble, precio, ubicacion, estado, m2, num_habitaciones, num_baños, tipo, id_imagen, imagenes, caracteristicas, latitude, longitude) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    anuncioId,
                    datos.id_usuario,
                    datos.titulo ?? null,
                    datos.descripcion ?? null,
                    datos.precio ?? null,
                    datos.ubicacion || 'Sevilla', 
                    datos.estado || 'Activo',     
                    datos.superficie ?? null,
                    datos.dormitorios ?? null,
                    datos.banos ?? null,
                    datos.tipo ?? null,
                    imagenId,
                    datos.imagenes ? JSON.stringify(datos.imagenes) : null,
                    datos.caracteristicas
                        ? (typeof datos.caracteristicas === 'string' ? datos.caracteristicas : JSON.stringify(datos.caracteristicas))
                        : null,
                    datos.latitude ?? 0.0,
                    datos.longitude ?? 0.0
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
                a.latitude,
                a.longitude
            FROM inmueble_anuncio a
            LEFT JOIN imagen i ON a.id_imagen = i.id
            ORDER BY a.id DESC 
        `);

        return rows.map(r => {
            r.latitude = r.latitude != null ? Number(r.latitude) : 0.0;
            r.longitude = r.longitude != null ? Number(r.longitude) : 0.0;

            try {
                r.caracteristicas = r.caracteristicas ? JSON.parse(r.caracteristicas) : [];
            } catch {
                r.caracteristicas = (r.caracteristicas || '').split(',').map(s => s.trim()).filter(Boolean);
            }

            try {
                r.imagenes = r.imagenes ? JSON.parse(r.imagenes) : (r.url_imagen ? [r.url_imagen] : []);
            } catch {
                r.imagenes = r.url_imagen ? [r.url_imagen] : [];
            }

            return r;
        });
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
                a.latitude,
                a.longitude
            FROM inmueble_anuncio a
            LEFT JOIN imagen i ON a.id_imagen = i.id
            WHERE a.id = ?
        `, [id]);
        
        if (rows.length === 0) return null;

        const propiedad = rows[0];
        propiedad.latitude = propiedad.latitude != null ? Number(propiedad.latitude) : 0.0;
        propiedad.longitude = propiedad.longitude != null ? Number(propiedad.longitude) : 0.0;

        try {
            propiedad.imagenes = propiedad.imagenes ? JSON.parse(propiedad.imagenes) : (propiedad.url_imagen ? [propiedad.url_imagen] : []);
        } catch {
            propiedad.imagenes = propiedad.url_imagen ? [propiedad.url_imagen] : [];
        }

        try {
            if (propiedad.caracteristicas) {
                if (typeof propiedad.caracteristicas === 'string') {
                    try {
                        propiedad.caracteristicas = JSON.parse(propiedad.caracteristicas);
                    } catch {
                        propiedad.caracteristicas = propiedad.caracteristicas.split(',').map(s => s.trim()).filter(Boolean);
                    }
                }
            } else {
                propiedad.caracteristicas = [];
            }
        } catch {
            propiedad.caracteristicas = [];
        }

        return propiedad;
    }

    // 4. ACTUALIZAR propiedad (solo campos que envías)
    static async actualizar(id, datos) {
        const connection = await db.getConnection();
        try {
            await connection.beginTransaction();

            // Obtener propiedad actual
            const [rows] = await connection.execute(`SELECT * FROM inmueble_anuncio WHERE id = ?`, [id]);
            if (!rows.length) throw new Error('Propiedad no encontrada');
            const actual = rows[0];

            // Campos a actualizar
            const updates = [];
            const params = [];

            if (datos.titulo != null) {
                updates.push('nombre = ?');
                params.push(datos.titulo);
            }

            if (datos.descripcion != null) {
                updates.push('desc_inmueble = ?');
                params.push(datos.descripcion);
            }

            if (datos.precio != null && datos.precio !== '') {
                updates.push('precio = ?');
                params.push(this.parseNumber(datos.precio, actual.precio));
            }

            if (datos.superficie != null && datos.superficie !== '') {
                updates.push('m2 = ?');
                params.push(this.parseNumber(datos.superficie, actual.m2));
            }

            if (datos.dormitorios != null && datos.dormitorios !== '') {
                updates.push('num_habitaciones = ?');
                params.push(this.parseNumber(datos.dormitorios, actual.num_habitaciones));
            }

            if (datos.banos != null && datos.banos !== '') {
                updates.push('num_baños = ?');
                params.push(this.parseNumber(datos.banos, actual.num_baños));
            }

            if (datos.tipo != null) {
                updates.push('tipo = ?');
                params.push(datos.tipo);
            }

            if (datos.ubicacion != null) {
                updates.push('ubicacion = ?');
                params.push(datos.ubicacion);
            }

            if (datos.latitude != null && datos.latitude !== '') {
                updates.push('latitude = ?');
                params.push(this.parseNumber(datos.latitude, actual.latitude));
            }

            if (datos.longitude != null && datos.longitude !== '') {
                updates.push('longitude = ?');
                params.push(this.parseNumber(datos.longitude, actual.longitude));
            }

            if (datos.caracteristicas != null) {
                let caracteristicas = [];
                if (typeof datos.caracteristicas === 'string') {
                    try {
                        caracteristicas = JSON.parse(datos.caracteristicas);
                    } catch {
                        caracteristicas = datos.caracteristicas.split(',').map(s => s.trim()).filter(Boolean);
                    }
                } else {
                    caracteristicas = datos.caracteristicas;
                }
                updates.push('caracteristicas = ?');
                params.push(JSON.stringify(caracteristicas));
            }

            if (datos.imagenes && Array.isArray(datos.imagenes) && datos.imagenes.length > 0) {
                const imagenId = uuidv4();
                await connection.execute(`INSERT INTO imagen (id, url_imagen) VALUES (?, ?)`, [imagenId, datos.imagenes[0]]);
                updates.push('id_imagen = ?');
                params.push(imagenId);

                updates.push('imagenes = ?');
                params.push(JSON.stringify(datos.imagenes));
            }

            if (updates.length === 0) return false; // No hay campos que actualizar

            const sql = `UPDATE inmueble_anuncio SET ${updates.join(', ')} WHERE id = ?`;
            params.push(id);

            await connection.execute(sql, params);

            await connection.commit();
            return true;

        } catch (error) {
            await connection.rollback();
            console.error('🔥 Error al actualizar propiedad:', error);
            throw error;
        } finally {
            connection.release();
        }
    }
}

module.exports = PropiedadModel;

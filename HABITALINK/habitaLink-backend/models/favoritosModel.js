const db = require('../config/db');

class FavoritosModel {
    // Obtener favoritos de un usuario: devolver lista de id_propiedad (sea cual sea el nombre de columna)
    static async obtenerPorUsuario(id_usuario) {
        const queries = [
            ['SELECT * FROM favoritos WHERE id_usuario = ?', [id_usuario]],
            ['SELECT * FROM favoritos WHERE id_ususuario = ?', [id_usuario]],
            ['SELECT * FROM favoritos WHERE id_usuario_fk = ?', [id_usuario]],
            ['SELECT * FROM favoritos WHERE usuario_id = ?', [id_usuario]]
        ];

        let rows = [];
        for (const [sql, params] of queries) {
            try {
                const [res] = await db.execute(sql, params);
                if (res && res.length > 0) {
                    rows = res;
                    break;
                }
            } catch (err) {
                // ignorar y probar la siguiente variante
            }
        }

        if (!rows || rows.length === 0) return [];

        // Normalizar: devolver primer campo que parezca el id de la propiedad
        return rows.map(r => r.id_propiedad || r.id_inmueble || r.id_inmueble_fk || r.id_inmuebleId || Object.values(r).find(v => typeof v === 'string' && v !== id_usuario));
    }

    static async anadir(id_usuario, id_propiedad) {
        // Intentar columnas comunes, con fallback
        try {
            await db.execute(
                'INSERT INTO favoritos (id_usuario, id_propiedad) VALUES (?, ?)'
                , [id_usuario, id_propiedad]
            );
            return true;
        } catch (e) {
            try {
                await db.execute(
                    'INSERT INTO favoritos (id_ususuario, id_inmueble) VALUES (?, ?)'
                    , [id_usuario, id_propiedad]
                );
                return true;
            } catch (e2) {
                // última opción: columnas genéricas
                await db.execute(
                    'INSERT INTO favoritos (id_usuario, id_inmueble) VALUES (?, ?)'
                    , [id_usuario, id_propiedad]
                );
                return true;
            }
        }
    }

    static async eliminar(id_usuario, id_propiedad) {
        // Intentar borrar con varias combinaciones de columnas
        const attempts = [
            ['DELETE FROM favoritos WHERE id_usuario = ? AND id_propiedad = ?', [id_usuario, id_propiedad]],
            ['DELETE FROM favoritos WHERE id_ususuario = ? AND id_inmueble = ?', [id_usuario, id_propiedad]],
            ['DELETE FROM favoritos WHERE id_usuario = ? AND id_inmueble = ?', [id_usuario, id_propiedad]],
        ];

        for (const [sql, params] of attempts) {
            try {
                const [result] = await db.execute(sql, params);
                if (result && result.affectedRows > 0) return true;
            } catch (_) {
                // ignorar y probar siguiente
            }
        }
        return false;
    }
}

module.exports = FavoritosModel;

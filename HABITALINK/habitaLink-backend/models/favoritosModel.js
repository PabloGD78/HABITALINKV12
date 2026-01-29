const db = require('../config/db');

class FavoritosModel {
    static async obtenerPorUsuario(id_usuario) {
        try {
            // ✅ CORREGIDO: Cambiamos id_inmueble por id_propiedad
            const [rows] = await db.execute(
                'SELECT id_propiedad FROM favoritos WHERE id_usuario = ?', 
                [id_usuario]
            );
            // Devolvemos los IDs mapeados correctamente
            return rows.map(r => r.id_propiedad);
        } catch (err) {
            console.error("Error en favoritosModel (obtener):", err);
            return [];
        }
    }

    static async anadir(id_usuario, id_propiedad) {
        try {
            // ✅ CORREGIDO: Cambiamos id_inmueble por id_propiedad
            await db.execute(
                'INSERT INTO favoritos (id_usuario, id_propiedad) VALUES (?, ?)',
                [id_usuario, id_propiedad]
            );
            return true;
        } catch (err) {
            console.error("Error en favoritosModel (anadir):", err);
            throw err; // Lanzamos el error para que el controlador lo capture
        }
    }

    static async eliminar(id_usuario, id_propiedad) {
        try {
            // ✅ CORREGIDO: Cambiamos id_inmueble por id_propiedad
            const [result] = await db.execute(
                'DELETE FROM favoritos WHERE id_usuario = ? AND id_propiedad = ?',
                [id_usuario, id_propiedad]
            );
            return result.affectedRows > 0;
        } catch (err) {
            console.error("Error en favoritosModel (eliminar):", err);
            return false;
        }
    }
}

module.exports = FavoritosModel;
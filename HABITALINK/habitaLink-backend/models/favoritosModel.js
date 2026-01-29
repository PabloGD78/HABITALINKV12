const db = require('../config/db');

class FavoritosModel {
    static async obtenerPorUsuario(id_usuario) {
    try {
        // Tu SQL dice que las columnas son id_usuario e id_inmueble
        const [rows] = await db.execute(
            'SELECT id_inmueble FROM favoritos WHERE id_usuario = ?', 
            [id_usuario]
        );
        // Devolvemos solo los IDs para que el frontend sepa qué marcar como corazón rojo
        return rows.map(r => r.id_inmueble);
    } catch (err) {
        console.error("Error en favoritosModel:", err);
        return [];
    }
}

    static async anadir(id_usuario, id_inmueble) {
        await db.execute(
            'INSERT INTO favoritos (id_usuario, id_inmueble) VALUES (?, ?)',
            [id_usuario, id_inmueble]
        );
        return true;
    }

    static async eliminar(id_usuario, id_inmueble) {
        const [result] = await db.execute(
            'DELETE FROM favoritos WHERE id_usuario = ? AND id_inmueble = ?',
            [id_usuario, id_inmueble]
        );
        return result.affectedRows > 0;
    }
}

module.exports = FavoritosModel;
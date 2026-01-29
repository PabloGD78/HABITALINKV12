// models/userModel.js

const db = require('../config/db');

class UserModel {
    
    // Buscar usuario por correo
    static async buscarPorCorreo(correo) {
        // ⚠️ CORRECCIÓN: Cambiado de USUARIO a usuario (minúsculas)
        const [rows] = await db.execute(
            "SELECT * FROM usuario WHERE correo = ?", 
            [correo]
        );
        return rows[0]; 
    }

    // Registrar nuevo usuario
    // ✅ MODIFICACIÓN: Añadidos 'tipo' y 'rol' para que el admin se guarde correctamente
    static async crear(id, nombre, apellidos, tlf, correo, contraseniaHash, tipo = 'admin', rol = 'usuario') {
        // ⚠️ CORRECCIÓN: Cambiado de USUARIO a usuario (minúsculas)
        await db.execute(
            `INSERT INTO usuario (id, nombre, apellidos, tlf, correo, contrasenia, tipo, rol)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [id, nombre, apellidos, tlf, correo, contraseniaHash, tipo, rol]
        );
        return id;
    }
}

module.exports = UserModel;
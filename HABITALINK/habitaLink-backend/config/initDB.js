const db = require('./db');
const UserModel = require('../models/userModel');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const initDB = async () => {
    try {
        console.log('🔄 Iniciando verificación de base de datos...');

        // 1. Asegurar tabla favoritos
        await db.execute(`
            CREATE TABLE IF NOT EXISTS favoritos (
                id_usuario VARCHAR(100),
                id_propiedad VARCHAR(100)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        `);

        // 2. Asegurar tabla de estadísticas
        await db.execute(`
            CREATE TABLE IF NOT EXISTS estadisticas_anuncio (
                id INT AUTO_INCREMENT PRIMARY KEY,
                id_inmueble VARCHAR(100),
                fecha DATE,
                visitas INT DEFAULT 0,
                contactos INT DEFAULT 0,
                FOREIGN KEY (id_inmueble) REFERENCES inmueble_anuncio(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        `);

        // 3. Crear Usuario ADMIN
        const adminEmail = 'admin@habitalink.com';
        const [existingAdmin] = await db.execute('SELECT * FROM usuario WHERE correo = ?', [adminEmail]);

        if (existingAdmin.length === 0) {
            const salt = await bcrypt.genSalt(10);
            const hash = await bcrypt.hash('root', salt);
            const id = uuidv4();
            await db.execute(
                'INSERT INTO usuario (id, nombre, apellidos, tlf, correo, contrasenia, tipo, rol) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [id, 'Admin', 'HabitaLink', '000000000', adminEmail, hash, 'Profesional', 'admin']
            );
            console.log('✅ Usuario ADMIN creado.');
        } else {
            // Asegurar que tenga rol admin
            await db.execute('UPDATE usuario SET rol = "admin" WHERE correo = ?', [adminEmail]);
        }

        // 4. Crear Usuario de prueba (Jose)
        const emailJose = 'joseruiz@gmail.com';
        const existingJose = await UserModel.buscarPorCorreo(emailJose);
        if (!existingJose) {
            const salt = await bcrypt.genSalt(10);
            const hash = await bcrypt.hash('12345678', salt);
            const id = uuidv4();
            await UserModel.crear(id, 'Jose', 'Ruiz Perez', '670239876', emailJose, hash);
            console.log('✅ Usuario seed creado: Jose.');
        }

        // 5. Migraciones y checks adicionales (ALTER TABLES)
        await runMigrations();

        console.log('🚀 Base de datos inicializada y verificada correctamente.');

    } catch (e) {
        console.error('🔥 Error en la inicialización de la DB:', e.message);
    }
};

// Función auxiliar para limpiar el código principal
const runMigrations = async () => {
    try {
        // Detectar tabla de propiedades
        const propertyTableCandidates = ['propiedad', 'inmueble_anuncio', 'anuncio', 'inmueble'];
        let propertyTable = null;
        for (const t of propertyTableCandidates) {
            const [tbl] = await db.execute(
                `SELECT COUNT(*) AS cnt FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`, [t]
            );
            if (tbl[0].cnt > 0) {
                propertyTable = t;
                break;
            }
        }

        if (propertyTable) {
            const [expRows] = await db.execute(
                `SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = 'expiration_date'`, [propertyTable]
            );
            if (expRows[0].cnt === 0) {
                await db.execute(`ALTER TABLE ${propertyTable} ADD COLUMN expiration_date DATETIME NULL`);
            }
        }

        const [loginRows] = await db.execute(
            `SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'usuario' AND COLUMN_NAME = 'last_login'`
        );
        if (loginRows[0].cnt === 0) {
            await db.execute(`ALTER TABLE usuario ADD COLUMN last_login DATETIME NULL`);
        }

        await db.execute(`
            CREATE TABLE IF NOT EXISTS contacto (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nombre VARCHAR(255) NULL,
                email VARCHAR(255) NULL,
                mensaje TEXT NULL,
                fecha DATETIME DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        `);
    } catch (err) {
        console.warn('⚠️ Advertencia en migraciones:', err.message);
    }
};

module.exports = initDB;
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

// --- Middlewares ---
app.use(cors());
app.use(express.json());

// --- Carpeta Pública (Imágenes) ---
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// --- Importar Rutas ---
const propiedadRoutes = require('./routes/propiedadRoutes');
const authRoutes = require('./routes/authRoutes');
const favoritosRoutes = require('./routes/favoritosRoutes');
const adminRoutes = require('./routes/adminRoutes');
// ✅ NUEVO: Importamos el controlador de estadísticas
const statsController = require('./controllers/statsController');

// --- Usar Rutas ---
app.use('/api/propiedades', propiedadRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/favoritos', favoritosRoutes);
app.use('/api/admin', adminRoutes);

// ✅ NUEVO: Ruta para las gráficas del Dashboard de Inmobiliaria (Líneas)
app.get('/api/stats/agencia/:id_usuario', statsController.getEstadisticasAgencia);

// ✅ NUEVO: Ruta para las gráficas del Dashboard de Admin (Pastel)
app.get('/api/stats/admin/usuarios', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT tipo, COUNT(*) as cantidad FROM usuario GROUP BY tipo');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error("Error en stats admin:", error);
        res.status(500).json({ success: false, message: "Error al obtener tipos de usuarios" });
    }
});

// --- Arrancar Servidor ---
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor HabitaLink corriendo en http://localhost:${PORT}`);
    console.log(`📂 Carpeta de uploads pública activa`);
});

// -- Asegurar tablas y configuración de DB --
const db = require('./config/db');
const UserModel = require('./models/userModel');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

(async () => {
    try {
        // 1. Asegurar tabla favoritos
        await db.execute(`
            CREATE TABLE IF NOT EXISTS favoritos (
                id_usuario VARCHAR(100),
                id_propiedad VARCHAR(100)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        `);
        console.log('Tabla favoritos verificada.');

        // ✅ NUEVO: Asegurar tabla de estadísticas para las gráficas
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
        console.log('Tabla estadisticas_anuncio verificada.');

        // 2. SEED: Asegurar existencia de usuario administrador
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
            console.log('✅ Usuario ADMIN creado: admin@habitalink.com / root');
        } else {
            await db.execute('UPDATE usuario SET rol = "admin" WHERE correo = ?', [adminEmail]);
            console.log('✔ Usuario admin verificado en la base de datos.');
        }

        // 3. SEED: Usuario joseruiz@gmail.com
        const emailJose = 'joseruiz@gmail.com';
        const existingJose = await UserModel.buscarPorCorreo(emailJose);
        if (!existingJose) {
            const salt = await bcrypt.genSalt(10);
            const hash = await bcrypt.hash('12345678', salt);
            const id = uuidv4();
            await UserModel.crear(id, 'Jose', 'Ruiz Perez', '670239876', emailJose, hash);
            console.log('Usuario seed creado:', emailJose);
        }

        // 4. Asegurar columnas/tablas adicionales necesarias para informes
        try {
            const propertyTableCandidates = ['propiedad', 'inmueble_anuncio', 'anuncio', 'inmueble'];
            let propertyTable = null;
            for (const t of propertyTableCandidates) {
                const [tbl] = await db.execute(
                    `SELECT COUNT(*) AS cnt FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`,
                    [t]
                );
                if (tbl[0].cnt > 0) {
                    propertyTable = t;
                    break;
                }
            }

            if (propertyTable) {
                const [expRows] = await db.execute(
                    `SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = 'expiration_date'`,
                    [propertyTable]
                );
                if (expRows[0].cnt === 0) {
                    await db.execute(`ALTER TABLE ${propertyTable} ADD COLUMN expiration_date DATETIME NULL`);
                    console.log(`Columna expiration_date añadida a tabla ${propertyTable}.`);
                }
            }

            const [loginRows] = await db.execute(
                `SELECT COUNT(*) AS cnt FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'usuario' AND COLUMN_NAME = 'last_login'`
            );
            if (loginRows[0].cnt === 0) {
                await db.execute(`ALTER TABLE usuario ADD COLUMN last_login DATETIME NULL`);
                console.log('Columna last_login añadida a tabla usuario.');
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
            console.log('Tabla contacto verificada/creada.');
        } catch (schemaErr) {
            console.warn('Error comprobando esquema adicional:', schemaErr.message);
        }

    } catch (e) {
        console.error('🔥 Error en el proceso de inicialización:', e.message);
    }
})();
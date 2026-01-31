const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

// --- Middlewares ---
app.use(cors());
app.use(express.json());

// --- Carpeta Pública (Para que se vean las fotos) ---
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// --- Importar Rutas ---
const propiedadRoutes = require('./routes/propiedadRoutes');
const authRoutes = require('./routes/authRoutes');
const favoritosRoutes = require('./routes/favoritosRoutes');
const adminRoutes = require('./routes/adminRoutes');
const statsRoutes = require('./routes/statsRoutes'); // ✅ NUEVO

// --- Usar Rutas ---
// 1. Propiedades (Inmuebles)
app.use('/api/propiedades', propiedadRoutes);

// 2. Autenticación (Login/Registro)
app.use('/api/auth', authRoutes);

// 3. Favoritos
app.use('/api/favoritos', favoritosRoutes);

// 4. Administración (Usuarios)
app.use('/api/admin', adminRoutes);

// 5. Estadísticas (Dashboard)
app.use('/api/stats', statsRoutes); // ✅ Esto arregla el Dashboard

// --- Ruta Base (Prueba) ---
app.get('/', (req, res) => {
    res.send('¡Servidor HabitaLink funcionando al 100%!');
});

// --- Arrancar Servidor ---
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
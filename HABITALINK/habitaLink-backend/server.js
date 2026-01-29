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

// --- Importar Controlador de Estadísticas ---
const statsController = require('./controllers/statsController');

// --- Usar Rutas ---
app.use('/api/propiedades', propiedadRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/favoritos', favoritosRoutes);
app.use('/api/admin', adminRoutes);

// --- Rutas de Estadísticas ---
// Gráfica de líneas (Agencia)
app.get('/api/stats/agencia/:id_usuario', statsController.getEstadisticasAgencia);
// Gráfica de pastel (Admin)
app.get('/api/stats/admin/usuarios', statsController.getEstadisticasAdmin);

// --- Ruta Base (Mensaje de bienvenida) ---
app.get('/', (req, res) => {
    res.send('¡Hola! El servidor backend de HabitaLink está funcionando correctamente.');
});

// --- Arrancar Servidor ---
const PORT = 3000;

app.listen(PORT, () => {
    console.log(`--------------------------------------------------`);
    console.log(`Servidor HabitaLink corriendo en: http://localhost:${PORT}`);
    console.log(`Carpeta de uploads pública activa`);
    console.log(`--------------------------------------------------`);
});
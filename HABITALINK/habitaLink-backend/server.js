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
const adminController = require('./controllers/adminController');
// --- Importar Controlador de Estadísticas ---
const statsController = require('./controllers/statsController');

// --- Usar Rutas ---
app.use('/api/propiedades', propiedadRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/favoritos', favoritosRoutes);
app.use('/api/admin', adminRoutes);
// --- Rutas de Estadísticas ---
// Cámbiala de '/api/stats/admin/usuarios' a solo '/api/stats/admin'
app.get('/api/stats/admin', statsController.getEstadisticasAdmin);

// La de agencia se queda igual si así la llamas desde el panel de agencia
app.get('/api/stats/agencia/:id_usuario', statsController.getEstadisticasAgencia);

// Añade esto para que la URL directa funcione
app.get('/api/properties', adminController.getAllProperties);
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
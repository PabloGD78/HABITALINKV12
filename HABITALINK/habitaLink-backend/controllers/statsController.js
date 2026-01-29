const db = require('../config/db'); // Asegúrate de que la ruta a tu db sea correcta

// 1. Definimos la función de ADMIN
const getEstadisticasAdmin = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT tipo, COUNT(*) as cantidad FROM usuario GROUP BY tipo');
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error("Error en stats admin:", error);
        res.status(500).json({ success: false, message: "Error al obtener tipos de usuarios" });
    }
};

// 2. Definimos la función de AGENCIA (Ya no usamos exports. aqui, sino const)
const getEstadisticasAgencia = async (req, res) => {
    const { id_usuario } = req.params; 

    try {
        const query = `
            SELECT 
                DATE_FORMAT(e.fecha, '%d/%m') as dia, 
                SUM(e.visitas) as total_visitas, 
                SUM(e.contactos) as total_contactos
            FROM estadisticas_anuncio e
            JOIN inmueble_anuncio i ON e.id_inmueble = i.id
            WHERE i.id_usuario = ? 
              AND e.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            GROUP BY e.fecha
            ORDER BY e.fecha ASC;
        `;

        const [rows] = await db.execute(query, [id_usuario]); 
        
        res.json({ 
            success: true, 
            data: rows 
        });
    } catch (error) {
        console.error("❌ Error en SQL Stats:", error);
        res.status(500).json({ 
            success: false, 
            message: "Error al obtener estadísticas de inmuebles" 
        });
    }
};

// 3. ✅ EXPORTACIÓN FINAL UNIFICADA
// Esto es lo que permite que en server.js puedas hacer "statsController.getEstadisticasAgencia"
module.exports = {
    getEstadisticasAdmin,
    getEstadisticasAgencia
};
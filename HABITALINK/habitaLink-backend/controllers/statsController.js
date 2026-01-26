const db = require('../config/db'); // Asegúrate de que la ruta a tu db sea correcta

// ✅ Cambiamos el nombre de la función para que coincida con el require de server.js
exports.getEstadisticasAgencia = async (req, res) => {
    const { id_usuario } = req.params; 

    try {
        const query = `
            SELECT 
                DATE_FORMAT(e.fecha, '%d/%m') as dia, 
                SUM(e.visitas) as total_visitas, 
                SUM(e.contactos) as total_contactos
            FROM estadisticas_anuncio e
            JOIN inmueble_anuncio i ON e.id_inmueble = i.id  -- 👈 Cambiado: id_inmueble en lugar de id_anuncio
            WHERE i.id_usuario = ? 
              AND e.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
            GROUP BY e.fecha
            ORDER BY e.fecha ASC;
        `;

        const [rows] = await db.execute(query, [id_usuario]); // Usamos .execute para mayor seguridad
        
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
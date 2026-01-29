const db = require('../config/db'); // Asegúrate de que la ruta a db sea correcta

exports.getEstadisticasAgencia = async (req, res) => {
    const { id_usuario } = req.params;

    try {
        // 1. Verificar si el usuario tiene inmuebles
        // Esta consulta asume que tienes una tabla que vincula inmuebles con usuarios.
        // Ajustamos para obtener estadísticas agrupadas por fecha de TODOS los anuncios de este usuario.
        
        const query = `
            SELECT 
                DATE_FORMAT(e.fecha, '%Y-%m-%d') as fecha,
                SUM(e.visitas) as visitas,
                SUM(e.contactos) as contactos
            FROM estadisticas_anuncio e
            JOIN inmueble_anuncio ia ON e.id_inmueble = ia.id
            JOIN propiedad p ON ia.id_propiedad = p.id
            WHERE p.id_usuario = ?
            GROUP BY e.fecha
            ORDER BY e.fecha ASC
            LIMIT 30;
        `;

        const [rows] = await db.execute(query, [id_usuario]);

        // Si no hay datos, devolvemos un array vacío pero con éxito
        if (rows.length === 0) {
            return res.json({ 
                success: true, 
                data: [],
                message: "No hay estadísticas disponibles aún" 
            });
        }

        res.json({ success: true, data: rows });

    } catch (error) {
        console.error("Error obteniendo estadísticas:", error);
        res.status(500).json({ 
            success: false, 
            message: "Error en el servidor al cargar estadísticas" 
        });
    }
};
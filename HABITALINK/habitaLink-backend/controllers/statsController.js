const db = require('../config/db'); 

// 1. Estadísticas para el ADMIN
const getEstadisticasAdmin = async (req, res) => {
    try {
        // A. Total Usuarios
        const [usersCount] = await db.execute('SELECT COUNT(*) as total FROM usuario');
        
        // B. Total Propiedades (usando inmueble_anuncio)
        const [propsCount] = await db.execute('SELECT COUNT(*) as total FROM inmueble_anuncio');
        
        // C. Distribución (Gráfica)
        const [distribucion] = await db.execute('SELECT tipo as rol, COUNT(*) as cantidad FROM usuario GROUP BY tipo');

        // D. Enviar TODO junto
        res.json({
            success: true,
            totalUsuarios: usersCount[0].total,
            totalPropiedades: propsCount[0].total,
            distribucionUsuarios: distribucion
        });

    } catch (error) {
        console.error("Error stats admin:", error);
        res.status(500).json({ success: false, message: "Error al obtener estadísticas" });
    }
};

// 2. Estadísticas para AGENCIA
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
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error("Error stats agencia:", error);
        res.status(500).json({ success: false, message: "Error interno" });
    }
};

module.exports = {
    getEstadisticasAdmin,
    getEstadisticasAgencia
};
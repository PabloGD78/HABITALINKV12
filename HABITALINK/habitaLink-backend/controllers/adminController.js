const db = require('../config/db');

// Esta es la función que tu router estaba buscando
exports.obtenerInformeGeneral = async (req, res) => {
    try {
        console.log("=== GENERANDO DATOS PARA INFORME ADMIN ===");

        // 1. Estadísticas de Usuarios por Tipo (Para el gráfico de Pastel)
        const [usuariosTipo] = await db.execute(`
            SELECT 
                CASE 
                    -- Preferir la columna 'tipo' en la tabla usuario si existe (insensible a mayúsculas)
                    WHEN LOWER(COALESCE(u.tipo, '')) = 'profesional' THEN 'Profesional'
                    WHEN LOWER(COALESCE(u.tipo, '')) = 'particular' THEN 'Particular'
                    -- Si no hay valor en usuario.tipo, fallback a las tablas de perfil
                    WHEN prof.id_usuario IS NOT NULL THEN 'Profesional'
                    WHEN part.id_usuario IS NOT NULL THEN 'Particular'
                    ELSE 'Sin perfil'
                END AS tipo,
                COUNT(*) as cantidad
            FROM usuario u
            LEFT JOIN perfil_profesional prof ON u.id = prof.id_usuario
            LEFT JOIN perfil_particular part ON u.id = part.id_usuario
            GROUP BY tipo
        `);

        // 2. Estadísticas de Anuncios (Activos vs Caducados para el gráfico de Barras)
        // Más útil: agrupar anuncios por su 'tipo' (venta, alquiler, etc.)
        const [anunciosEstado] = await db.execute(`
            SELECT 
                CASE WHEN COALESCE(tipo, '') = '' THEN 'Desconocido' ELSE tipo END as estado,
                COUNT(*) as cantidad
            FROM inmueble_anuncio
            GROUP BY estado
            ORDER BY cantidad DESC
        `);

        // 2b. Popularidad basada en favoritos: cuántos favoritos tiene cada tipo de anuncio
        const [popularTypes] = await db.execute(`
            SELECT COALESCE(a.tipo, 'Desconocido') AS tipo, COUNT(*) AS favoritos
            FROM favoritos f
            LEFT JOIN inmueble_anuncio a ON a.id = f.id_propiedad
            GROUP BY tipo
            ORDER BY favoritos DESC
        `);

        // 2c. Popularidad por características (piscina, jardin, garaje, terraza, ascensor, aire acondicionado)
        const [popularFeaturesRaw] = await db.execute(`
            SELECT 'piscina' AS feature, COUNT(*) AS cantidad FROM favoritos f JOIN inmueble_anuncio a ON a.id = f.id_propiedad WHERE LOWER(COALESCE(a.caracteristicas, '')) LIKE '%piscina%'
            UNION ALL
            SELECT 'jardin' AS feature, COUNT(*) AS cantidad FROM favoritos f JOIN inmueble_anuncio a ON a.id = f.id_propiedad WHERE LOWER(COALESCE(a.caracteristicas, '')) LIKE '%jardin%'
            UNION ALL
            SELECT 'garaje' AS feature, COUNT(*) AS cantidad FROM favoritos f JOIN inmueble_anuncio a ON a.id = f.id_propiedad WHERE LOWER(COALESCE(a.caracteristicas, '')) LIKE '%garaje%'
            UNION ALL
            SELECT 'terraza' AS feature, COUNT(*) AS cantidad FROM favoritos f JOIN inmueble_anuncio a ON a.id = f.id_propiedad WHERE LOWER(COALESCE(a.caracteristicas, '')) LIKE '%terraza%'
            UNION ALL
            SELECT 'ascensor' AS feature, COUNT(*) AS cantidad FROM favoritos f JOIN inmueble_anuncio a ON a.id = f.id_propiedad WHERE LOWER(COALESCE(a.caracteristicas, '')) LIKE '%ascensor%'
            UNION ALL
            SELECT 'aire_acondicionado' AS feature, COUNT(*) AS cantidad FROM favoritos f JOIN inmueble_anuncio a ON a.id = f.id_propiedad WHERE LOWER(COALESCE(a.caracteristicas, '')) LIKE '%aire%'
        `);

        // 3. Usuarios Activos hoy (Logueados en las últimas 24h)
        const [activos] = await db.execute(`
            SELECT COUNT(*) as cant 
            FROM usuario 
            WHERE last_login > DATE_SUB(NOW(), INTERVAL 1 DAY)
        `);

        // 4. Alertas: Anuncios que no tienen imagen (Simulado o real si tienes tabla fotos)
        const alertasSinImagen = 0; 

        // Enviamos la respuesta estructurada como la espera Flutter
        res.json({
            success: true,
            data: {
                usuariosTipo,
                anunciosPorTipo: anunciosEstado,
                popularTypes,
                popularFeatures: popularFeaturesRaw,
                usuariosActivos: activos[0].cant,
                alertasSinImagen,
                totalAnuncios: anunciosEstado.reduce((acc, curr) => acc + curr.cantidad, 0)
            }
        });

    } catch (error) {
        console.error("🔥 Error en obtenerInformeGeneral:", error);
        res.status(500).json({ 
            success: false, 
            message: "Error interno al obtener estadísticas del administrador" 
        });
    }
};
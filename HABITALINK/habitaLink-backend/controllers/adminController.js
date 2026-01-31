const db = require('../config/db');

// --- OBTENER TODOS LOS USUARIOS ---
exports.getAllUsers = async (req, res) => {
    try {
        // Seleccionamos solo los campos necesarios para la tabla de Flutter
        const [users] = await db.execute('SELECT id, nombre, apellidos, correo, tlf, rol, tipo FROM usuario');
        res.json({ success: true, users });
    } catch (error) {
        console.error("Error getAllUsers:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- BORRAR USUARIO ---
exports.deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('DELETE FROM usuario WHERE id = ?', [id]);
        res.json({ success: true, message: "Usuario eliminado" });
    } catch (error) {
        console.error("Error deleteUser:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- OBTENER TODAS LAS PROPIEDADES (Para el Admin) ---
exports.getAllProperties = async (req, res) => {
    try {
        // Hacemos JOIN con usuario para mostrar el nombre del dueño en el Admin Panel
        // Mapeamos 'nombre' a 'title' y 'ubicacion' a 'address' para compatibilidad con Flutter
        const query = `
            SELECT 
                i.id, 
                i.nombre as title, 
                i.ubicacion as address, 
                i.precio, 
                i.tipo, 
                i.estado, 
                i.descripcion,
                u.nombre as owner 
            FROM inmueble_anuncio i 
            LEFT JOIN usuario u ON i.id_usuario = u.id
        `;
        
        const [properties] = await db.execute(query);
        
        // Devolvemos en formato { success: true, data: [...] }
        res.json({ success: true, data: properties });
        
    } catch (error) {
        console.error("Error getAllProperties:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- CAMBIAR ESTADO PROPIEDAD (Aprobar) ---
exports.updatePropertyStatus = async (req, res) => {
    const { id } = req.params;
    const { estado } = req.body; // Flutter enviará "disponible" o "aprobado"
    try {
        await db.execute('UPDATE inmueble_anuncio SET estado = ? WHERE id = ?', [estado, id]);
        res.json({ success: true, message: "Estado actualizado correctamente" });
    } catch (error) {
        console.error("Error updatePropertyStatus:", error);
        res.status(500).json({ success: false, message: error.message });
    }
};
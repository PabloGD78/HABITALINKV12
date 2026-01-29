const db = require('../config/db'); // Tu conexión existente

// --- OBTENER TODOS LOS USUARIOS ---
exports.getAllUsers = async (req, res) => {
    try {
        const [users] = await db.execute('SELECT id, nombre, apellidos, correo, tlf, rol, tipo FROM usuario');
        res.json({ success: true, users });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('DELETE FROM usuario WHERE id = ?', [id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.getAllProperties = async (req, res) => {
    try {
        const [properties] = await db.execute(`
            SELECT i.id, i.nombre as title, i.ubicacion as address, i.precio, i.tipo, i.estado, u.nombre as owner 
            FROM inmueble_anuncio i 
            LEFT JOIN usuario u ON i.id_usuario = u.id
        `);
        res.json({ success: true, properties });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

exports.updatePropertyStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    try {
        await db.execute('UPDATE inmueble_anuncio SET estado = ? WHERE id = ?', [status, id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
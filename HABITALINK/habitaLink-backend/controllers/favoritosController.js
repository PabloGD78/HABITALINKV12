const FavoritosModel = require('../models/favoritosModel');

exports.obtenerFavoritosPorUsuario = async (req, res) => {
    try {
        const usuarioId = req.params.id;
        const favoritos = await FavoritosModel.obtenerPorUsuario(usuarioId);
        return res.status(200).json(favoritos);
    } catch (error) {
        console.error('Error al obtener favoritos:', error);
        return res.status(500).json({ error: error.message });
    }
};

exports.anadirFavorito = async (req, res) => {
    try {
        const { id_usuario, id_propiedad } = req.body;
        if (!id_usuario || !id_propiedad) {
            return res.status(400).json({ error: 'Faltan parámetros' });
        }
        await FavoritosModel.anadir(id_usuario, id_propiedad);
        return res.status(201).json({ success: true });
    } catch (error) {
        console.error('Error al añadir favorito:', error);
        return res.status(500).json({ error: error.message });
    }
};

exports.eliminarFavorito = async (req, res) => {
    try {
        const { id_usuario, id_propiedad } = req.body;
        if (!id_usuario || !id_propiedad) {
            return res.status(400).json({ error: 'Faltan parámetros' });
        }
        const deleted = await FavoritosModel.eliminar(id_usuario, id_propiedad);
        if (deleted) return res.status(200).json({ success: true });
        return res.status(404).json({ success: false, message: 'No encontrado' });
    } catch (error) {
        console.error('Error al eliminar favorito:', error);
        return res.status(500).json({ error: error.message });
    }
};

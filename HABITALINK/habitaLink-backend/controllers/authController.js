// controllers/authController.js

const UserModel = require('../models/userModel');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

exports.login = async (req, res) => {
    // ✅ MODIFICACIÓN: Pasamos el correo a minúsculas para que coincida siempre con la BD
    const correo = req.body.correo ? req.body.correo.toLowerCase() : "";
    const { contrasenia } = req.body;

    try {
        // --- BLOQUE DE DIAGNÓSTICO ---
        console.log("=== INTENTO DE LOGIN ===");
        console.log("Recibido de Flutter -> Correo:", correo, "| Clave:", contrasenia);

        // 1. Buscar usuario
        const user = await UserModel.buscarPorCorreo(correo);

        if (!user) {
            console.log("Resultado -> USUARIO NO ENCONTRADO EN BD");
            return res.status(401).json({ success: false, message: "Correo o contraseña incorrectos." });
        }

        console.log("Usuario en BD -> ID:", user.id, "| Hash:", user.contrasenia, "| Rol:", user.rol);

        // 2. Comprobar contraseña
        const passwordMatch = await bcrypt.compare(contrasenia, user.contrasenia);
        console.log("¿La contraseña coincide? ->", passwordMatch ? "SÍ ✅" : "NO ❌");

        if (!passwordMatch) {
            return res.status(401).json({ success: false, message: "Correo o contraseña incorrectos." });
        }

        // 3. Eliminar contraseña antes de enviar al frontend
        delete user.contrasenia;

        // 4. Responder
        res.json({
            success: true,
            message: "Inicio de sesión exitoso.",
            user: user, 
            token: "simulated-jwt-token" 
        });

    } catch (error) {
        console.error("🔥 Error en login:", error); 
        res.status(500).json({ success: false, message: "Error interno del servidor" });
    }
};

exports.register = async (req, res) => {
    const { nombre, apellidos, tlf, correo, contrasenia, tipo } = req.body;

    // Validar tipo si se envía
    const tipoValido = (t) => {
        if (!t) return false;
        const low = t.toString().toLowerCase();
        return low === 'particular' || low === 'profesional';
    };

    try {
        console.log('Registro recibido:', { correo, nombre, tipo });
        const salt = await bcrypt.genSalt(10);
        const contraseniaHash = await bcrypt.hash(contrasenia, salt);
        const id = uuidv4();

        // Normalizar correo a minúsculas para mantener consistencia con login
        const correoNorm = correo ? correo.toString().toLowerCase() : '';

        // Usar 'Particular' por defecto si no se envía o es inválido
        const tipoFinal = tipoValido(tipo) ? (tipo[0].toUpperCase() + tipo.slice(1).toLowerCase()) : 'Particular';

        await UserModel.crear(id, nombre, apellidos, tlf, correoNorm, contraseniaHash, tipoFinal);

        res.status(201).json({
            success: true,
            message: "Usuario registrado correctamente.",
            tipo: tipoFinal,
        });

    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ success: false, message: "El correo ya está registrado." });
        }
        console.error("Error en registro:", error);
        res.status(500).json({ success: false, message: "Error al registrar usuario." });
    }
};
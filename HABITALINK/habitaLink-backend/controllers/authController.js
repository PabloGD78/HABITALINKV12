// controllers/authController.js
const UserModel = require('../models/userModel');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

// --- FUNCIÓN LOGIN ---
const login = async (req, res) => {
    const correo = req.body.correo ? req.body.correo.toLowerCase().trim() : "";
    const { contrasenia } = req.body;

    try {
        console.log("=== LOGIN ===", correo);
        const user = await UserModel.buscarPorCorreo(correo);

        if (!user) return res.status(401).json({ success: false, message: "Correo o contraseña incorrectos." });

        const passwordMatch = await bcrypt.compare(contrasenia, user.contrasenia);
        if (!passwordMatch) return res.status(401).json({ success: false, message: "Correo o contraseña incorrectos." });

        delete user.contrasenia;

        res.json({
            success: true,
            message: "Inicio de sesión exitoso.",
            user: user, 
            token: "simulated-jwt-token" 
        });

    } catch (error) {
        console.error("🔥 Error en login:", error); 
        res.status(500).json({ success: false, message: "Error interno." });
    }
};

// --- FUNCIÓN REGISTRO ---
const register = async (req, res) => {
    const { nombre, apellidos, tlf, correo, contrasenia, tipo } = req.body;

    try {
        console.log("📦 Body recibido:", req.body); 

        // Validaciones básicas
        if (!contrasenia) {
            return res.status(400).json({ success: false, message: "Falta la contraseña." });
        }

        // Datos seguros
        const nombreSafe = nombre || "Usuario";
        const apellidosSafe = apellidos || "";
        const tlfSafe = tlf || "";
        const correoNorm = correo ? correo.toString().toLowerCase().trim() : '';
        
        // Lógica de tipo
        let inputTipo = tipo ? tipo.toString().toLowerCase().trim() : '';
        let tipoFinal = (inputTipo === 'profesional' || inputTipo === 'agencia') ? inputTipo : 'comprador';

        // Hash
        const salt = await bcrypt.genSalt(10);
        const contraseniaHash = await bcrypt.hash(contrasenia, salt);
        const id = uuidv4();

        console.log(`💾 Guardando: ${correoNorm} como ${tipoFinal}`);
        
        await UserModel.crear(id, nombreSafe, apellidosSafe, tlfSafe, correoNorm, contraseniaHash, tipoFinal, 'usuario');

        res.status(201).json({
            success: true,
            message: "Registrado correctamente",
            tipo: tipoFinal,
        });

    } catch (error) {
        console.error("🔥 ERROR REGISTRO:", error);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ success: false, message: "Correo ya registrado." });
        }
        res.status(500).json({ success: false, message: error.message });
    }
};

// ✅ EXPORTACIÓN SEGURA AL FINAL DEL ARCHIVO
module.exports = {
    login,
    register
};
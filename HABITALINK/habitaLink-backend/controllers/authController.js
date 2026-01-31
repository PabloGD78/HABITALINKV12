const UserModel = require('../models/userModel');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

// --- FUNCIÓN LOGIN ---
const login = async (req, res) => {
    // Normalizamos el correo
    const correo = req.body.correo ? req.body.correo.toLowerCase().trim() : "";
    const { contrasenia } = req.body;

    try {
        console.log("=== INTENTO LOGIN ===", correo);
        
        // Buscar usuario
        const user = await UserModel.buscarPorCorreo(correo);
        if (!user) {
            return res.status(401).json({ success: false, message: "Correo o contraseña incorrectos." });
        }

        // Comparar contraseñas
        const passwordMatch = await bcrypt.compare(contrasenia, user.contrasenia);
        if (!passwordMatch) {
            return res.status(401).json({ success: false, message: "Correo o contraseña incorrectos." });
        }

        // Eliminar contraseña del objeto respuesta por seguridad
        const { contrasenia: _, ...userSinPass } = user;

        res.json({
            success: true,
            message: "Inicio de sesión exitoso.",
            user: userSinPass, 
            token: "simulated-jwt-token" // Aquí iría tu JWT real si lo usas
        });

    } catch (error) {
        console.error("🔥 Error en login:", error); 
        res.status(500).json({ success: false, message: "Error interno del servidor." });
    }
};

// --- FUNCIÓN REGISTRO ---
const register = async (req, res) => {
    try {
        const { nombre, apellidos, tlf, correo, contrasenia, tipo } = req.body;

        if (!correo || !contrasenia) {
            return res.status(400).json({ success: false, message: "Faltan datos obligatorios (correo o contraseña)." });
        }

        const correoNorm = correo.toString().toLowerCase().trim();
        
        // --- LÓGICA DE TIPO DE USUARIO (CORREGIDA) ---
        let inputTipo = tipo ? tipo.toString().toLowerCase().trim() : 'comprador';
        
        // Permitimos estos tipos exactos que tienes en tu base de datos
        const tiposValidos = ['particular', 'profesional', 'agencia', 'comprador'];
        
        // Si el tipo enviado no es válido, asignamos 'comprador' por defecto.
        // Esto asegura que si envías 'particular', SE QUEDE como 'particular'.
        let tipoFinal = tiposValidos.includes(inputTipo) ? inputTipo : 'comprador';

        // Generar ID y Hash de contraseña
        const id = uuidv4();
        const salt = await bcrypt.genSalt(10);
        const contraseniaHash = await bcrypt.hash(contrasenia, salt);

        console.log(`💾 Registrando usuario: ${correoNorm} como [${tipoFinal}]`);
        
        // Llamada al modelo para insertar (rol por defecto 'usuario')
        await UserModel.crear(id, nombre || "Usuario", apellidos || "", tlf || "", correoNorm, contraseniaHash, tipoFinal, 'usuario');

        res.status(201).json({
            success: true,
            message: "Registrado correctamente",
            tipo: tipoFinal,
        });

    } catch (error) {
        console.error("🔥 ERROR REGISTRO:", error);
        // Código de error MySQL para duplicados
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ success: false, message: "El correo ya está registrado." });
        }
        res.status(500).json({ success: false, message: "Error en el servidor." });
    }
};

module.exports = { login, register };
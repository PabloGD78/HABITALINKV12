import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/auth_service.dart';

final AuthService _authService = AuthService(); // Inicializa el servicio

// --- Widget Principal de la Página ---

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Tu AppBar original se mantiene)
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppColors.kPadding,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.home,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    tooltip: 'Volver a la página principal',
                  ),
                  Image.asset(
                    'assets/logo/LogoSinFondo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Container(
              color: AppColors.primary,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  NavMenuItem(title: 'Comprar'),
                  NavMenuItem(title: 'Alquilar'),
                  NavMenuItem(title: 'Valoración'),
                  NavMenuItem(title: 'Favoritos'),
                ],
              ),
            ),
          ],
        ),
      ),
      // Cuerpo de la página de Registro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppColors.kPadding),
          child:
              const _RegisterForm(), // Widget privado para el formulario de registro
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// --- WIDGETS DEL FORMULARIO DE REGISTRO (MODIFICADOS) ---
// ------------------------------------------------------------------

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  // Controladores para todos los campos requeridos por el backend
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _tlfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _tipoSeleccionado = 'Particular';

  // Función para mostrar alertas de resultado
  void _showMessageDialog(String title, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessageDialog('Error', 'Las contraseñas no coinciden.', false);
      return;
    }

    final result = await _authService.register(
      nombre: _nombreController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      tlf: _tlfController.text.trim(),
      correo: _emailController.text.trim(),
  contrasenia: _passwordController.text,
  tipo: _tipoSeleccionado,
    );

    if (result['success'] == true) {
      _showMessageDialog('Éxito', result['message'], true);
      // Navegar a la página de login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showMessageDialog('Error', result['message'], false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _tlfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Icono de Usuario
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.iconColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),

            // 2. Campo Nombre
            _RegisterTextField(
              controller: _nombreController, // Pasar controlador
              hintText: 'Nombre',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // 3. Campo Apellidos (Añadido)
            _RegisterTextField(
              controller: _apellidosController, // Pasar controlador
              hintText: 'Apellidos',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // 4. Campo Teléfono (Añadido)
            _RegisterTextField(
              controller: _tlfController, // Pasar controlador
              hintText: 'Teléfono',
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // 5. Campo Email
            _RegisterTextField(
              controller: _emailController, // Pasar controlador
              hintText: 'Usuario@gmail.com',
              icon: Icons.mail_outline,
            ),
            const SizedBox(height: 20),

            // 6. Campo Contraseña
            _RegisterTextField(
              controller: _passwordController, // Pasar controlador
              hintText: 'Contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 20),

            // 7. Campo Confirmar Contraseña
            _RegisterTextField(
              controller: _confirmPasswordController, // Pasar controlador
              hintText: 'Confirmar contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 20),

            // Selector de Tipo (Particular / Profesional)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Registrarse como:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _tipoSeleccionado,
                  items: const [
                    DropdownMenuItem(value: 'Particular', child: Text('Particular')),
                    DropdownMenuItem(value: 'Profesional', child: Text('Profesional')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _tipoSeleccionado = v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 8. Botón Crear Cuenta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleRegister, // Llama a la función de registro
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Verde oscuro
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 9. Link a Iniciar sesión
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                'Iniciar sesión ↗',
                style: TextStyle(color: AppColors.iconColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// --- WIDGETS AUXILIARES (MODIFICADOS) ---
// ------------------------------------------------------------------

/// Un TextField personalizado
class _RegisterTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller; // Aceptar Controller
  final TextInputType keyboardType;

  const _RegisterTextField({
    required this.hintText,
    required this.icon,
    required this.controller, // Recibir Controller
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Asignar Controller
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.hintTextColor),
        prefixIcon: Icon(icon, color: AppColors.iconColor),
        filled: true,
        fillColor: AppColors.textFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // Sin borde
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 25,
        ),
      ),
    );
  }
}

/// Widget para el menú de navegación
class NavMenuItem extends StatelessWidget {
  final String title;
  const NavMenuItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}

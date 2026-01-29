import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'admin/admin_dashboard_screen.dart'; // Verifica que esta ruta sea correcta

final AuthService _authService = AuthService();

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppColors.kPadding),
          child: const _LoginForm(),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showMessageDialog(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessageDialog("Por favor, rellena todos los campos", false);
      return;
    }

    final result = await _authService.login(
      correo: _emailController.text.trim(),
      contrasenia: _passwordController.text,
    );

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      final userData = result['user'];

      // --- GUARDAR ESTADO DE SESIÓN ---
      await prefs.setBool('userLoggedIn', true);
      await prefs.setString('userName', userData['nombre'] ?? 'Usuario');
      
      // Limpiamos el rol para evitar errores de mayúsculas o espacios
      String rol = (userData['rol'] ?? 'usuario').toString().trim().toLowerCase();
      await prefs.setString('rol', rol); 
      
      await prefs.setString(
        'tipo',
        (userData['tipo'] ?? 'particular').toString().toLowerCase(),
      );
      await prefs.setString('userId', userData['id']?.toString() ?? '');

      // DEBUG: Para que veas en la consola de Flutter qué rol se guardó
      debugPrint("DEBUG: Login exitoso. Rol detectado: $rol");

      if (!mounted) return;
      _showMessageDialog("Bienvenido, ${userData['nombre']}", true);

      // --- NAVEGACIÓN BASADA EN ROL ---
      if (rol == 'admin') {
  // FORMA CORRECTA PARA QUE CAMBIE LA URL:
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/admin_dashboard_screen', // <--- Al poner el nombre, la URL del navegador cambiará
    (route) => false,
  );
} else {
  // Lo mismo para el usuario normal
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/', 
    (route) => false,
  );
}
    } else {
      _showMessageDialog(result['message'] ?? 'Error de credenciales', false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            _LoginTextField(
              controller: _emailController,
              hintText: 'Usuario@gmail.com',
              icon: Icons.mail_outline,
            ),
            const SizedBox(height: 20),
            _LoginTextField(
              controller: _passwordController,
              hintText: '.........',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ),
              child: const Text(
                'Crear cuenta ↗',
                style: TextStyle(color: AppColors.iconColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const _LoginTextField({
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<_LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<_LoginTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: AppColors.hintTextColor),
        prefixIcon: Icon(widget.icon, color: AppColors.iconColor),
        filled: true,
        fillColor: AppColors.textFieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 25,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.iconColor,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}

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
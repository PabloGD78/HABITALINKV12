import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

// 1. IMPORTAMOS LOS DASHBOARDS (Asegúrate que los archivos estén en la carpeta correcta)
import 'particular_dashboard.dart';
import 'professional_dashboard.dart'; // <--- IMPORTANTE: Agregado este import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _backgroundColor = const Color(0xFFF3E5CD);

  String? userName;
  String? userEmail;
  String? userPassword;
  String? userType;
  bool _isLoading = true;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('userName') ?? 'Usuario';
      userEmail = prefs.getString('userEmail') ?? 'Correo no disponible';
      userPassword = prefs.getString('userPassword') ?? '';
      userType = prefs.getString('tipo')?.toLowerCase();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para saber qué tipo de usuario es
    bool isProfesional = userType == 'profesional';
    bool isParticular = userType == 'particular';

    // El Dashboard se muestra si es Profesional O Particular
    bool showDashboard = isProfesional || isParticular;

    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 40 : 20,
                    horizontal: isDesktop ? 40 : 16,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 320,
                              child: _buildIdentityCard(
                                isProfesional,
                                isParticular,
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: _buildMainContent(
                                showDashboard,
                                isProfesional,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildIdentityCard(isProfesional, isParticular),
                            const SizedBox(height: 25),
                            _buildMainContent(showDashboard, isProfesional),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildIdentityCard(bool isProfesional, bool isParticular) {
    String badgeText = 'USUARIO';
    Color badgeColor = Colors.grey;

    if (isProfesional) {
      badgeText = 'PROFESIONAL';
      badgeColor = AppColors.primary;
    } else if (isParticular) {
      badgeText = 'PARTICULAR';
      badgeColor = Colors.orange[800]!;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: _backgroundColor,
                    child: Text(
                      userName != null && userName!.isNotEmpty
                          ? userName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                Text(
                  userName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userEmail!,
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool showDashboard, bool isProfesional) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDashboard) ...[
          _buildDashboardCard(isProfesional),
          const SizedBox(height: 30),
        ],

        const Padding(
          padding: EdgeInsets.only(bottom: 15, left: 5),
          child: Text(
            'Información de la Cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFormRow('Nombre', userName!, showEdit: true),
              Divider(height: 1, color: AppColors.primary.withOpacity(0.1)),
              _buildFormRow('Correo', userEmail!, showEdit: false),
              Divider(height: 1, color: AppColors.primary.withOpacity(0.1)),
              _buildPasswordRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(bool isProfesional) {
    final String label = isProfesional
        ? 'PANEL PROFESIONAL'
        : 'PANEL DE GESTIÓN';
    final String title = isProfesional
        ? 'Gestiona tu Inmobiliaria'
        : 'Gestiona tus Anuncios';
    final String subtitle = isProfesional
        ? 'Accede a tus métricas y propiedades.'
        : 'Revisa las visitas y edita tus inmuebles.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // --- BOTÓN DE NAVEGACIÓN ACTUALIZADO ---
          ElevatedButton(
            onPressed: () {
              if (userType == 'particular') {
                // Navegación para Particular
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParticularDashboard(),
                  ),
                );
              } else if (userType == 'profesional') {
                // Navegación para Profesional (CONECTADO AHORA)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfessionalDashboard(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Ir al Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Contraseña',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _showPassword
                  ? (userPassword ?? '')
                  : '•' *
                        (userPassword != null && userPassword!.isNotEmpty
                            ? userPassword!.length
                            : 8),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primary.withOpacity(0.5),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, String value, {bool showEdit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
          if (showEdit)
            InkWell(
              onTap: () {},
              child: Text(
                'Editar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Asegúrate de que estas rutas sean correctas en tu proyecto
import '../theme/colors.dart';
import 'particular_dashboard.dart';
import 'professional_dashboard.dart';

// --- MODELO DE DATOS ---
class AnuncioPerfil {
  final String titulo;
  final String precio;
  final String estado;
  final String imagenUrl;

  AnuncioPerfil({
    required this.titulo,
    required this.precio,
    required this.estado,
    required this.imagenUrl,
  });

  factory AnuncioPerfil.fromJson(Map<String, dynamic> json) {
    String img = json['imagenPrincipal'] ?? '';
    // Manejo robusto de imágenes (por si viene como string de array)
    if (img.startsWith('[')) {
      try {
        List<dynamic> imgs = jsonDecode(img);
        if (imgs.isNotEmpty) img = imgs[0];
      } catch (_) {}
    }

    return AnuncioPerfil(
      titulo: json['nombre'] ?? 'Sin título',
      precio: json['precio'] != null ? "${json['precio']} €" : "0 €",
      estado: json['estado'] ?? 'Desconocido',
      imagenUrl: img,
    );
  }
}

// --- PÁGINA PRINCIPAL DE PERFIL ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color _backgroundColor = const Color(0xFFF3E5CD);

  // Datos del usuario
  String? userName;
  String? userEmail;
  String? userPassword;
  String? userType;
  String? idUsuario;

  bool _isLoading = true;
  bool _showPassword = false;

  // Lista de anuncios
  List<AnuncioPerfil> misAnuncios = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    String? id1 = prefs.getString('idUsuario');
    String? id2 = prefs.getString('userId');
    String? id3 = prefs.getString('id');

    idUsuario = id1 ?? id2 ?? id3;

    userName = prefs.getString('userName') ?? 'Usuario';
    userEmail = prefs.getString('userEmail') ?? 'Correo no disponible';
    userPassword = prefs.getString('userPassword') ?? '';
    userType = prefs.getString('tipo')?.toLowerCase();

    if (idUsuario != null && idUsuario!.isNotEmpty) {
      await _fetchUserProperties(idUsuario!);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProperties(String userId) async {
    try {
      final url = Uri.parse(
        'http://localhost:3000/api/propiedades/usuario/$userId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> listaBruta = [];

        if (decoded is List) {
          listaBruta = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          listaBruta = decoded['data'];
        }

        setState(() {
          misAnuncios = listaBruta
              .map((json) => AnuncioPerfil.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching user properties: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isProfesional = userType == 'profesional';
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ajustes de Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20, // Texto un poco más chico
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 30 : 16,
                    horizontal: isDesktop ? 40 : 16,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 350, // Columna izquierda más estrecha
                              child: Column(
                                children: [
                                  _buildIdentityCard(isProfesional),
                                  const SizedBox(height: 20),
                                  _buildAccountDetailsCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTopBanner(isProfesional),
                                  const SizedBox(height: 30),
                                  _buildUserPropertiesSection(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildIdentityCard(isProfesional),
                            const SizedBox(height: 20),
                            _buildTopBanner(isProfesional),
                            const SizedBox(height: 20),
                            _buildAccountDetailsCard(),
                            const SizedBox(height: 30),
                            _buildUserPropertiesSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  // --- WIDGETS DE UI ---

  Widget _buildIdentityCard(bool isProfesional) {
    String badgeText = isProfesional ? 'PROFESIONAL' : 'PARTICULAR';
    Color badgeColor = isProfesional
        ? AppColors.primary
        : const Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 90, // Altura reducida
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF3D6158)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40, // Avatar más pequeño
                      backgroundColor: _backgroundColor,
                      child: Text(
                        userName != null && userName!.isNotEmpty
                            ? userName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Text(
            userName ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: badgeColor.withOpacity(0.2)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20), // Padding reducido
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos Personales',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Nombre completo', userName ?? ''),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF3F4F6)),
          _buildInfoRow('Correo electrónico', userEmail ?? ''),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF3F4F6)),
          _buildPasswordRow(),
        ],
      ),
    );
  }

  Widget _buildTopBanner(bool isProfesional) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // Menos padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1A2E2A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Panel de Control",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Gestiona y analiza tus publicaciones.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => isProfesional
                      ? const ProfessionalDashboard()
                      : const ParticularDashboard(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "Ir a mi Panel de Control",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPropertiesSection() {
    if (misAnuncios.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.folder_open, size: 40, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "No tienes anuncios publicados.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    int itemCount = misAnuncios.length > 2 ? 2 : misAnuncios.length;
    bool showSeeAllButton = misAnuncios.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Mis anuncios",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              "${misAnuncios.length} total",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // AQUI ESTA LA CLAVE PARA HACERLO "CHICO":
            // Un valor más alto hace la tarjeta más ancha y baja.
            // 0.85 es vertical (estilo móvil), 1.2 es casi cuadrado.
            // Usamos 0.9 para un balance compacto.
            childAspectRatio: 0.9,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return _buildAnuncioCard(misAnuncios[index]);
          },
        ),
        if (showSeeAllButton) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllAdsPage(allAnuncios: misAnuncios),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Ver todos",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // TARJETA COMPACTA Y OPTIMIZADA
  Widget _buildAnuncioCard(AnuncioPerfil anuncio) {
    Color colorEstado = anuncio.estado == 'Activo'
        ? Colors.green.shade100
        : Colors.red.shade100;
    Color textoEstado = anuncio.estado == 'Activo'
        ? Colors.green.shade900
        : Colors.red.shade900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN MÁS CHICA
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.grey.shade100,
                image: anuncio.imagenUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(anuncio.imagenUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: anuncio.imagenUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
          // CONTENIDO COMPACTO
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anuncio.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anuncio.precio,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          anuncio.estado,
                          style: TextStyle(
                            color: textoEstado,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Botón Mini
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contraseña',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _showPassword ? userPassword! : '••••••••',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
        IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9CA3AF),
            size: 20,
          ),
        ),
      ],
    );
  }
}

// --- PANTALLA SECUNDARIA: VER TODOS (OPTIMIZADA) ---
class AllAdsPage extends StatelessWidget {
  final List<AnuncioPerfil> allAnuncios;

  const AllAdsPage({super.key, required this.allAnuncios});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5CD),
      appBar: AppBar(
        title: const Text(
          "Todos mis anuncios",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // Aspect Ratio 0.8: Tarjetas verticales compactas
            childAspectRatio: 0.8,
          ),
          itemCount: allAnuncios.length,
          itemBuilder: (context, index) {
            return _buildCompactGridCard(allAnuncios[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCompactGridCard(AnuncioPerfil anuncio) {
    Color colorEstado = anuncio.estado == 'Activo'
        ? Colors.green.shade100
        : Colors.red.shade100;
    Color textoEstado = anuncio.estado == 'Activo'
        ? Colors.green.shade900
        : Colors.red.shade900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade100,
              child: anuncio.imagenUrl.isNotEmpty
                  ? Image.network(anuncio.imagenUrl, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.image, color: Colors.black12, size: 30),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anuncio.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anuncio.precio,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          anuncio.estado,
                          style: TextStyle(
                            color: textoEstado,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.edit, size: 14, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

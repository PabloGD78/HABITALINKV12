import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'particular_dashboard.dart';
import 'professional_dashboard.dart';

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
    bool isProfesional = userType == 'profesional';
    bool isParticular = userType == 'particular';
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ajustes de Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
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
                    vertical: isDesktop ? 40 : 20,
                    horizontal: isDesktop ? 40 : 16,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 380,
                              child: Column(
                                children: [
                                  _buildIdentityCard(
                                    isProfesional,
                                    isParticular,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildAccountDetailsCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTopBanner(isProfesional),
                                  const SizedBox(height: 48),
                                  _buildPropertiesSection(
                                    context,
                                    isParticular,
                                  ), // PASAMOS LA VARIABLE AQUI
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildIdentityCard(isProfesional, isParticular),
                            const SizedBox(height: 24),
                            _buildTopBanner(isProfesional),
                            const SizedBox(height: 24),
                            _buildAccountDetailsCard(),
                            const SizedBox(height: 32),
                            _buildPropertiesSection(
                              context,
                              isParticular,
                            ), // PASAMOS LA VARIABLE AQUI
                          ],
                        ),
                ),
              ),
            ),
    );
  }

  Widget _buildIdentityCard(bool isProfesional, bool isParticular) {
    String badgeText = isProfesional
        ? 'PROFESIONAL'
        : (isParticular ? 'PARTICULAR' : 'USUARIO');
    Color badgeColor = isProfesional
        ? AppColors.primary
        : const Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF3D6158)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: -45,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: _backgroundColor,
                      child: Text(
                        userName != null ? userName![0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 38,
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
          const SizedBox(height: 55),
          Text(
            userName ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withOpacity(0.2)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Nombre completo', userName ?? ''),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF3F4F6)),
          _buildInfoRow('Correo electrónico', userEmail ?? ''),
          const Divider(height: 32, thickness: 1, color: Color(0xFFF3F4F6)),
          _buildPasswordRow(),
        ],
      ),
    );
  }

  Widget _buildTopBanner(bool isProfesional) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage(
            "https://www.transparenttextures.com/patterns/carbon-fibre.png",
          ),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
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
            "Análisis y Métricas en Tiempo Real",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Optimiza tus ventas revisando el rendimiento de tus publicaciones.",
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 30),
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
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            ),
            child: const Text(
              "Acceder a mi panel de control",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFICADO: Acepta isParticular para pasarlo al botón ---
  Widget _buildPropertiesSection(BuildContext context, bool isParticular) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Mis anuncios",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // AQUI PASAMOS EL DATO PARA QUE LA SIGUIENTE PANTALLA SEPA QUÉ MOSTRAR
                  builder: (context) =>
                      AllAdsScreen(isParticular: isParticular),
                ),
              ),
              icon: const Text(
                "Ver todos",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              label: const Icon(
                Icons.arrow_forward,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // GridView de vista previa (se mantiene igual)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.4,
          ),
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=500',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Piso de Lujo en Centro",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Activo • 24 visitas hoy",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _showPassword ? userPassword! : '••••••••',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
        IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF9CA3AF),
            size: 22,
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------------
// PANTALLA DE TODOS LOS ANUNCIOS (MODIFICADA)
// -------------------------------------------------------------------------

class AllAdsScreen extends StatelessWidget {
  final bool isParticular;

  // Aceptamos el parámetro para saber qué vista mostrar
  const AllAdsScreen({super.key, this.isParticular = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // O un gris muy claro para contrastar tarjetas
      appBar: AppBar(
        title: const Text(
          "Mis anuncios",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      // AQUI ESTA LA LOGICA: Si es particular mostramos la lista detallada, si no, la lista simple
      body: isParticular ? _buildParticularView() : _buildProfessionalView(),
    );
  }

  // --- VISTA PARA PARTICULARES (Estilo Tarjeta Detallada) ---
  Widget _buildParticularView() {
    // Datos de ejemplo simulando diferentes estados
    final List<Map<String, String>> misAnunciosParticular = [
      {
        "titulo": "Ático con terraza centro",
        "precio": "250.000 €",
        "estado": "Activo",
        "imagen":
            "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500",
      },
      {
        "titulo": "Piso reformado 3 hab",
        "precio": "180.000 €",
        "estado": "Caduca pronto",
        "imagen":
            "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=500",
      },
      {
        "titulo": "Garaje zona norte",
        "precio": "15.000 €",
        "estado": "Caducado",
        "imagen":
            "https://images.unsplash.com/photo-1580587771525-78b9dba3b91d?w=500",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: misAnunciosParticular.length,
      itemBuilder: (context, index) {
        final anuncio = misAnunciosParticular[index];
        return TarjetaAnuncioParticular(
          titulo: anuncio["titulo"]!,
          precio: anuncio["precio"]!,
          estado: anuncio["estado"]!,
          imagenUrl: anuncio["imagen"]!,
        );
      },
    );
  }

  // --- VISTA PARA PROFESIONALES (La lista simple que ya tenías) ---
  Widget _buildProfessionalView() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              "Ref: #4829${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text("Piso • 3 Dormitorios • 125m²"),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------------------
// NUEVO WIDGET: DISEÑO TARJETA PARTICULAR (Con foto, precio, estado y botones)
// -------------------------------------------------------------------------
class TarjetaAnuncioParticular extends StatelessWidget {
  final String titulo;
  final String precio;
  final String estado; // "Activo", "Caduca pronto", "Caducado"
  final String imagenUrl;

  const TarjetaAnuncioParticular({
    super.key,
    required this.titulo,
    required this.precio,
    required this.estado,
    required this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color colorEstado;
    Color colorTextoEstado;
    String textoBoton = "Editar";
    IconData iconoBoton = Icons.edit;
    Color colorBoton = AppColors.primary; // Color por defecto (editar)

    // Lógica de colores según el estado
    if (estado == "Caduca pronto") {
      colorEstado = Colors.orange.shade100;
      colorTextoEstado = Colors.orange.shade900;
      textoBoton = "Renovar";
      iconoBoton = Icons.refresh;
      colorBoton = Colors.orange;
    } else if (estado == "Caducado") {
      colorEstado = Colors.red.shade100;
      colorTextoEstado = Colors.red.shade900;
      textoBoton = "Renovar";
      iconoBoton = Icons.refresh;
      colorBoton = Colors.red;
    } else {
      // Activo
      colorEstado = Colors.green.shade100;
      colorTextoEstado = Colors.green.shade900;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imagen a la izquierda
              Container(
                width: 110,
                height: 110,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imagenUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 2. Información a la derecha
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 14.0,
                    right: 14.0,
                    bottom: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.2,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        precio,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Estadísticas (Vistas y Chats)
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_rounded,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          Text(
                            " 145  ",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.chat_bubble_rounded,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          Text(
                            " 3",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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

          const Divider(height: 1, indent: 12, endIndent: 12),

          // 3. Parte inferior: Estado y Botones
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chip de Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      color: colorTextoEstado,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Botón de Acción
                if (estado != "Activo")
                  SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorBoton,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: Icon(iconoBoton, color: Colors.white, size: 16),
                      label: Text(
                        textoBoton,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      "Editar",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

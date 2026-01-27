import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/property_card.dart';
import '../widgets/footer_widget.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import 'property/property_detail_page.dart';
import 'property/new_property_card_page.dart';

import 'search_results_page.dart';
import 'favoritos_page.dart';
import 'notificaciones_page.dart';
import 'informe_admin_page.dart';
import 'agency_dashboard.dart';
import 'profile_page.dart'; // ✅ IMPORTACIÓN AÑADIDA

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userRole;
  String? userType;
  final PropertyService _propertyService = PropertyService();

  List<PropertySummary> _featuredProperties = [];
  bool _isLoading = true;
  String? _error;
  late PageController _carouselController;
  int _currentCarouselPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFeaturedProperties();
    _carouselController = PageController();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      userRole = prefs.getString('rol')?.toLowerCase();
      userType = prefs.getString('tipo')?.toLowerCase();
    });
  }

  Future<void> _loadFeaturedProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final allProperties = await _propertyService.obtenerTodas();
      allProperties.sort((a, b) => b.creationDate.compareTo(a.creationDate));
      setState(() {
        _featuredProperties = allProperties.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar propiedades: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // ✅ FUNCIÓN MODIFICADA: Ahora conecta con ProfilePage
  void _showGoogleProfileCard(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (context) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 70, right: 20),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón cerrar X
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          userName != null ? userName![0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Saludo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '¡Hola, ${userName ?? 'Usuario'}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // BOTONES INFERIORES
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Cierra el diálogo pequeño
                              // ✅ NAVEGACIÓN A LA PÁGINA DE PERFIL NUEVA
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(28),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Perfil',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _logout();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(28),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Salir',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = math.min(
      300.0,
      screenWidth * (_featuredProperties.length > 1 ? 0.4 : 0.8),
    );
    final cardHeight = cardWidth * 1.5;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                children: [
                  const Spacer(),
                  Center(
                    child: Image.asset(
                      'assets/logo/LogoSinFondo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  if (userName == null)
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          'Hola, $userName',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (userRole == 'usuario' && userType == 'profesional')
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () {},
                          ),
                        if (userRole == 'admin')
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InformeAdminPage(),
                              ),
                            ),
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text('Informe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showGoogleProfileCard(context),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              color: AppColors.primary,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(
                    'Comprar',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchResultsPage(),
                      ),
                    ),
                  ),
                  _navItem(
                    'Anunciar',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewPropertyCardPage(),
                      ),
                    ),
                  ),
                  _navItem(
                    'Notificaciones',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    ),
                  ),
                  _navItem(
                    'Favoritos',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritosPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Conecta con tu espacio ideal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppColors.kPadding),
              child: SizedBox(height: 60, child: SearchBarWidget()),
            ),
            if (userRole == 'usuario' && userType == 'profesional') ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.kPadding,
                  vertical: 20,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgencyDashboardPage(),
                    ),
                  ),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(width: 20),
                        Icon(
                          Icons.dashboard_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            'Panel Inmobiliario',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            _sectionTitle('Últimas Propiedades'),
            _sectionSubtitle('Descubre las viviendas más recientes añadidas.'),
            const SizedBox(height: 20),
            SizedBox(
              height: cardHeight + 40,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildErrorWidget()
                  : _buildCarousel(cardWidth, cardHeight),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FooterWidget(compact: true),
    );
  }

  Widget _navItem(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppColors.kPadding),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  );

  Widget _sectionSubtitle(String subtitle) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppColors.kPadding),
    child: Text(
      subtitle,
      style: const TextStyle(fontSize: 18, color: Colors.grey),
    ),
  );

  Widget _buildErrorWidget() => Center(
    child: Text(_error!, style: const TextStyle(color: Colors.red)),
  );

  Widget _buildCarousel(double cardWidth, double cardHeight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int itemsPerPage = constraints.maxWidth >= 1200
            ? 4
            : (constraints.maxWidth >= 900
                  ? 3
                  : (constraints.maxWidth >= 600 ? 2 : 1));
        final pagesCount =
            (_featuredProperties.length + itemsPerPage - 1) ~/ itemsPerPage;

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _carouselController,
                itemCount: pagesCount,
                onPageChanged: (p) => setState(() => _currentCarouselPage = p),
                itemBuilder: (context, pageIndex) {
                  final chunk = _featuredProperties
                      .skip(pageIndex * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: chunk
                        .map(
                          (property) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: PropertyCard(
                              property: property,
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              onDetailsPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailPage(
                                    propertyRef: property.id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            _buildDots(pagesCount),
          ],
        );
      },
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentCarouselPage ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentCarouselPage ? AppColors.primary : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

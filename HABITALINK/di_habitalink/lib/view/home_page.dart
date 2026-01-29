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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userRole; // admin / usuario
  String? userType; // profesional / particular
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
      print('DEBUG: userRole = $userRole, userType = $userType');
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
    Navigator.pushReplacementNamed(context, '/login');
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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

                        // ✅ Chat y Panel profesional
                        if (userRole == 'usuario' &&
                            userType == 'profesional') ...[
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              // Acción chat
                            },
                            tooltip: 'Mensajes',
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AgencyDashboardPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.dashboard_customize,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Mi Panel',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // ✅ Botón admin
                        

                        PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'logout') _logout();
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'logout',
                              child: Text('Cerrar sesión'),
                            ),
                          ],
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Barra de navegación azul
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppColors.kPadding,
                ),
                child: const Text(
                  'Conecta con tu espacio ideal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppColors.kPadding,
              ),
              child: SizedBox(height: 60, child: const SearchBarWidget()),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panel Inmobiliario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Consulta visitas, contactos y rendimiento',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                  : _featuredProperties.isEmpty
                  ? const Center(child: Text('No hay propiedades disponibles.'))
                  : _buildCarousel(cardWidth, cardHeight),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const FooterWidget(compact: true),
    );
  }

  Widget _navItem(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
    child: Padding(
      padding: const EdgeInsets.all(AppColors.kPadding),
      child: Text(
        _error!,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    ),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _carouselController,
                    itemCount: pagesCount,
                    onPageChanged: (p) =>
                        setState(() => _currentCarouselPage = p),
                    itemBuilder: (context, pageIndex) {
                      final start = pageIndex * itemsPerPage;
                      final end =
                          (start + itemsPerPage) < _featuredProperties.length
                          ? (start + itemsPerPage)
                          : _featuredProperties.length;
                      final chunk = _featuredProperties.sublist(start, end);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: chunk
                            .map(
                              (property) => Padding(
                                padding: const EdgeInsets.only(
                                  right: AppColors.kMargin,
                                ),
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
                  if (pagesCount > 1) ...[
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, size: 36),
                        onPressed: () => _moveCarousel(-1, pagesCount),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_right, size: 36),
                        onPressed: () => _moveCarousel(1, pagesCount),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDots(pagesCount),
          ],
        );
      },
    );
  }

  void _moveCarousel(int direction, int pagesCount) {
    int next = (_currentCarouselPage + direction) % pagesCount;
    if (next < 0) next = pagesCount - 1;
    _carouselController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _currentCarouselPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

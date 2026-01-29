import 'package:flutter/material.dart';
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
import 'agency_dashboard.dart';

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
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Column(
          children: [
            // --- LOGO Y SESIÓN ---
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
                  _buildSessionAction(),
                ],
              ),
            ),
            // --- BARRA NAVEGACIÓN AZUL (CORREGIDA) ---
            Container(
              color: AppColors.primary,
              height: 45,
              child: Row(
                children: [
                  _navItem('Comprar', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchResultsPage()))),
                  _navItem('Anunciar', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPropertyCardPage()))),
                  _navItem('Notificaciones', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()))),
                  _navItem('Favoritos', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritosPage()))),
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
            _buildHeroText(),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppColors.kPadding),
              child: SizedBox(height: 60, child: SearchBarWidget()),
            ),
            if (userRole == 'usuario' && userType == 'profesional') _buildAgencyBanner(),
            const SizedBox(height: 40),
            _sectionTitle('Últimas Propiedades'),
            _sectionSubtitle('Descubre las viviendas más recientes.'),
            const SizedBox(height: 20),
            // --- CARRUSEL CON ALTURA CORREGIDA ---
            SizedBox(
              height: 280, 
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorWidget()
                      : _featuredProperties.isEmpty
                          ? const Center(child: Text('No hay propiedades.'))
                          : _buildCarousel(screenWidth),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const FooterWidget(compact: true),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildHeroText() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppColors.kPadding),
        child: Text(
          'Conecta con tu espacio ideal',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSessionAction() {
    if (userName == null) {
      return ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Iniciar sesión', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      );
    }
    return Row(
      children: [
        Text('Hola, $userName', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        PopupMenuButton(
          onSelected: (value) => value == 'logout' ? _logout() : null,
          itemBuilder: (context) => [const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión'))],
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // MÉTODO NAV ITEM CORREGIDO PARA EVITAR OVERFLOW
  Widget _navItem(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppColors.kPadding, vertical: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgencyDashboardPage())),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: ListTile(
              leading: Icon(Icons.dashboard_rounded, size: 40, color: Colors.white),
              title: Text('Panel Inmobiliario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Gestiona tus propiedades aquí', style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppColors.kPadding),
        child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
      );

  Widget _sectionSubtitle(String subtitle) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppColors.kPadding),
        child: Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      );

  Widget _buildErrorWidget() => Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

  Widget _buildCarousel(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int itemsPerPage = constraints.maxWidth >= 1200 ? 4 : (constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 600 ? 2 : 1));
        final pagesCount = (_featuredProperties.length + itemsPerPage - 1) ~/ itemsPerPage;

        return Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _carouselController,
                    itemCount: pagesCount,
                    onPageChanged: (p) => setState(() => _currentCarouselPage = p),
                    itemBuilder: (context, pageIndex) {
                      final start = pageIndex * itemsPerPage;
                      final end = (start + itemsPerPage) < _featuredProperties.length ? (start + itemsPerPage) : _featuredProperties.length;
                      final chunk = _featuredProperties.sublist(start, end);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: chunk.map((property) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: PropertyCard(
                              property: property,
                              isCompact: true,
                              onDetailsPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PropertyDetailPage(propertyRef: property.id)),
                              ),
                            ),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                  if (pagesCount > 1) ...[
                    Positioned(left: 0, child: IconButton(icon: const Icon(Icons.chevron_left, size: 30), onPressed: () => _moveCarousel(-1, pagesCount))),
                    Positioned(right: 0, child: IconButton(icon: const Icon(Icons.chevron_right, size: 30), onPressed: () => _moveCarousel(1, pagesCount))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDots(pagesCount),
          ],
        );
      },
    );
  }

  void _moveCarousel(int direction, int pagesCount) {
    int next = (_currentCarouselPage + direction) % pagesCount;
    if (next < 0) next = pagesCount - 1;
    _carouselController.animateToPage(next, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _currentCarouselPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(color: active ? AppColors.primary : Colors.grey[400], borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }
}
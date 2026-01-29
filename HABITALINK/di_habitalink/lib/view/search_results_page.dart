import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/filter_sidebar.dart';
// Asegúrate de que este sea el import correcto de tu nuevo PropertyCard
import '../widgets/property_card.dart'; 
import '../widgets/search_bar_widget.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import '../models/filter_data_model.dart';
import 'property/property_detail_page.dart';
import 'notificaciones_page.dart';
import 'favoritos_page.dart';

const double _kMaxWidth = 1200.0;

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final PropertyService _propertyService = PropertyService();

  List<PropertySummary> _allPropertiesFromDb = [];
  List<PropertySummary> _filteredProperties = [];
  bool _loading = true;
  String? _errorMessage;
  String? _initialQuery;
  String? _initialFilter;

  @override
  void initState() {
    super.initState();
    _loadInitialProperties();
  }

  Future<void> _loadInitialProperties() async {
    try {
      final data = await _propertyService.obtenerTodas();
      setState(() {
        _allPropertiesFromDb = data;
        _filteredProperties = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  void _onFilterChanged(FilterData filters) {
    if (_allPropertiesFromDb.isEmpty && !_loading) return;

    setState(() {
      _filteredProperties = _allPropertiesFromDb.where((property) {
        // Filtros de precio, tipo, etc. (Tu lógica actual se mantiene igual)
        if (property.price < filters.minPrice || property.price > filters.maxPrice) return false;
        if (filters.type != null && property.type != filters.type) return false;
        // ... (resto de filtros)
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Center(
        child: SizedBox(
          width: _kMaxWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel lateral de filtros
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: FilterSidebar(onFilterChanged: _onFilterChanged),
                ),
              ),
              
              // Divisor visual
              Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(vertical: 20)),

              // Lista de resultados
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(child: Text('Error: $_errorMessage'))
                          : _filteredProperties.isEmpty
                              ? const Center(child: Text('No se encontraron propiedades.'))
                              : _buildResultsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _filteredProperties.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final property = _filteredProperties[index];
        return PropertyCard(
          property: property,
          isCompact: false, // <--- Aquí usamos la versión grande para resultados
          onDetailsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailPage(propertyRef: property.id),
              ),
            );
          },
        );
      },
    );
  }

  // El AppBar se mantiene igual a tu diseño anterior...
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: SafeArea(
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/'),
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(child: SearchBarWidget(isDense: true, borderRadius: 30.0)),
              const SizedBox(width: 15),
              _buildActionIcon(Icons.favorite_border, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritosPage()))),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.notifications_none, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()))),
              const SizedBox(width: 10),
              const CircleAvatar(radius: 25, backgroundColor: AppColors.primary, child: Icon(Icons.person_outline, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: AppColors.primary,
      child: IconButton(icon: Icon(icon, color: Colors.white), onPressed: onTap),
    );
  }
}
import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../services/admin_service.dart';

class HomeController extends ChangeNotifier {
  // Conectamos con el servicio que habla con la BD real
  final AdminService _adminService = AdminService();

  List<PropertySummary> _featuredProperties = [];
  bool _isLoading = true;

  // Getters para que la vista pueda leer los datos
  List<PropertySummary> get featuredProperties => _featuredProperties;
  bool get isLoading => _isLoading;

  HomeController() {
    loadFeaturedProperties();
  }

  Future<void> loadFeaturedProperties() async {
    _isLoading = true;
    notifyListeners(); // Avisa a la vista "Cargando..."

    try {
      // 1. Obtenemos la lista cruda (Mapas) desde el backend
      final List<Map<String, dynamic>> rawData = await _adminService.getProperties();

      // 2. Usamos el .fromJson de tu modelo para convertir los datos
      // Esto soluciona el error de "double vs int" porque el modelo ya lo gestiona internamente
      _featuredProperties = rawData
          .map((item) => PropertySummary.fromJson(item))
          .toList();

    } catch (e) {
      print("Error cargando propiedades en Home: $e");
      _featuredProperties = []; // Si falla, lista vacía para no romper la UI
    }

    _isLoading = false;
    notifyListeners(); // Avisa a la vista "Ya tengo los datos"
  }
}
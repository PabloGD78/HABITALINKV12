// lib/controllers/home_controller.dart - CÓDIGO COMPLETO Y CORREGIDO

import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../models/property_data_source.dart'; // Importa allProperties

class HomeController extends ChangeNotifier {
  // Lista para las propiedades destacadas (p.ej., las primeras 2 de tu lista general)
  List<PropertySummary> _featuredProperties = [];
  List<PropertySummary> get featuredProperties => _featuredProperties;

  HomeController() {
    loadFeaturedProperties();
  }

  // Cargar las propiedades destacadas usando la lista global
  void loadFeaturedProperties() {
  // Mostrar todas las propiedades del data source (sin límite)
  _featuredProperties = allProperties.toList();
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import 'property_service.dart' as prop_service;

class FavoriteService {
  // ✅ Cambia a '10.0.2.2' si usas emulador de Android
  final String baseUrl = 'http://localhost:3000/api/favoritos'; 

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (kDebugMode) print('DEBUG: ID de usuario recuperado de las preferencias: $userId');
    return userId;
  }

  Future<List<PropertySummary>> getFavorites() async {
    final userId = await _getUserId();
    if (userId == null) {
      if (kDebugMode) print('Error: No se puede cargar favoritos porque el ID de usuario es NULL.');
      return [];
    }

    final url = Uri.parse('$baseUrl/user/$userId');
    try {
      final response = await http.get(url);
      if (kDebugMode) print('DEBUG: Respuesta de obtener favoritos: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final propService = prop_service.PropertyService();
        final List<PropertySummary> results = [];
        
        for (final id in data) {
          try {
            final prop = await propService.obtenerPropiedadDetalle(id.toString());
            results.add(PropertySummary.fromDetailedProperty(prop));
          } catch (e) {
            if (kDebugMode) print('No se pudo cargar favorito individual $id: $e');
          }
        }
        return results;
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error de conexión al obtener favoritos: $e');
      return [];
    }
  }

  Future<bool> addFavorite(String propertyId) async {
    final userId = await _getUserId();
    
    // 🔍 Esto nos dirá si el problema es que no hay usuario logeado
    if (userId == null) {
      if (kDebugMode) print('❌ ERROR: No se puede añadir a favoritos. El user_id es NULL. ¿Has iniciado sesión?');
      return false;
    }

    final url = Uri.parse('$baseUrl/add');
    if (kDebugMode) print('DEBUG: Enviando POST a $url con User: $userId y Prop: $propertyId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_usuario': userId, 
          'id_propiedad': propertyId
        }),
      );

      if (kDebugMode) {
        print('DEBUG: Respuesta del servidor al añadir: ${response.statusCode}');
        print('DEBUG: Cuerpo de respuesta: ${response.body}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) print('❌ ERROR de conexión al añadir favorito: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String propertyId) async {
    final userId = await _getUserId();
    if (userId == null) return false;

    final url = Uri.parse('$baseUrl/remove');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_usuario': userId, 
          'id_propiedad': propertyId
        }),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error al eliminar favorito: $e');
      return false;
    }
  }
}
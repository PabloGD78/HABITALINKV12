import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/property_model.dart';

const String _baseUrl = 'http://localhost:3000';
// Asegúrate de que esta URL sea la que funciona en el navegador
const String apiUrl = '$_baseUrl/api/properties'; 

class PropertyService {
  
  // 1. OBTENER DETALLE DE UNA SOLA PROPIEDAD
  Future<Property> obtenerPropiedadDetalle(String propertyId) async {
    final url = Uri.parse('$apiUrl/$propertyId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Cambiado a 'property' para coincidir con el backend
        if (jsonResponse['success'] == true && jsonResponse.containsKey('property')) {
          return Property.fromJson(jsonResponse['property']);
        }
        throw Exception('Formato de datos de propiedad inesperado.');
      } 
      throw Exception('Error de servidor: ${response.statusCode}');
    } catch (e) {
      throw Exception('Fallo al obtener detalle: $e');
    }
  }

  // 2. OBTENER TODAS LAS PROPIEDADES
  Future<List<PropertySummary>> obtenerTodas() async {
    final url = Uri.parse(apiUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Cambiado a 'properties' para coincidir con tu JSON
        if (jsonResponse['success'] == true && jsonResponse.containsKey('properties')) {
          final List<dynamic> propertiesList = jsonResponse['properties'];
          return propertiesList
              .map((jsonItem) => PropertySummary.fromJson(jsonItem))
              .toList();
        }
        throw Exception('La llave "properties" no existe en la respuesta.');
      } 
      throw Exception('Error al cargar propiedades: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
    // Al añadir los "throw" dentro de los bloques, Dart ya sabe que 
    // nunca se devolverá un null por error.
  }

  // 3. OBTENER PROPIEDADES POR TIPO
  Future<List<PropertySummary>> obtenerPropiedadesPorTipo(String tipo) async {
    try {
      final allProperties = await obtenerTodas();
      return allProperties.where((prop) {
        return prop.type.toLowerCase() == tipo.toLowerCase();
      }).toList();
    } catch (e) {
      throw Exception('Fallo al filtrar por tipo: $e');
    }
  }
}
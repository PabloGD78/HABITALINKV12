import 'package:latlong2/latlong.dart';
import 'property_model.dart'; // PropertySummary

// --- BASE DE DATOS SIMULADA ---
final Map<String, Property> _database = {
  'W-02UXX4': Property(
    ref: 'W-02UXX4',
    title:
        'Casa o chalet independiente en venta en Santa Cruz - Alfalfa Centro, Sevilla',
    price: '3400000',
    area: '888',
    beds: '10',
    baths: '8',
  description: 'Exclusiva y Majestuosa Casa Palacio. Al entrar, desde las calles peatonales...',
    location: LatLng(37.3865, -5.9933),
    images: [
      'assets/engels_volkers/ref_w02uxx4/1.png',
      'assets/engels_volkers/ref_w02uxx4/2.png',
    ],
    features: ['Piscina', 'Garaje'],
  ),
  'SV-001': Property(
    ref: 'SV-001',
    title: 'Piso en venta en Calle San Vicente, 90',
    price: '380000',
    area: '82',
    beds: '2',
    baths: '1',
  description: 'Descubre este espectacular piso reformado. Con una superficie construida de 82 m²...',
    location: LatLng(37.3891, -5.9915),
    images: [
      'assets/italyca/ref_01360/1.png',
      'assets/italyca/ref_01360/2.png',
    ],
    features: ['Balcón', 'Trastero', 'Aire Acondicionado'],
  ),
};

// --- LISTA PÚBLICA DE PROPIEDADES ---
final List<PropertySummary> allProperties = _database.values
    .map((p) => PropertySummary.fromDetailedProperty(p))
    .toList();

// --- FUNCIÓN SIMULADA ---
Property getPropertyByRef(String ref) {
  final normalizedRef = ref.trim();
  final property = _database[normalizedRef];
  if (property == null) {
    throw Exception('Property with ref $ref not found.');
  }
  return property;
}

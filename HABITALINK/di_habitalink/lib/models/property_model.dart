import 'package:latlong2/latlong.dart';

// -----------------------------------------------------------------------------
// 0. CONFIGURACIÓN DE URL BASE
// -----------------------------------------------------------------------------
const String baseUrl = 'http://localhost:3000'; 

// -----------------------------------------------------------------------------
// 1. FUNCIONES HELPER (UTILIDADES)
// -----------------------------------------------------------------------------

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    final cleanString = value
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^\d\.]'), '')
        .trim();
    return double.tryParse(cleanString) ?? 0.0;
  }
  return 0.0;
}

int _parseToInt(dynamic value) => _parseToDouble(value).toInt();

DateTime _parseToDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

String _makeAbsoluteUrl(String? path) {
  if (path == null || path.isEmpty) return 'https://via.placeholder.com/400';
  if (path.startsWith('http')) return path;
  String cleanPath = path.startsWith('2.') ? path.substring(2) : path;
  if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
  return baseUrl + cleanPath;
}

String _formatCurrency(num value) {
  if (value == 0) return '0 €';
  final s = value.toInt().toString(); 
  final buffer = StringBuffer();
  int offset = s.length % 3;
  if (offset > 0) {
    buffer.write(s.substring(0, offset));
    if (s.length > 3) buffer.write('.');
  }
  for (int i = offset; i < s.length; i += 3) {
    buffer.write(s.substring(i, i + 3));
    if (i + 3 < s.length) buffer.write('.');
  }
  return '${buffer.toString()} €';
}

// -----------------------------------------------------------------------------
// 2. MODELO DE DETALLE: Property
// -----------------------------------------------------------------------------

class Property {
  final String ref;
  final String title;
  final String price; 
  final String area;
  final String beds;
  final String baths;
  final String description;
  final LatLng location;
  final List<String> images;
  final List<String> features;

  Property({
    required this.ref,
    required this.title,
    required this.price,
    required this.area,
    required this.beds,
    required this.baths,
    required this.description,
    required this.location,
    required this.images,
    required this.features,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final lat = _parseToDouble(json['latitude']);
    final lon = _parseToDouble(json['longitude']);

    List<String> imagesList = [];
    if (json['imagenes'] != null && json['imagenes'] is List) {
      imagesList = (json['imagenes'] as List)
          .map((i) => _makeAbsoluteUrl(i.toString()))
          .toList();
    } else if (json['url_imagen'] != null) {
      imagesList = [_makeAbsoluteUrl(json['url_imagen'].toString())];
    }

    return Property(
      ref: json['id']?.toString() ?? json['ref']?.toString() ?? '',
      title: json['titulo_completo'] ?? json['titulo'] ?? 'Sin título',
      price: json['precio']?.toString() ?? '0',
      area: json['superficie']?.toString() ?? '0',
      beds: json['dormitorios']?.toString() ?? '0',
      baths: json['banos']?.toString() ?? '0',
      description: json['descripcion_larga'] ?? json['descripcion'] ?? 'Sin descripción.',
      location: LatLng(lat, lon),
      images: imagesList,
      features: List<String>.from(json['caracteristicas'] ?? []),
    );
  }
}

extension PropertyFormatters on Property {
  double get priceValue => _parseToDouble(price);
  String get formattedPrice => _formatCurrency(priceValue);
}

// -----------------------------------------------------------------------------
// 3. MODELO DE RESUMEN: PropertySummary
// -----------------------------------------------------------------------------

class PropertySummary {
  final String id;
  final String imageUrl;
  final String title;
  final String details;
  final double price; 
  final int bedrooms;
  final int bathrooms;
  final double superficie;
  final String location;
  final String type;
  final bool hasPool;
  final List<String> features;
  final DateTime creationDate;

  PropertySummary({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.details,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.superficie,
    required this.location,
    required this.type,
    required this.hasPool,
    required this.features,
    required this.creationDate,
  });

  factory PropertySummary.fromJson(Map<String, dynamic> json) {
    final double superficieValue = _parseToDouble(json['superficie']);
    final int bedroomsValue = _parseToInt(json['dormitorios']);
    final int bathroomsValue = _parseToInt(json['banos']);
    final double priceValue = _parseToDouble(json['precio']);
    
    String thumbUrl = '';
    if (json['imagenes'] != null && (json['imagenes'] as List).isNotEmpty) {
      thumbUrl = _makeAbsoluteUrl(json['imagenes'][0].toString());
    } else {
      thumbUrl = _makeAbsoluteUrl(json['url_imagen']?.toString());
    }

    final bool hasPoolValue = (json['caracteristicas'] as List?)?.any(
      (f) => f.toString().toLowerCase().contains('piscina')
    ) ?? false;

    return PropertySummary(
      id: json['id']?.toString() ?? '',
      imageUrl: thumbUrl,
      title: json['titulo'] ?? 'Propiedad Sin Título',
      price: priceValue,
      bedrooms: bedroomsValue,
      bathrooms: bathroomsValue,
      superficie: superficieValue,
      location: json['ubicacion'] ?? 'Sevilla',
      type: json['tipo'] ?? 'Desconocido',
      hasPool: hasPoolValue,
      features: List<String>.from(json['caracteristicas'] ?? []),
      details: '$bedroomsValue habs - $bathroomsValue baños - ${superficieValue.toInt()} m2',
      creationDate: _parseToDateTime(json['fecha_creacion']),
    );
  }

  // ✅ AQUÍ ES DONDE IBA EL MÉTODO QUE FALTABA
  factory PropertySummary.fromDetailedProperty(Property detailedProperty) {
    final double priceValue = _parseToDouble(detailedProperty.price);
    final int bedroomsValue = _parseToInt(detailedProperty.beds);
    final int bathroomsValue = _parseToInt(detailedProperty.baths);
    final double superficieValue = _parseToDouble(detailedProperty.area);

    return PropertySummary(
      id: detailedProperty.ref,
      imageUrl: detailedProperty.images.isNotEmpty 
          ? detailedProperty.images.first 
          : 'https://via.placeholder.com/400',
      title: detailedProperty.title,
      price: priceValue,
      bedrooms: bedroomsValue,
      bathrooms: bathroomsValue,
      superficie: superficieValue,
      location: 'Sevilla',
      type: 'Propiedad',
      hasPool: detailedProperty.features.any((f) => f.toLowerCase().contains('piscina')),
      features: detailedProperty.features,
      details: '$bedroomsValue habs - $bathroomsValue baños - ${superficieValue.toInt()} m2',
      creationDate: DateTime.now(),
    );
  }
}

extension PropertySummaryFormatters on PropertySummary {
  String get formattedPrice => _formatCurrency(price);
}
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../theme/colors.dart';
import '../config/env.dart'; // Asegúrate de haber creado el archivo Env

class PropertyCard extends StatelessWidget {
  final PropertySummary property;
  final VoidCallback? onDetailsPressed;
  final bool isCompact; // true para Home, false para Resultados/Favoritos

  const PropertyCard({
    super.key,
    required this.property,
    this.onDetailsPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos la URL centralizada de Env
    final String imageUrl = property.imageUrl.startsWith('http') 
        ? property.imageUrl 
        : "${Env.baseUrl}/${property.imageUrl.replaceAll(RegExp(r'^/'), '')}";

    return Container(
      width: double.infinity,
      height: isCompact ? 160 : 200, // Altura adaptable
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompact ? Colors.white : const Color(0xFFF0E5D0), // Estilo dinámico
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // IMAGEN
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: SizedBox(
              width: isCompact ? 120 : 150,
              height: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover),
              ),
            ),
          ),
          // CONTENIDO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: isCompact ? Colors.black87 : const Color(0xFF855227)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${property.superficie} m² • ${property.bedrooms} hab • ${property.bathrooms} baños",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    property.formattedPrice,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: onDetailsPressed,
                      child: Text(
                        isCompact ? 'Ver más >' : 'Más detalles ↗',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}